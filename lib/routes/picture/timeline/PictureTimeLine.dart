import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resourcemanager/main.dart';
import 'package:resourcemanager/widgets/ToolBar.dart';
import 'package:resourcemanager/widgets/TopTool.dart';

class PictureTimeLine extends ConsumerStatefulWidget{
  const PictureTimeLine({super.key});

  @override
  ConsumerState<PictureTimeLine> createState() => PictureTimeLineState();
}

class PictureTimeLineState extends ConsumerState<PictureTimeLine>{
  @override
  Widget build(BuildContext context) {
    return TopTool(
      title: "图片",
      // endDrawer: PictureDrawer(id: widget.id),
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
              widgetList: [
                  IconButton(
                    onPressed: () => GoRouter.of(context).push("/picture/random"),
                    icon: const Icon(Icons.shuffle_sharp),
                    tooltip: "随机十张图片",
                  ),
                IconButton(
                  onPressed: () => context.go("/picture"),
                  icon: const Icon(Icons.folder),
                  tooltip: "切换为文件夹",
                ),
                IconButton(
                    onPressed: () {
                    },
                    icon: const Icon(Icons.refresh),
                    tooltip: "刷新"),
                IconButton(
                    onPressed: () {
                    },
                    icon: const Icon(Icons.featured_play_list_sharp),
                    tooltip: "扫描图片文件夹"),
              ],
            ),
        ],
      ),
    );
  }
}