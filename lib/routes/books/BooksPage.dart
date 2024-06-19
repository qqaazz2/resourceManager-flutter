import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resourcemanager/common/Global.dart';
import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/main.dart';
import 'package:resourcemanager/models/GetBooksList.dart';
import 'package:resourcemanager/routes/books/BooksPageDrawer.dart';
import 'package:resourcemanager/state/BooksState.dart';
import 'package:resourcemanager/widgets/ToolBar.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<StatefulWidget> createState() => BooksPageState();
}

class BooksPageState extends State<BooksPage> {
  int size = 10;
  static late BooksState booksState;

  @override
  void initState() {
    super.initState();
    booksState =
        Provider.of<BooksState>(MyApp.rootNavigatorKey.currentContext!,listen: false);
    booksState.getList(size);
    MyApp.drawer = const BooksPageDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      int num = 10;
      if (1300 > constraints.maxWidth && constraints.maxWidth > 600) {
        num = 4;
      } else if (constraints.maxWidth < MyApp.width) {
        num = 2;
      }
      return Consumer<BooksState>(builder: (context, value, child) {
        return Column(
          children: [
            if (constraints.maxWidth > MyApp.width)
              ToolBar(
                addButton: IconButton(
                    onPressed: () {
                      booksState.clearBooks();
                      BooksState.showDetails(
                          constraints.maxWidth > MyApp.width, context, null, 0);
                    },
                    icon: const Icon(Icons.add_circle_outline)),
              ),
            Expanded(
                child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (value.listNum < value.count &&
                    notification.metrics.atEdge &&
                    notification.metrics.pixels ==
                        notification.metrics.maxScrollExtent) {
                  value.getList(size);
                }
                return false;
              },
              child: GridView.builder(
                  itemCount: booksState.count,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: constraints.maxWidth / num,
                      childAspectRatio: 9 / 13),
                  itemBuilder: (context, index) {
                    return Container(
                        margin: const EdgeInsets.only(
                            bottom: 20, left: 20, right: 20),
                        child: constraints.maxWidth > MyApp.width
                            ? PCItem(
                                data: value.booksList[index],
                                index: index,
                              )
                            : MobileItem(
                                data: value.booksList[index],
                                index: index,
                              ));
                  }),
            ))
          ],
        );
      });
    });
  }
}

class MobileItem extends StatefulWidget {
  const MobileItem({super.key, required this.data, required this.index});

  final Data data;
  final int index;

  @override
  State<StatefulWidget> createState() => MobileItemState();
}

class MobileItemState extends State<MobileItem> {
  bool show = false;

  @override
  Widget build(BuildContext context) {
    return BooksItem(
      index: widget.index,
      data: widget.data,
      isPc: false,
      show: true,
    );
  }
}

class PCItem extends StatelessWidget {
  PCItem({super.key, required this.data, required this.index});

  final Data data;
  final int index;
  final ValueNotifier<bool> show = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        show.value = true;
      },
      onExit: (event) {
        show.value = false;
      },
      child: ValueListenableBuilder<bool>(
        builder: (BuildContext context, bool value, Widget? child) {
          return BooksItem(
            data: data,
            show: value,
            index: index,
          );
        },
        valueListenable: show,
      ),
      // child: BooksItem(data: data,show: show),
    );
  }
}

class BooksItem extends StatelessWidget {
  const BooksItem(
      {super.key,
      required this.data,
      this.show = false,
      this.isPc = true,
      required this.index});

  final Data data;
  final bool show;
  final bool isPc;
  final int index;

  @override
  Widget build(BuildContext context) {
    late Widget imageWidget;
    if (data.cover != null && data.cover!.isNotEmpty) {
      imageWidget = Image.network(
        "${HttpApi.options.baseUrl}files/${data.cover}",
        headers: {"Authorization": "Bearer ${Global.token}"},
      );
    } else {
      imageWidget = Container(
          color: const Color(0xB8B7B7FF),
          child: const Center(
              child: Text(
            "暂无图片",
            style: TextStyle(color: Colors.white),
          )));
    }
    return GestureDetector(
        onTap: () {
          BooksPageState.booksState.setBooks(data, index);
          context.go("/books/info");
        },
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(aspectRatio: 9 / 13, child: imageWidget),
                if (show)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: IconButton(
                        onPressed: () {
                          BooksPageState.booksState.setBooks(data, index);
                          BooksState.showDetails(isPc, context, data, 0);
                        },
                        icon: const Icon(Icons.edit)),
                  ),
                if (data.readNum > 0)
                  Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 3, horizontal: 10),
                        color: Theme.of(context).primaryColor,
                        child: Text(
                          "${data.readNum}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      )),
              ],
            ),
            Text(data.name, maxLines: 1),
          ],
        ));
  }
}