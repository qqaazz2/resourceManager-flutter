import 'package:flutter/material.dart';
import 'package:resourcemanager/main.dart';

class BooksDetails extends StatefulWidget {
  const BooksDetails({super.key});

  @override
  State<StatefulWidget> createState() => BooksDetailsState();
}

class BooksDetailsState extends State {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    List tabs = ["系列信息", "书籍列表", "书籍详情"];
    return Container(
      width: screenWidth > MyApp.width ? screenWidth * 0.6 : screenWidth,
      height: screenWidth > MyApp.width ? screenHeight * 0.6 : screenHeight,
      child: DefaultTabController(
          length: tabs.length,
          child: TabBarView(
            children: tabs.map((e) {
              return Text(e);
            }).toList(),
          )),
    );
  }
}
