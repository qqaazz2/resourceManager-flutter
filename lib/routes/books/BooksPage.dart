import 'package:flutter/material.dart';
import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/main.dart';
import 'package:resourcemanager/models/BaseResult.dart';
import 'package:resourcemanager/models/GetBooksList.dart';
import 'package:resourcemanager/routes/books/BooksDetails.dart';
import 'package:resourcemanager/widgets/ToolBar.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<StatefulWidget> createState() => BooksPageState();
}

class BooksPageState extends State<BooksPage> {
  List list = [];
  int count = 0;
  int listNum = 0;
  int page = 0;
  int size = 10;

  @override
  void initState() {
    super.initState();
    getList();
  }

  static void showDetails(bool isPc, BuildContext context, int booksID) {
    if (isPc) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return const Dialog(child: BooksDetails());
          });
    } else {
      showModalBottomSheet<int>(
        context: context,
        builder: (BuildContext context) {
          return const BooksDetails();
        },
      );
    }
  }

  void getList() async {
    BaseResult baseResult = await HttpApi.request(
        "/books/getList", (json) => GetBooksList.fromJson(json),
        params: {
          "page": page,
          "size": size,
        });

    if (baseResult.code == "2000") {
      list.addAll(baseResult.result!.data);
      listNum += list.length;
      count = baseResult.result!.count;
    }
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
      return Column(
        children: [
          if (constraints.maxWidth > MyApp.width)
            ToolBar(
              addButton: IconButton(
                  onPressed: () {
                    showDetails(constraints.maxWidth > MyApp.width, context, 0);
                  },
                  icon: const Icon(Icons.add_circle_outline)),
            ),
          Expanded(
              child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (listNum < count &&
                  notification.metrics.atEdge &&
                  notification.metrics.pixels ==
                      notification.metrics.maxScrollExtent) {
                page++;
                getList();
              }
              return false;
            },
            child: GridView.builder(
                itemCount: count,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: constraints.maxWidth / num,
                    childAspectRatio: 9 / 13),
                itemBuilder: (context, index) {
                  return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: constraints.maxWidth > MyApp.width
                          ? PCItem(data: list[index])
                          : MobileItem(data: list[index]));
                }),
          ))
        ],
      );
    });
  }
}

class MobileItem extends StatelessWidget {
  const MobileItem({super.key, required this.data});

  final Data data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        // onLongPress: () => BooksPageState.showDetails(false, context,),
        child: BooksItem(data: data,isPc: false,));
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
  const BooksItem({super.key, required this.data, this.show = false,this.isPc = true});

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
            child: IconButton(onPressed: () {
              BooksPageState.showDetails(isPc, context, data.id);
            }, icon: const Icon(Icons.edit)),
          ),
        Positioned(bottom: 0, child: Text(data.name))
      ],
    );
  }
}
