import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resourcemanager/common/Global.dart';
import 'package:resourcemanager/main.dart';

class LeftDrawer extends StatefulWidget {
  LeftDrawer({super.key, this.width = 300});

  final double width;

  @override
  State<StatefulWidget> createState() => LeftDrawerState();
}

class LeftDrawerState extends State<LeftDrawer> {
  int index = 0;
  late double width;
  late String current;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    width = MediaQuery.of(context).size.width;
    current = GoRouter.of(context).routerDelegate.currentConfiguration.last.route.path;
  }

  void jump(String path) {
    print(path);
    if (current != path) {
      GoRouter.of(context).go(path);
    } else if (width <= MyApp.width) {
      GoRouter.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Drawer(
        width: widget.width,
        child: Container(
          width: double.infinity,
          padding: width < MyApp.width
              ? const EdgeInsets.only(top: 20, left: 20)
              : const EdgeInsets.only(top: 40, left: 0),
          child: Column(
            children: [
              Container(
                  width: double.infinity,
                  padding: width < MyApp.width ? EdgeInsets.zero : const EdgeInsets.only(left: 20),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: const Text(
                    "Resource Manager",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 20),
                  )),
              Expanded(
                  child: ListView.builder(
                itemBuilder: (content, index) {
                  Item item = Global.itemList[index];
                  return Padding(
                      padding:width < MyApp.width ? EdgeInsets.zero : const EdgeInsets.only(bottom: 20),
                      child: ListTile(
                        leading: item.icon,
                        title: Text(item.title),
                        onTap: () => jump(item.path),
                        selected: item.path == GoRouter.of(context).routerDelegate.currentConfiguration.last.route.path,
                        hoverColor: Colors.grey,
                      ));
                },
                itemCount: Global.itemList.length,
              ))
            ],
          ),
        ));
  }
}

class Item {
  String title;
  String path;
  Icon icon;

  Item({required this.title, required this.path, required this.icon});
}

// class Item extends StatelessWidget{
//   @override
//   Widget build(BuildContext context) {
//     return Row()
//   }
// }
