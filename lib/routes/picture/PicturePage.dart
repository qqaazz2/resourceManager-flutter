import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/main.dart';
import 'package:resourcemanager/models/BaseResult.dart';
import 'package:resourcemanager/models/picture/PictureList.dart';
import 'package:resourcemanager/routes/picture/PictureDrawer.dart';
import 'package:resourcemanager/routes/picture/PictureItem.dart';
import 'package:resourcemanager/state/picture/PictureListState.dart';
import 'package:resourcemanager/widgets/ListWidget.dart';
import 'package:resourcemanager/widgets/ToolBar.dart';
import 'package:resourcemanager/widgets/TopTool.dart';

class PicturePage extends StatefulWidget {
  const PicturePage({super.key, required this.id});

  final String? id;

  @override
  State<StatefulWidget> createState() => PicturePageState();
}

class PicturePageState extends State<PicturePage> {
  @override
  void initState() {
    super.initState();
    setData();
  }

  late PictureListState pageListState;

  void setData() {
    pageListState = Provider.of<PictureListState>(
        MyApp.rootNavigatorKey.currentContext!,
        listen: false);
    pageListState.getList(widget.id);
  }

  //
  // @override
  // void didUpdateWidget(covariant PicturePage oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   print(oldWidget.id);
  //   print(widget.id);
  //   print("oldWidget.id != widget.id${oldWidget.id != widget.id}");
  //   if (oldWidget.id != widget.id) setData();
  // }

  @override
  Widget build(BuildContext context) {
    return TopTool(
      title: "图片",
      endDrawer: PictureDrawer(id: widget.id),
      floatingActionButton: Builder(builder: (context) {
        return FloatingActionButton(
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
          },
          child: const Icon(Icons.list),
        );
      }),
      child: LayoutBuilder(builder: (context, constraints) {
        return Column(
          children: [
            if (constraints.maxWidth > MyApp.width)
              ToolBar(
                widgetList: [
                  ElevatedButton(
                      onPressed: () async {
                        await pageListState.randomData();
                        final result =
                            await GoRouter.of(context).push("/picture/details");
                        setData();
                      },
                      child: const Text("随机十张图片"))
                ],
                addButton: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.add_circle_outline)),
              ),
            Consumer<PictureListState>(builder: (context, value, child) {
              return Expanded(
                  child: ListWidget<PictureData>(
                      list: value.list,
                      count: value.count,
                      scale: 1,
                      widget: (PictureData data, index,
                          {show = false, isPc = true}) {
                        return PictureItem(
                          data: data,
                          index: index,
                          show: show,
                          isPc: isPc,
                        );
                      },
                      getList: () => value.getList(widget.id)));
            })
          ],
        );
      }),
    );
  }
}
