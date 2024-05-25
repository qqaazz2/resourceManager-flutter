import 'package:flutter/material.dart';
import 'package:resourcemanager/widgets/KeepActivePage.dart';

import 'BooksForm.dart';

class BooksDetails extends StatefulWidget {
  const BooksDetails({super.key, this.booksID = 0, this.bookID = 0});

  final int booksID;
  final int bookID;

  @override
  State<BooksDetails> createState() => BooksDetailsState();
}

class BooksDetailsState extends State<BooksDetails> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    List<String> tabs = ["系列信息"];
    if (widget.booksID != 0) {
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
                  padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                  child: TabBarView(
                    children: tabs.map((e) {
                      if (e == "系列信息") {
                        return KeepActivePage(
                            widget: BooksForm(booksID: widget.booksID));
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
