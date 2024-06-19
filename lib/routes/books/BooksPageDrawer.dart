import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resourcemanager/main.dart';
import 'package:resourcemanager/state/BooksState.dart';

class BooksPageDrawer extends StatefulWidget {
  const BooksPageDrawer({super.key});

  @override
  State<StatefulWidget> createState() => BooksPageDrawerState();
}

class BooksPageDrawerState extends State<BooksPageDrawer> {
  late int status;
  late bool sortStatus;
  late int sort;
  late BooksState booksState;
  IconData iconData = Icons.keyboard_arrow_down;

  @override
  void initState() {
    super.initState();
    booksState = Provider.of<BooksState>(MyApp.rootNavigatorKey.currentContext!,
        listen: false);
    status = booksState.status;
    sort = booksState.sort;
    sortStatus = booksState.sortStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      child: Stack(
        children: [
          SingleChildScrollView(
              child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("筛选项",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w400)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("系列状态："),
                    Expanded(
                        child: StatefulBuilder(builder: (context, _setState) {
                      return DropdownButton<int>(
                        value: status,
                        underline: Container(height: 0),
                        items: const [
                          DropdownMenuItem(
                            value: 1,
                            child: Text('连载中'),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text('已完结'),
                          ),
                          DropdownMenuItem(
                            value: 3,
                            child: Text('弃坑'),
                          )
                        ],
                        onChanged: (int? value) {
                          _setState(() {
                            status = value!;
                          });
                        },
                      );
                    }))
                  ],
                ),
                const Divider(),
                Text("排序方式",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w400)),
                Row(
                  children: [
                    const Text("系列排序："),
                    Expanded(
                        child: StatefulBuilder(builder: (context, _setState) {
                      return DropdownButton<int>(
                        value: sort,
                        underline: Container(height: 0),
                        items: const [
                          DropdownMenuItem(
                            value: 1,
                            child: Text('ID'),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text('新增时间'),
                          ),
                          DropdownMenuItem(
                            value: 3,
                            child: Text('编辑时间'),
                          ),
                          DropdownMenuItem(
                            value: 4,
                            child: Text('最后一次阅读时间'),
                          )
                        ],
                        onChanged: (int? value) {
                          _setState(() {
                            sort = value!;
                          });
                        },
                      );
                    })),
                    StatefulBuilder(builder: (context, _setState) {
                      return GestureDetector(
                        child: Icon(iconData),
                        onTap: () {
                          _setState(() {
                            sortStatus = !sortStatus;
                            iconData = sortStatus
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up;
                          });
                        },
                      );
                    })
                  ],
                )
              ],
            ),
          )),
          Positioned(
              width: 300,
              bottom: 10,
              left: 0,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        status = 1;
                        sortStatus = true;
                        sort = 1;
                        setState(() {});
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(Colors.grey.shade400),
                          foregroundColor:
                              WidgetStateProperty.all(Colors.white)),
                      child: const Text("重置选项")),
                  ElevatedButton(
                    onPressed: () {
                      booksState.initList();
                      booksState.getList(10,
                          sortFiled: sort, sort: sortStatus ? "ASC" : "DESC");
                      MyApp.scaffoldKey.currentState!.closeEndDrawer();
                      booksState.changeDrawer(status, sort, sortStatus);
                    },
                    child: const Text("搜索"),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
