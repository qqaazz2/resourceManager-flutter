import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resourcemanager/entity/comic/ComicSetItem.dart';
import 'package:resourcemanager/main.dart';
import 'package:resourcemanager/state/comic/ComicSetListState.dart';
import 'package:resourcemanager/widgets/ListWidget.dart';
import 'package:resourcemanager/widgets/ToolBar.dart';
import 'package:resourcemanager/widgets/TopTool.dart';

import 'ComicSetItems.dart';

class ComicSetPage extends ConsumerStatefulWidget{
  const ComicSetPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => ComicSetPageState();
}

class ComicSetPageState extends ConsumerState<ComicSetPage>{
  @override
  void initState() {
    super.initState();
    ref.read(comicSetListStateProvider.notifier).getList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(comicSetListStateProvider);
    return TopTool(floatingActionButton: Builder(builder: (context) {
      return FloatingActionButton(
        onPressed: () {
          Scaffold.of(context).openEndDrawer();
        },
        child: const Icon(Icons.list),
      );
    }), title: "漫画",
        child: LayoutBuilder(builder: (context, constraints) {
          return Column(
            children: [
              if (constraints.maxWidth > MyApp.width) ToolBar(widgetList: [
                IconButton(onPressed: (){
                  ref.read(comicSetListStateProvider.notifier).reload();
                }, icon: const Icon(Icons.refresh)),
                IconButton(onPressed: (){
                  ref.read(comicSetListStateProvider.notifier).scanning();
                }, icon: const Icon(Icons.featured_play_list_sharp))
              ]),
              Expanded(
                  child: ListWidget<ComicSetItem>(
                      list: state.data!,
                      count: state.count,
                      scale: .7,
                      widget: (ComicSetItem data, index,
                          {show = false, isPc = true}) {
                        return ComicSetItems(
                          data: data,
                          index: index,
                          show: show,
                          isPc: isPc,
                        );
                      },
                      getList: () =>
                          ref.read(comicSetListStateProvider.notifier).getList())),
            ],
          );
        }));
  }
}