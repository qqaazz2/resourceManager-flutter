import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resourcemanager/main.dart';
import 'package:resourcemanager/models/GetBooksDetailsList.dart';
import 'package:resourcemanager/models/GetBooksList.dart';
import 'package:resourcemanager/state/BooksState.dart';
import 'package:resourcemanager/widgets/KeepActivePage.dart';

import '../../common/Global.dart';
import '../../common/HttpApi.dart';
import '../../models/BaseResult.dart';

class BooksList extends StatefulWidget {
  const BooksList({super.key});

  @override
  State<StatefulWidget> createState() => BooksListState();
}

class BooksListState extends State<BooksList> {
  late Data books;
  late List<Details> list;
  static List<Details> selectList = [];
  int count = 0;

  void upload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['epub']);
    if (result!.count > 0) {
      List<MultipartFile> files = [];
      for (PlatformFile platformFile in result.files) {
        List<int> fileBytes = platformFile.bytes!;
        MultipartFile file = MultipartFile.fromBytes(
          fileBytes,
          filename: platformFile.name, // 文件名
        );
        files.add(file);
      }

      FormData formData = FormData.fromMap({
        'files': files,
        'name': books.name,
        'id': books.id,
      });
      BaseResult baseResult = await HttpApi.request(
          "/booksDetails/upload", (json) => {},
          method: "post", formData: formData);
      if (baseResult.code == "2000") {
        books.count += 1;
        books.readNum++;
        booksState.initDetails();
        booksState.getDetailsList();
      }
    }
  }

  static BooksState booksState =
      Provider.of<BooksState>(MyApp.rootNavigatorKey.currentContext!);

  @override
  void initState() {
    super.initState();
    booksState = Provider.of<BooksState>(MyApp.rootNavigatorKey.currentContext!,
        listen: false);
    booksState.initDetails();
    booksState.getDetailsList();
    books = booksState.books;
  }

  static Future showDeleteDialog(context) {
    bool type = false;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("删除书籍"),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text("你确定删除这些书籍吗？"),
                ),
                Row(
                  children: [
                    StatefulBuilder(builder: (context, setState) {
                      return Checkbox(
                          value: type,
                          onChanged: (value) {
                            setState(() => type = value!);
                          });
                    }),
                    const Text("是否删除书籍文件")
                  ],
                )
              ],
            ),
            actions: [
              TextButton(
                child: const Text("取消"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text("删除"),
                onPressed: () async {
                  BaseResult baseResult = await HttpApi.request(
                      "/booksDetails/delete", (json) => {},
                      params: {
                        "ids": selectList.map((e) => e.id).toList(),
                        "bookID":booksState.books.id,
                        "delFile": type,
                      });
                  if (baseResult.code == "2000") {
                    booksState.deleteDetails(selectList);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    booksState = Provider.of<BooksState>(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Text.rich(TextSpan(children: [
              const TextSpan(text: "该系列图书有(册)："),
              TextSpan(text: "${books.count}")
            ]))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: OutlinedButton.icon(
                onPressed: () => showDeleteDialog(context),
                label: const Text("批量删除"),
                icon: const Icon(Icons.delete_forever),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => upload(),
              label: const Text("上传书籍"),
              icon: const Icon(Icons.add_link),
            ),
          ],
        ),
        Expanded(
            child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (booksState.detailsList.length < booksState.detailsCount &&
                notification.metrics.atEdge &&
                notification.metrics.pixels ==
                    notification.metrics.maxScrollExtent &&
                !booksState.isLoading) {
              booksState.isLoading = true;
              booksState.getDetailsList();
            }
            return false;
          },
          child: ListView.builder(
            itemBuilder: (buildContext, index) {
              return KeepActivePage(
                  widget: Item(details: booksState.detailsList[index]));
            },
            itemCount: booksState.detailsList.length,
          ),
        ))
      ],
    );
  }
}

class Item extends StatefulWidget {
  const Item({super.key, required this.details});

  final Details details;

  @override
  State<StatefulWidget> createState() => ItemState();
}

class ItemState extends State<Item> {
  @override
  Widget build(BuildContext context) {
    String path = "${HttpApi.options.baseUrl}files/${widget.details.cover}";
    bool check = false;
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Theme.of(context).primaryColor))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StatefulBuilder(builder: (context, _setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Checkbox(
                  value: check,
                  onChanged: (value) {
                    if (value!) {
                      BooksListState.selectList.add(widget.details);
                    } else {
                      if (BooksListState.selectList.contains(widget.details)) {
                        BooksListState.selectList.remove(widget.details);
                      }
                    }
                    _setState(() {
                      check = value;
                    });
                  }),
            );
          }),
          Image.network(
            path,
            headers: {"Authorization": "Bearer ${Global.token}"},
            width: 90,
            height: 130,
            fit: BoxFit.cover,
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(widget.details.name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
          )),
          IconButton(
              onPressed: () {
                BooksListState.selectList = [widget.details];
                BooksListState.showDeleteDialog(context);
              },
              icon: const Icon(Icons.delete))
        ],
      ),
    );
  }
}
