import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resourcemanager/models/GetBooksList.dart';
import 'package:resourcemanager/state/BooksState.dart';
import 'package:resourcemanager/widgets/KeepActivePage.dart';

import 'BooksForm.dart';
import 'BooksList.dart';

class BooksDetails extends StatefulWidget {
  const BooksDetails({super.key, this.books, this.bookID = 0});

  final Data? books;
  final int bookID;

  @override
  State<BooksDetails> createState() => BooksDetailsState();
}

class BooksDetailsState extends State<BooksDetails> {
  static late BooksState booksState;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    booksState = Provider.of<BooksState>(context);
    List<String> tabs = ["系列信息"];
    if (widget.books != null) {
      tabs.add("书籍列表");
    } else if (widget.bookID != 0) {
      tabs.add("书籍详情");
    }

    return SizedBox(
      width: screenWidth > 600 ? screenWidth * 0.6 : screenWidth * 0.9,
      height: 400,
      child: DefaultTabController(
          length: tabs.length,
          child: Column(
            children: [
              TabBar(
                tabs: tabs.map((e) => Tab(text: e)).toList(),
              ),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: TabBarView(
                    children: tabs.map((e) {
                      if (e == "系列信息") {
                        return const KeepActivePage(widget: BooksForm());
                      } else if (e == "书籍列表") {
                        return const KeepActivePage(widget: BooksList());
                      }
                      return KeepActivePage(widget: Text(e));
                    }).toList(),
                  ),
                ),
              )
            ],
          )),
    );
  }
}
