import 'package:flutter/material.dart';
import 'package:resourcemanager/main.dart';
import 'package:resourcemanager/routes/books/BooksDetails.dart';
import 'package:resourcemanager/widgets/ToolBar.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<StatefulWidget> createState() => BooksPageState();
}

class BooksPageState extends State<BooksPage> {
  void showDetails(bool isPc) {
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
                    showDetails(constraints.maxWidth > MyApp.width);
                  }, icon: const Icon(Icons.add_circle_outline)),
            ),
          Expanded(
              child: GridView.builder(
                  itemCount: 20,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: constraints.maxWidth / num,
                      childAspectRatio: 9 / 13),
                  itemBuilder: (context, index) {
                    return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GestureDetector(
                          onTap: () =>
                              showDetails(constraints.maxWidth > MyApp.width),
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
                          ),
                        ));
                  }))
        ],
      );
    });
  }
}
