import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:epub_view/epub_view.dart' hide Image;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:resourcemanager/common/EpubParsing.dart';
import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/entity/book/BookItem.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart' hide Text;
import 'package:resourcemanager/main.dart';
import 'package:resourcemanager/routes/book/widgets/PageBar.dart';
import 'package:resourcemanager/routes/book/widgets/TextPage.dart';
import 'package:resourcemanager/routes/book/widgets/TextPcPage.dart';
import 'package:resourcemanager/state/book/SeriesContentState.dart';

class BookRead extends ConsumerStatefulWidget {
  const BookRead(
      {super.key,
      required this.bookItem,
      this.textSize = 15,
      required this.seriesId});

  final BookItem bookItem;
  final int seriesId;
  final int textSize;

  @override
  ConsumerState<BookRead> createState() => BookReadState();
}

class BookReadState extends ConsumerState<BookRead> {
  late EpubBook epubBook;
  bool isLoading = true;
  late Map<String, EpubByteContentFile>? imageMap;
  late String temporaryFolder;
  late Directory folder;
  late int charsPerLine;
  late int linesPerPage;
  List<List<TextContent>> _list = [];
  late Isolate _isolate;
  late ReceivePort _receivePort;
  final ValueNotifier<bool> currentValue = ValueNotifier<bool>(false);
  final ValueNotifier<int> currentPage = ValueNotifier<int>(1);
  PageController pageController = PageController();
  List<int> bytes = [];
  late final AppLifecycleListener appLifecycleListener;

  double? lastMaxWidth;
  Timer? debounceTimer;

  Timer? _timer;

  late int readTagNum;
  late double progress;

  @override
  void initState() {
    super.initState();
    temporaryFolder = "${widget.bookItem.id}";
    readTagNum = widget.bookItem.readTagNum;
    progress = widget.bookItem.progress;

    HardwareKeyboard.instance.addHandler(_handleEvent);

    appLifecycleListener = AppLifecycleListener(
      onHide: () => updateProgress(), //隐藏了程序会触发
      onInactive: () => updateProgress(), //失去了焦点，但是页面还在后台（PC） 分屏、画中画（Android）
    );
  }

