import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resourcemanager/entity/comic/ComicItem.dart';
import 'package:resourcemanager/routes/comic/widgets/ComicItems.dart';
import 'package:resourcemanager/state/comic/ComicListState.dart';
import 'package:resourcemanager/state/comic/ComicSetListState.dart';
import 'package:resourcemanager/widgets/ListWidget.dart';

class ComicList extends ConsumerStatefulWidget {
  const ComicList({super.key, required this.filesId});

  final int filesId;

  @override
  ConsumerState<ComicList> createState() => ComicListState();
}

class ComicListState extends ConsumerState<ComicList> {
  @override
  void initState() {
    super.initState();
    ref.read(comicListStateProvider.notifier).getList(widget.filesId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(comicListStateProvider);
    return Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: ListWidget<ComicItem>(
            count: state.count,
            list: state.data!,
            widget: (ComicItem data, index, {show = false, isPc = true}) {
              return ComicItems(
                data: data,
                index: index,
                show: show,
                isPc: isPc,
              );
            },
            scale: .7,
            getList: () =>
                ref.read(comicListStateProvider.notifier).getList(widget.filesId)));
  }
}
