import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resourcemanager/common/Global.dart';
import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/models/GetBooksDetailsList.dart';
import 'package:resourcemanager/models/GetBooksList.dart';
import 'package:resourcemanager/routes/books/BooksPage.dart';
import 'package:resourcemanager/state/BooksState.dart';

import '../../../main.dart';
import '../../../widgets/ToolBar.dart';

class BooksInfo extends StatefulWidget {
  const BooksInfo({super.key});

  @override
  State<StatefulWidget> createState() => BooksInfoState();
}

class BooksInfoState extends State<BooksInfo> {
  late BooksState booksState;
  late Data books;
  int page = 0;
  int count = 0;
  late List<Details> list;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    booksState = Provider.of<BooksState>(MyApp.rootNavigatorKey.currentContext!,
        listen: false);
    booksState.getDetailsList();
  }

  @override
  Widget build(BuildContext context) {
    Map<int, String> status = {
      1: "连载中",
      2: "已完结",
      3: "弃坑",
    };

    booksState = Provider.of<BooksState>(context);
    books = booksState.books;

    return LayoutBuilder(builder: (context, constraints) {
      int num = 0;
      if (constraints.maxWidth > 1300) {
        num = 10;
      } else if (1300 > constraints.maxWidth &&
          constraints.maxWidth > MyApp.width) {
        num = 6;
      } else {
        num = 3;
      }

      return Column(
        children: [
          if (constraints.maxWidth > MyApp.width)
            ToolBar(
              addButton: IconButton(
                  onPressed: () {
                    BooksState.showDetails(
                        constraints.maxWidth > MyApp.width, context, books, 0);
                  },
                  icon: const Icon(Icons.edit_note_sharp)),
            ),
          Expanded(
              child: Center(
            child: Container(
              width: 1920,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Text(
                        "系列信息",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).primaryColor),
                      )),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            right:
                                MyApp.width < constraints.maxWidth ? 50 : 30),
                        child: Image.network(
                          "${HttpApi.options.baseUrl}files/${books.cover}",
                          headers: {"Authorization": "Bearer ${Global.token}"},
                          fit: BoxFit.cover,
                          width: MyApp.width < constraints.maxWidth ? 180 : 120,
                          height:
                              MyApp.width < constraints.maxWidth ? 260 : 200,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(books.name,
                                maxLines: 3,
                                style: const TextStyle(
                                    fontSize: 23, fontWeight: FontWeight.w600)),
                            Text("作者：${books.author}"),
                            Text("插画家：${books.illustrator}"),
                            Text("书籍数量：${books.count}"),
                            Text("已读书籍：${books.count - books.readNum}"),
                            Text("系列状态：${status[books.status]}"),
                            const Text("最后一次阅读时间"),
                            Text(books.lastRead ?? "暂未阅读")
                          ],
                        ),
                      )
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Text(
                        "书籍列表",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).primaryColor),
                      )),
                  Expanded(
                      child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (booksState.detailsList.length <
                              booksState.detailsCount &&
                          notification.metrics.atEdge &&
                          notification.metrics.pixels ==
                              notification.metrics.maxScrollExtent &&
                          !booksState.isLoading) {
                        booksState.isLoading = true;
                        booksState.getDetailsList();
                      }
                      return false;
                    },
                    child: GridView.builder(
                        itemCount: booksState.detailsList.length,
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: constraints.maxWidth / num,
                            childAspectRatio: 9 / 13),
                        itemBuilder: (context, index) {
                          Details details = booksState.detailsList[index];
                          print(details.name);
                          print(details.progress);
                          return GestureDetector(
                            onTap: () {
                              booksState.setDetails(details, index);
                              context.push("/books/read");
                            },
                            child: Column(children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Stack(
                                  children: [
                                    Image.network(
                                        "${HttpApi.options.baseUrl}files/${details.cover}",
                                        headers: {
                                          "Authorization":
                                              "Bearer ${Global.token}"
                                        }),
                                    Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: IconButton(
                                            iconSize: 17,
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              booksState.setDetails(details, index);
                                              BooksState.showDetails(
                                                  constraints.maxWidth >
                                                      MyApp.width,
                                                  context,
                                                  books,
                                                  details.id);
                                            })),
                                    if (details.status == 1)
                                      Positioned(
                                          left: -20,
                                          top: -20,
                                          child: ClipOval(
                                            child: Container(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              width: 40,
                                              height: 40,
                                            ),
                                          )),
                                    if (details.status == 3)
                                      Positioned(
                                          child: LinearProgressIndicator(
                                        value: details.progress,
                                      ))
                                  ],
                                ),
                              ),
                              Text(
                                details.name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                              ),
                            ]),
                          );
                        }),
                  ))
                ],
              ),
            ),
          ))
        ],
      );
    });
  }
}
