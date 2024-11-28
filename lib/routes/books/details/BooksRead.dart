import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:epubx/epubx.dart' hide Image;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/main.dart';
import 'package:resourcemanager/entity/BaseResult.dart';
import 'package:resourcemanager/models/GetBooksDetailsList.dart';
import 'package:resourcemanager/state/BooksState.dart';
import 'package:html/parser.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' hide Text;
import 'package:web_socket_channel/web_socket_channel.dart';

class BooksRead extends StatefulWidget {
  const BooksRead({super.key});

  @override
  State<StatefulWidget> createState() => BooksReadState();
}

class BooksReadState extends State<BooksRead> {
  late BooksState booksState;
  static late Details details;
  static PageController _pageController = PageController();
  static List<String> _pages = [];
  String data = "";
  List<String> htmlContents = [];
  bool isReady = false;
  static late EpubBook epubBook;
  late HardwareKeyboard hardwareKeyboard;
  ValueNotifier<int> currentIndex = ValueNotifier(0);
  late bool Function(KeyEvent event) _keyboardHandler;
  late final AppLifecycleListener appLifecycleListener;
  ValueNotifier<bool> showBar = ValueNotifier(false);

  @override
  void initState() {
    hardwareKeyboard = HardwareKeyboard.instance;
    _keyboardHandler = (KeyEvent event) {
      if (event.logicalKey.keyLabel == "Arrow Right" &&
          _pageController.positions.isNotEmpty) {
        _pageController.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.linear);
      } else if (event.logicalKey.keyLabel == "Arrow Left" &&
          _pageController.positions.isNotEmpty) {
        _pageController.previousPage(
            duration: const Duration(milliseconds: 300), curve: Curves.linear);
      }
      return true;
    };

    hardwareKeyboard.addHandler(_keyboardHandler);
    super.initState();
    appLifecycleListener = AppLifecycleListener(
      onHide: changeProgress,
    );
    booksState = Provider.of<BooksState>(context, listen: false);
    details = booksState.details;
    getEpub();
  }

  @override
  void dispose() {
    hardwareKeyboard.removeHandler(_keyboardHandler);
    changeProgress();
    appLifecycleListener.dispose();
    details.status = details.progress == 1 ? 2 : 3;
    WidgetsBinding.instance.addPostFrameCallback((Duration duration) {
      booksState.changeDetailsState();
    });
    super.dispose();
  }
  
  void changeProgress() => HttpApi.request("/booksDetails/changeProgress", (json) => json,params: {"id":details.id,"progress":details.progress});

  void getEpub() async {
    List<int> bytes = await HttpApi.request(
        "/files/${details.url}",
        responseType: ResponseType.bytes,
        () => {},
        isLoading: false);
    // epubBook = await EpubReader.readBook(bytes);

    EpubReader.readBook(bytes).then((value) {
      epubBook = value;
      setHtmlContents();
    });
  }

  void setHtmlContents() {
    for (var name in epubBook.Schema!.Package!.Spine!.Items!) {
      htmlContents.add(epubBook.Content!.Html!["Text/${name.IdRef}"]!.Content!);
    }
    setState(() {
      isReady = true;
    });
  }

  Widget _splitHtmlIntoPages(
      List<String> htmlContents, BoxConstraints constraints) {
    _pages.clear();
    final screenHeight = constraints.maxHeight;
    final screenWidth = constraints.maxWidth;

    String currentPage = '';
    double currentPageHeight = 0.0;

    double lineHeight = constraints.maxWidth > MyApp.width ? 23 : 20;
    double margin = 20; // This value can be adjusted

    for (var content in htmlContents) {
      Document document = parse(content);
      bool isImg = false;
      var list = [];
      if (document.body!.children.first.localName == "div" &&
          document.body!.children.first.children.isNotEmpty) {
        list = document.body!.children.first.children;
      } else {
        list = document.body!.children;
      }
      for (var element in list) {
        if (element.localName == 'img' ||
            (element.children.isNotEmpty &&
                element.children[0].localName == "img")) {
          if (currentPage.isNotEmpty) {
            _pages.add(currentPage);
            currentPage = '';
            currentPageHeight = 0.0;
          }
          isImg = true;
          _pages.add(element.outerHtml);
          continue;
        }

        int textLineCount =
            (element.text.length / (screenWidth / lineHeight)).ceil();
        double estimatedHeight = textLineCount * lineHeight + margin;

        if (currentPageHeight + estimatedHeight > screenHeight) {
          _pages.add(currentPage);
          currentPage = element.outerHtml;
          currentPageHeight = estimatedHeight;
        } else {
          currentPage += element.outerHtml;
          currentPageHeight += estimatedHeight;
        }
      }

      if (!isImg) {
        _pages.add(currentPage);
        currentPage = "";
        currentPageHeight = 0;
      }
    }

    // Add the last page if it's not empty
    if (currentPage.isNotEmpty) {
      _pages.add(currentPage);
    }

    currentIndex.value = (details.progress * _pages.length).ceil();
    if (currentIndex.value > 0) {
      _pageController = PageController(initialPage: currentIndex.value);
    }

    return GestureDetector(
        onTap: () {
          showBar.value = !showBar.value;
        },
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                String progress = ((index + 1) / _pages.length).toStringAsFixed(3);
                currentIndex.value = index;
                details.progress = double.parse(progress);
              },
              itemBuilder: (context, index) {
                return HtmlPage(_pages[index], constraints);
              },
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: ValueListenableBuilder(
                  valueListenable: currentIndex,
                  builder: (context, value, child) {
                    return Text("$value/${_pages.length}");
                  }),
            ),
            Positioned(
                child: ValueListenableBuilder<bool>(
                    valueListenable: showBar,
                    builder: (context, value, child) {
                      return AnimatedOpacity(
                          opacity: value ? 1 : 0,
                          duration: const Duration(milliseconds: 500),
                          child: const ReadBar());
                    }))
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (!isReady) {
        return const Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text("正在加载,请稍后..."),
            )
          ],
        );
      }
      return _splitHtmlIntoPages(htmlContents, constraints);
    });
  }
}

