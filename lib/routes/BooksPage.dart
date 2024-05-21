import 'package:flutter/material.dart';
import 'package:resourcemanager/main.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<StatefulWidget> createState() => BooksPageState();
}

class BooksPageState extends State<BooksPage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      int num = 10;
      if (1300 > constraints.maxWidth && constraints.maxWidth > 600) {
        num = 4;
      } else if (constraints.maxWidth < MyApp.width) {
        num = 2;
      }
      return GridView.builder(
          itemCount: 20,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: constraints.maxWidth / num,
              childAspectRatio: 9 / 13),
          itemBuilder: (context, index) {
            return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 9 / 13,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.black87,
                      ),
                    ),
                    Positioned(
                        bottom: 0,
                        child: Text(
                          "$index",
                        ))
                  ],
                ));
          });
    });
  }
}