  bool _handleEvent(event) {
    if (HardwareKeyboard.instance.logicalKeysPressed
        .contains(LogicalKeyboardKey.arrowLeft)) {
      pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.linear);
      return false;
    } else if (HardwareKeyboard.instance.logicalKeysPressed
        .contains(LogicalKeyboardKey.arrowRight)) {
      pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.linear);
      return false;
    }

    return false;
  }

  void _calculateTextFit(BoxConstraints? constraints) {
    BuildContext context = MyApp.rootNavigatorKey.currentContext!;

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = constraints?.maxWidth ?? mediaQuery.size.width;
    final screenHeight = constraints?.maxHeight ?? mediaQuery.size.height;

    final safeAreaHorizontal =
        mediaQuery.padding.left + mediaQuery.padding.right;
    final safeAreaVertical = mediaQuery.padding.top + mediaQuery.padding.bottom;

    final availableWidth = (screenWidth - safeAreaHorizontal - 10 * 2);

    // 增加行高调整，1.2 是默认的行高比例，你可以根据实际需要进行调整
    const textStyle = TextStyle(fontSize: 15); // 适当调整 height
    final textPainter = TextPainter(
      text: const TextSpan(text: "然", style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final charWidth = textPainter.size.width;

    if (screenWidth < MyApp.width) {
      final charHeight = textPainter.size.height + 1;
      charsPerLine = (availableWidth / charWidth).floor();
      linesPerPage = ((screenHeight - safeAreaVertical) / charHeight).floor();
    } else {
      final charHeight = textPainter.size.height + 2;

      charsPerLine = (((availableWidth / charWidth - 5) - 2) / 2).floor();
      linesPerPage = ((screenHeight - safeAreaVertical) / charHeight).floor();
    }
  }

  void getEpub() async {
    Directory directory = await getTemporaryDirectory();
    folder = Directory("${directory.path}/$temporaryFolder");
    if (!folder.existsSync()) folder.createSync();

    // 替换反斜杠为正斜杠，并对路径进行 URI 编码
    String encodedFilePath = Uri.encodeFull(
      widget.bookItem.filePath.replaceAll('\\', '/').substring(1),
    );

    // 请求文件字节数据
    if (bytes.isEmpty) {
      bytes = await HttpApi.request(
        encodedFilePath,
        responseType: ResponseType.bytes,
        () => {},
        isLoading: false,
      );
    }

    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(parsing, [
      bytes,
      folder.path,
      _receivePort.sendPort,
      charsPerLine,
      linesPerPage,
      readTagNum
    ]);

    // 监听 Isolate 的消息
    _receivePort.listen((list) {
      _list = list[0];
      currentPage.value = MediaQuery.of(context).size.width > MyApp.width
          ? (list[1] / 2).floor()
          : list[1];

      pageController = PageController(initialPage: currentPage.value);

      setState(() {
        isLoading = false;
      });
    });
  }

  void updateProgress() {
    BookItem item = widget.bookItem;
    item.readTagNum = readTagNum;
    item.progress = progress;
    ref
        .read(seriesContentStateProvider(widget.seriesId).notifier)
        .updateProgress(item);
  }

  // 关闭 Isolate
  @override
  void dispose() {
    _isolate.kill(priority: Isolate.immediate);
    _receivePort.close();

    HardwareKeyboard.instance.removeHandler(_handleEvent);
    super.dispose();

    appLifecycleListener.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: PopScope(
          onPopInvokedWithResult: (bool didPop, Object? result) {
            updateProgress();
          },
          child: SafeArea(
              child: MediaQuery.of(context).size.width < MyApp.width
                  ? getMobile()
                  : getPc())),
    );
  }

  Widget getPc() {
    return LayoutBuilder(builder: (context, constraints) {
      if (lastMaxWidth == null) {
        _calculateTextFit(constraints);
        getEpub();
        lastMaxWidth ??= constraints.maxWidth;
      }

      debounceTimer = Timer(const Duration(milliseconds: 1000), () {
        if (lastMaxWidth != constraints.maxWidth) {
          lastMaxWidth = constraints.maxWidth;
          _isolate.kill(priority: Isolate.immediate);
          _receivePort.close();

          _calculateTextFit(constraints);
          getEpub();

          setState(() => isLoading = true);
        }
      });

      if (isLoading) {
        return const Center(
          child: SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(),
          ),
        );
      }

      int index = (_list.length / 2).ceil();
      List<Widget> widgetList = [];
      for (int i = 0; i < index; i++) {
        List<TextContent> content1 = _list[i * 2];

        List<TextContent> content2 = [];
        if (i * 2 + 1 < _list.length) {
          content2 = _list[i * 2 + 1];
        }

        widgetList.add(TextPcPage(
          list: content1,
          list2: content2,
        ));
      }
      return Listener(
        onPointerHover: (value) {
          currentValue.value = true;
          _resetIdleTimer();
        },
        onPointerMove: (value) {
          currentValue.value = true;
        },
        onPointerSignal: (PointerSignalEvent event) {
          if (event is PointerScrollEvent) {
            // 判断鼠标滚动
            if (event.scrollDelta.dy < 0) {
              pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.linear);
            } else if (event.scrollDelta.dy > 0) {
              pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.linear);
            }
          }
        },
        child: Stack(
          children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: PageView(
                  controller: pageController,
                  onPageChanged: (value) {
                    currentPage.value = value + 1;
                    readTagNum = _list[value * 2].first.num;
                    progress = currentPage.value / widgetList.length;
                  },
                  children: widgetList,
                )),
            Positioned(
                top: 0,
                left: 0,
                child: GestureDetector(
                  child: ValueListenableBuilder(
                      valueListenable: currentValue,
                      builder: (context, value, child) {
                        return AnimatedOpacity(
                            opacity: value ? 1 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                                width: constraints.maxWidth,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                color: Theme.of(context)
                                    .cardColor
                                    .withOpacity(0.8),
                                child: Row(
                                  children: [
                                    IconButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        icon: const Icon(
                                            Icons.arrow_back_ios_new)),
                                    Expanded(
                                      child: Text(
                                        widget.bookItem.name!,
                                        style: const TextStyle(fontSize: 18),
                                        maxLines: 2,
                                      ),
                                    )
                                  ],
                                )));
                      }),
                )),
            Positioned(
              bottom: 0,
              left: 0,
              child: GestureDetector(
                  child: ValueListenableBuilder(
                      valueListenable: currentValue,
                      builder: (context, value, child) {
                        return AnimatedOpacity(
                            opacity: value ? 1 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                                width: constraints.maxWidth,
                                padding: const EdgeInsets.all(10),
                                color: Theme.of(context)
                                    .cardColor
                                    .withOpacity(0.8),
                                child: ValueListenableBuilder(
                                    valueListenable: currentPage,
                                    builder: (context, value, child) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                IconButton(
                                                    onPressed: () =>
                                                        pageController
                                                            .jumpToPage(0),
                                                    icon: const Icon(Icons
                                                        .keyboard_double_arrow_left_outlined)),
                                                Expanded(
                                                    child: Listener(
                                                  onPointerDown: (event) {},
                                                  child: Slider(
                                                      label:
                                                          "${currentPage.value}",
                                                      value: currentPage.value
                                                          .toDouble(),
                                                      onChanged: (value) {
                                                        pageController
                                                            .jumpToPage(
                                                                value.toInt());
                                                      },
                                                      max: index.toDouble()),
                                                )),
                                                IconButton(
                                                    onPressed: () =>
                                                        pageController
                                                            .jumpToPage(index),
                                                    icon: const Icon(Icons
                                                        .keyboard_double_arrow_right_outlined)),
                                              ]),
                                          Text(
                                            "当前阅读进度:${currentPage.value}/${index}",
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          // Text(
                                          //   "${double.parse((currentPage.value / _list.length).toStringAsFixed(3))}",
                                          //   style:
                                          //   const TextStyle(fontSize: 16),
                                          // ),
                                        ],
                                      );
                                    })));
                      })),
            )
          ],
        ),
      );
    });
  }

  Widget getMobile() {
    if (isLoading) {
      _calculateTextFit(null);
      getEpub();
      return const Center(
        child: SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(),
        ),
      );
    }

    return GestureDetector(
      onTap: () => currentValue.value = !currentValue.value,
      child: Stack(
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: PageView(
                controller: pageController,
                onPageChanged: (value) {
                  currentPage.value = value + 1;
                  readTagNum = _list[value].first.num;
                  progress = currentPage.value / _list.length;
                },
                children: _list.map((value) => TextPage(list: value)).toList(),
              )),
          Positioned(
              top: 0,
              left: 0,
              child: GestureDetector(
                child: ValueListenableBuilder(
                    valueListenable: currentValue,
                    builder: (context, value, child) {
                      return AnimatedOpacity(
                          opacity: value ? 1 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              color:
                                  Theme.of(context).cardColor.withOpacity(0.8),
                              child: Row(
                                children: [
                                  IconButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      icon:
                                          const Icon(Icons.arrow_back_ios_new)),
                                  Expanded(
                                    child: Text(
                                      widget.bookItem.name!,
                                      style: const TextStyle(fontSize: 18),
                                      maxLines: 2,
                                    ),
                                  )
                                ],
                              )));
                    }),
                onTap: () {},
              )),
          Positioned(
            bottom: 0,
            left: 0,
            child: GestureDetector(
                child: ValueListenableBuilder(
                    valueListenable: currentValue,
                    builder: (context, value, child) {
                      return AnimatedOpacity(
                          opacity: value ? 1 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.all(10),
                              color:
                                  Theme.of(context).cardColor.withOpacity(0.8),
                              child: ValueListenableBuilder(
                                  valueListenable: currentPage,
                                  builder: (context, value, child) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              IconButton(
                                                  onPressed: () =>
                                                      pageController
                                                          .jumpToPage(0),
                                                  icon: const Icon(Icons
                                                      .keyboard_double_arrow_left_outlined)),
                                              Expanded(
                                                  child: Listener(
                                                child: Slider(
                                                    value: currentPage.value
                                                        .toDouble(),
                                                    onChanged: (value) {
                                                      pageController.jumpToPage(
                                                          value.toInt());
                                                    },
                                                    max: _list.length
                                                        .toDouble()),
                                              )),
                                              IconButton(
                                                  onPressed: () =>
                                                      pageController.jumpToPage(
                                                          _list.length),
                                                  icon: const Icon(Icons
                                                      .keyboard_double_arrow_right_outlined)),
                                            ]),
                                        Text(
                                          "当前阅读进度:${currentPage.value}/${_list.length}",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        // Text(
                                        //   "${double.parse((currentPage.value / _list.length).toStringAsFixed(3))}",
                                        //   style:
                                        //   const TextStyle(fontSize: 16),
                                        // ),
                                      ],
                                    );
                                  })));
                    })),
          )
        ],
      ),
    );
  }

  void _resetIdleTimer() {
    // 如果之前有计时器，取消它
    _timer?.cancel();

    // 设置一个新的计时器，假设 2 秒后将 currentValue 设为 false
    _timer = Timer(const Duration(seconds: 2), () {
      currentValue.value = false;
    });
  }
}

