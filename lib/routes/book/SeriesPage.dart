import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resourcemanager/entity/book/SeriesItem.dart';
import 'package:resourcemanager/main.dart';
import 'package:resourcemanager/routes/book/widgets/SeriesItems.dart';
import 'package:resourcemanager/state/book/SeriesListState.dart';
import 'package:resourcemanager/widgets/ListWidget.dart';
import 'package:resourcemanager/widgets/ToolBar.dart';
import 'package:resourcemanager/widgets/TopTool.dart';

class SeriesPage extends ConsumerStatefulWidget {
  const SeriesPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => SeriesPageState();
}

class SeriesPageState extends ConsumerState<SeriesPage> {
  @override
  void initState() {
    super.initState();
    ref.read(seriesListStateProvider.notifier).getList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(seriesListStateProvider);
    return TopTool(
      title: "图书",
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
            if (constraints.maxWidth > MyApp.width) ToolBar(widgetList: [
              IconButton(onPressed: (){
                ref.read(seriesListStateProvider.notifier).reload();
              }, icon: const Icon(Icons.refresh)),
              IconButton(onPressed: (){
                ref.read(seriesListStateProvider.notifier).scanning();
              }, icon: const Icon(Icons.featured_play_list_sharp))
            ]),
            Expanded(
                child: ListWidget<SeriesItem>(
                    list: state.data,
                    count: state.count,
                    scale: .7,
                    widget: (SeriesItem data, index,
                        {show = false, isPc = true}) {
                      return SeriesItems(
                        data: data,
                        index: index,
                        show: show,
                        isPc: isPc,
                      );
                    },
                    getList: () =>
                        ref.read(seriesListStateProvider.notifier).getList())),
          ],
        );
      }),
    );
  }
}
