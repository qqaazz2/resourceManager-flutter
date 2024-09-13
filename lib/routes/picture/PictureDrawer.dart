import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resourcemanager/main.dart';
import 'package:resourcemanager/state/picture/PictureListState.dart';

class PictureDrawer extends StatefulWidget {
  const PictureDrawer({super.key,this.id});
  final String? id;
  @override
  State<StatefulWidget> createState() => PictureDrawerState();
}

class PictureDrawerState extends State<PictureDrawer> {
  late PictureListState pictureListState;

  @override
  void initState() {
    super.initState();
    pictureListState =
        Provider.of<PictureListState>(MyApp.rootNavigatorKey.currentContext!,listen: false);
  }

  Map<int, String> map = {1: "未展示", 2: "已展示", 3: "永不展示"};

  List<DropdownMenuEntry> _buildMenuList() {
    List<DropdownMenuEntry> list = [];
    list.add(const DropdownMenuEntry(value: null, label: "全部"));
    map.forEach((v, k) {
      list.add(DropdownMenuEntry(value: v, label: k));
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.shuffle),
                title: const Text("随机图片"),
                onTap: () async{
                  await pictureListState.randomData();
                  final result =
                      await GoRouter.of(context).push("/picture/details");
                },
              ),
              ListTile(
                leading: const Icon(Icons.adf_scanner),
                title: const Text("扫描图片"),
                onTap: () => pictureListState.scanning(widget.id),
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text("按文件夹查询"),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.timeline),
                title: const Text("按时间线查询"),
                onTap: () {},
              ),
              const Divider(),
              const Text(
                "条件筛选",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              ListTile(
                  titleAlignment: ListTileTitleAlignment.titleHeight,
                  leading: const Icon(Icons.dashboard),
                  title: const Text("每日随机"),
                  subtitle: DropdownMenu(
                    width: 220,
                    dropdownMenuEntries: _buildMenuList(),
                    // initialSelection: pictureData.display,
                    // onSelected: (value) => pictureListState.setDisplay(
                    //     pictureListState.current, value),
                  )),
              ListTile(
                  titleAlignment: ListTileTitleAlignment.titleHeight,
                  leading: const Icon(Icons.star),
                  title: const Text("是否收藏"),
                  subtitle: DropdownMenu(
                    width: 220,
                    dropdownMenuEntries: [
                      DropdownMenuEntry(value: null, label: "全部"),
                      DropdownMenuEntry(value: 1, label: "收藏"),
                      DropdownMenuEntry(value: 2, label: "未收藏"),
                    ],
                    // initialSelection: pictureData.display,
                    // onSelected: (value) => pictureListState.setDisplay(
                    //     pictureListState.current, value),
                  )),
            ],
          ),
        ),
      ),
    ));
  }
}