class TextContent {
  String value;
  int type;
  int num;

  TextContent(this.type, this.value, this.num);
}

class IsolateData {
  final List<int> epubBytes;
  final String folderPath;
  final SendPort sendPort;
  final int charsPerLine;
  final int linesPerPage;

  IsolateData(this.epubBytes, this.folderPath, this.sendPort, this.charsPerLine,
      this.linesPerPage);
}

void parsing(List<dynamic> args) async {
  List<int> epubBytes = args[0];
  String folderPath = args[1];
  SendPort sendPort = args[2];
  int charsPerLine = args[3];
  int linesPerPage = args[4];
  int readNum = args[5];

  int currentNum = 0;
  int readPage = 0;

  EpubParsing epubParsing = EpubParsing();
  List<TextContent> strList = [];
  List<List<TextContent>> _list = [];
  int lastId = -1;

  String saveTemporaryImage(List<int> list, String name) {
    File file = File("${folderPath}/$name");
    if (!file.existsSync()) file.createSync(recursive: true);
    file.writeAsBytesSync(list);
    return file.path;
  }

  void setLine(String str, int type) {
    if (str.isEmpty) return;

    //跳过的页面
    if (readNum == currentNum) {
      readPage = _list.length;
    }
    ;

    int index = (str.length / charsPerLine).floor();
    if (type == 1) {
      for (int i = 0; i <= index; i++) {
        if (strList.length + 1 >= linesPerPage) {
          _list.add(List.from(strList));
          strList.clear();
        }

        final content = TextContent(
          type,
          str.substring(
              i * charsPerLine,
              (i + 1) * charsPerLine > str.length
                  ? str.length
                  : (i + 1) * charsPerLine),
          currentNum,
        );

        strList.add(content);
      }
      if (strList.length + 1 != linesPerPage) {
        strList.add(TextContent(4, "//br", currentNum));
      }
    } else if (type == 2) {
      for (int i = 0; i < index; i++) {
        if (strList.length + 1 >= linesPerPage) {
          _list.add(List.from(strList));
          strList.clear();
        }
        strList.add(TextContent(
            type, str.substring(0, (charsPerLine / 2).ceil() - 1), currentNum));
        strList.add(TextContent(5, "//title", currentNum));
      }
    } else {
      if (strList.isNotEmpty) {
        _list.add(List.from(strList));
        strList.clear();
      }
      strList.add(TextContent(type, str, currentNum));
      _list.add(List.from(strList));
      strList.clear();
      // print("_list${_list[0][0].value}");
    }
  }

  void parseElement(element, id) {
    if (id != lastId && strList.isNotEmpty) {
      _list.add(List.from(strList));
      strList.clear();
    }
    lastId = id;
    const allowedTags = {
      'p',
      'h1',
      'h2',
      'h3',
      'h4',
      'h5',
      'h6',
      'img',
      'image'
    };
    // 获取标签名称
    var tagName = element.localName;
    var textValue = "";
    // 获取标签的文本值
    if (allowedTags.contains(tagName)) {
      if (tagName == 'img' || tagName == 'image') {
        late String path;

        // 对于 <img> 标签，优先选择 src；对于 <image> 标签，优先选择 xlink:href 或 href
        if (tagName == 'img') {
          path = element.attributes["src"]?.replaceAll('../', '');
        } else if (tagName == 'image') {
          element.attributes.forEach((key, value) {
            if (key.toString() == "xlink:href" || key.toString() == "href") {
              path = element.attributes[key]?.replaceAll('../', '');
            }
          });
        }

        List<int>? list = epubParsing.getImage(path);
        if (list != null && list.isNotEmpty) {
          String imagePath = saveTemporaryImage(list, path);
          setLine(imagePath, 3);
        }
      } else if ({"h1", "h2", "h3", "h4", "h5", "h6"}.contains(tagName)) {
        print(tagName);
        textValue = element.text.trim();
        setLine(textValue, 2);
      } else {
        textValue = element.text.trim();
        setLine(textValue, 1);
      }
    }
    currentNum++;
    element.children.forEach((element) => parseElement(element, id));
  }

  List<String>? list = await epubParsing.parseEpubFromBytes(epubBytes);
  if (list != null) {
    int key = 0;
    for (String item in list) {
      Document document = parse(item);
      document.body?.children.forEach((element) => parseElement(element, key));
      key++;
    }
  }

  sendPort.send([_list, readPage]);
}
