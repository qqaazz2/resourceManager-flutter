import 'package:flutter/material.dart';
import 'package:resourcemanager/main.dart';

class ToolBar extends StatefulWidget {
  const ToolBar({super.key, this.addButton, this.isShowList = true});

  final Widget? addButton;
  final bool isShowList;

  @override
  State<StatefulWidget> createState() => ToolBarState();
}

class ToolBarState extends State<ToolBar> {
  @override
  Widget build(BuildContext context) {
    MaterialStatePropertyAll<TextStyle> style =
        const MaterialStatePropertyAll<TextStyle>(TextStyle(fontSize: 14));
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      width: double.infinity,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(),
          SearchBar(
            padding: const MaterialStatePropertyAll<EdgeInsets>(
                EdgeInsets.only(right: 0, left: 5)),
            leading: const Icon(
              Icons.search,
              size: 24,
            ),
            hintText: "请输入搜索内容",
            hintStyle: style,
            trailing: [
              TextButton(
                  onPressed: () {
                    print("search");
                  },
                  child: const Text(
                    "搜索",
                    style: TextStyle(fontSize: 14),
                  ))
            ],
            textStyle: style,
            constraints: const BoxConstraints(
                maxWidth: 400, minWidth: 400, minHeight: 30),
          ),
          Row(
            children: [
              widget.addButton != null ? widget.addButton! : Container(),
              if (widget.isShowList)
                IconButton(
                    icon: const Icon(Icons.list),
                    onPressed: () {
                      MyApp.scaffoldKey.currentState!.openEndDrawer();
                    }),
            ],
          )
        ],
      ),
    );
  }
}
