import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/main.dart';
import 'package:resourcemanager/entity/BaseResult.dart';
import 'package:resourcemanager/models/picture/PictureList.dart';
import 'package:resourcemanager/routes/picture/PictureDrawer.dart';
import 'package:resourcemanager/routes/picture/PictureItem.dart';
import 'package:resourcemanager/state/picture/PictureListState.dart';
import 'package:resourcemanager/state/picture/PictureState.dart';
import 'package:resourcemanager/widgets/ListWidget.dart';
import 'package:resourcemanager/widgets/ToolBar.dart';
import 'package:resourcemanager/widgets/TopTool.dart';

class PicturePage extends ConsumerStatefulWidget {
  const PicturePage({super.key, required this.id});

  final String? id;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => PicturePageState();
}

class PicturePageState extends ConsumerState<PicturePage> {
  @override
  void initState() {
    super.initState();
    ref.read(pictureStateProvider(widget.id).notifier).getList(widget.id);
  }

  // void setData() {
  //   pageListState.getList(widget.id);
  // }

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
    final pictureState = ref.watch(pictureStateProvider(widget.id));
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
      child: Column(
        children: [
          if (MediaQuery.of(context).size.width > MyApp.width)
            ToolBar(
              showBack: (widget.id != null && widget.id != "-1"),
              widgetList: [
                if (widget.id == "-1")
                  IconButton(
                    onPressed: () =>
                        GoRouter.of(context).push("/picture/random"),
                    icon: const Icon(Icons.shuffle_sharp),
                    tooltip: "随机十张图片",
                  ),
                IconButton(
                  onPressed: () => context.go("/picture/timeline"),
                  icon: const Icon(Icons.timeline),
                  tooltip: "切换为时间线",
                ),
                if (widget.id != null && widget.id != "-1")
                  IconButton(
                      onPressed: () => context.go("/picture"),
                      icon: const Icon(Icons.home),
                      tooltip: "回到主文件夹"),
                IconButton(
                    onPressed: () {
                      ref
                          .read(pictureStateProvider(widget.id).notifier)
                          .reload(widget.id);
                    },
                    icon: const Icon(Icons.refresh),
                    tooltip: "刷新"),
                IconButton(
                    onPressed: () {
                      ref
                          .read(pictureStateProvider(widget.id).notifier)
                          .scanning(widget.id);
                    },
                    icon: const Icon(Icons.featured_play_list_sharp),
                    tooltip: "扫描图片文件夹"),
              ],
            ),
          Expanded(
              child: ListWidget<PictureData>(
                  list: pictureState.list,
                  count: pictureState.count,
                  scale: 1,
                  widget: (PictureData data, index,
                      {show = false, isPc = true}) {
                    return PictureItem(
                      id: widget.id,
                      data: data,
                      index: index,
                      show: show,
                      isPc: isPc,
                    );
                  },
                  getList: () => ref
                      .read(pictureStateProvider(widget.id).notifier)
                      .getList(widget.id))),
        ],
      ),
    );
  }
}
