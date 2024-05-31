import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/main.dart';
import 'package:resourcemanager/models/BaseResult.dart';
import 'package:resourcemanager/models/GetBooksList.dart';
import 'package:resourcemanager/routes/books/BooksDetails.dart';
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
    booksState = Provider.of<BooksState>(MyApp.rootNavigatorKey.currentContext!);
    booksState.getList(size);
  }

  static void showDetails(bool isPc, BuildContext context, Data? books) {
    if (isPc) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
                child: BooksDetails(
              books: books,
            ));
          });
    } else {
      showModalBottomSheet<int>(
        context: context,
        builder: (BuildContext context) {
          return BooksDetails(
            books: books,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return  LayoutBuilder(builder: (context, constraints) {
      int num = 10;
      if (1300 > constraints.maxWidth && constraints.maxWidth > 600) {
        num = 4;
      } else if (constraints.maxWidth < MyApp.width) {
        num = 2;
      }
      return Consumer<BooksState>(builder: (context, value, child) {
        print(value.count);
        return Column(
          children: [
            if (constraints.maxWidth > MyApp.width)
              ToolBar(
                addButton: IconButton(
                    onPressed: () {
                      showDetails(
                          constraints.maxWidth > MyApp.width, context, null);
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
                    return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: constraints.maxWidth > MyApp.width
                            ? PCItem(data: value.booksList[index])
                            : MobileItem(data: value.booksList[index]));
                  }),
            ))
          ],
        );
      });
    });
  }
}

class MobileItem extends StatefulWidget {
  const MobileItem({super.key, required this.data});

  final Data data;

  @override
  State<StatefulWidget> createState() => MobileItemState();
}

class MobileItemState extends State<MobileItem> {
  bool show = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: BooksItem(
      data: widget.data,
      isPc: false,
      show: true,
    ));
  }
}

class PCItem extends StatelessWidget {
  PCItem({super.key, required this.data});

  final Data data;
  final ValueNotifier<bool> show = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        show.value = true;
      },
      onExit: (event) {
        show.value = false;
      },
      child: ValueListenableBuilder<bool>(
        builder: (BuildContext context, bool value, Widget? child) {
          return BooksItem(data: data, show: value);
        },
        valueListenable: show,
      ),
      // child: BooksItem(data: data,show: show),
    );
  }
}

class BooksItem extends StatelessWidget {
  const BooksItem(
      {super.key, required this.data, this.show = false, this.isPc = true});

  final Data data;
  final bool show;
  final bool isPc;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: 9 / 13,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
          ),
        ),
        if (show)
          Positioned(
            right: 0,
            bottom: 20,
            child: IconButton(
                onPressed: () {
                  BooksPageState.booksState.setBooks(data);
                  BooksPageState.showDetails(isPc, context, data);
                },
                icon: const Icon(Icons.edit)),
          ),
        Positioned(bottom: 0, child: Text(data.name))
      ],
    );
  }
}