class HtmlPage extends StatelessWidget {
  final String htmlContent;
  final BoxConstraints constraints;

  const HtmlPage(this.htmlContent, this.constraints, {super.key});

  @override
  Widget build(BuildContext context) {
    print(htmlContent);
    return SingleChildScrollView(
      child: Html(
        data: htmlContent,
        extensions: [
          TagExtension(
            tagsToExtend: {"img"},
            builder: (imageContext) {
              final url = imageContext.attributes['src']!.replaceAll('../', '');
              final content = Uint8List.fromList(
                  BooksReadState.epubBook.Content!.Images![url]!.Content!);
              return Image(
                height: constraints.maxHeight,
                image: MemoryImage(content),
              );
            },
          ),
        ],
        style: {
          "br": Style(
              padding: HtmlPaddings.zero,
              margin: Margins.zero,
              height: Height(0),
              display: Display.none),
          "p": Style(
            padding: HtmlPaddings.zero,
            margin: Margins.only(bottom: 20),
            fontSize: FontSize(15),
          ),
          "img": Style(
            padding: HtmlPaddings.zero,
            margin: Margins.zero,
          )
        },
      ),
    );
  }
}

class ReadBar extends StatefulWidget {
  const ReadBar({super.key});

  @override
  State<StatefulWidget> createState() => ReadBarState();
}

class ReadBarState extends State<ReadBar> {
  @override
  Widget build(BuildContext context) {
    Details details = BooksReadState.details;
    PageController pageController = BooksReadState._pageController;
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: double.infinity,
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            details.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          width: double.infinity,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () => pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.linear),
                      icon: const Icon(Icons.keyboard_arrow_left_sharp)),
                  IconButton(
                      onPressed: () => pageController.jumpToPage(0),
                      icon: const Icon(Icons.keyboard_double_arrow_left_sharp)),
                  Expanded(
                      child: Slider(
                          value: details.progress,
                          onChanged: (value) {
                            setState(() {
                              details.progress = value;
                              pageController.jumpToPage((BooksReadState._pages.length * value).ceil());
                            });
                          })),
                  IconButton(
                      onPressed: () => pageController
                          .jumpToPage(BooksReadState._pages.length),
                      icon:
                          const Icon(Icons.keyboard_double_arrow_right_sharp)),
                  IconButton(
                      onPressed: () => pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.linear),
                      icon: const Icon(Icons.keyboard_arrow_right_sharp)),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
