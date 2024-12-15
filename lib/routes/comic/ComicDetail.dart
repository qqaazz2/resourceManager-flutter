import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resourcemanager/main.dart';
import 'package:resourcemanager/routes/comic/ComicSetForm.dart';
import 'package:resourcemanager/routes/comic/widgets/ComicList.dart';
import 'package:resourcemanager/routes/comic/widgets/ComicSetDetail.dart';
import 'package:resourcemanager/state/comic/ComicSetDetailState.dart';
import 'package:resourcemanager/state/comic/ComicSetListState.dart';
import 'package:resourcemanager/widgets/KeepActivePage.dart';
import 'package:resourcemanager/widgets/ToolBar.dart';
import 'package:resourcemanager/widgets/TopTool.dart';

class ComicDetail extends ConsumerStatefulWidget {
  const ComicDetail(
      {super.key,
      required this.id,
      required this.isFirst,
      required this.filesId});

  final String id;
  final int isFirst;
  final String filesId;

  @override
  ConsumerState<ComicDetail> createState() => ComicDetailState();
}

class ComicDetailState extends ConsumerState<ComicDetail> {
  PageController pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if(MediaQuery.of(context).size.width < MyApp.width){
            if (pageController.page == 0) {
              Navigator.of(context).pop();
            } else {
              pageController.animateToPage(0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease);
              return;
            }
          }else{
            if(widget.isFirst != 1){
              final comicSetDetail = ref.read(comicSetDetailStateProvider);
              ref.read(comicSetListStateProvider.notifier).setData(widget.isFirst,comicSetDetail!);
            }
          }
        },
        child: TopTool(
            title: "",
            child: LayoutBuilder(builder: (context, constraints) {
              return Column(
                children: [
                  if (constraints.maxWidth > MyApp.width)
                    ToolBar(
                      showBack: true,
                      widgetList: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_rounded,
                          ),
                          color: Colors.grey,
                          onPressed: () => showDialog(
                              context: context,
                              builder: (context) {
                                return ComicSetForm(
                                  index: -1,
                                  id: int.parse(widget.id),
                                );
                              }),
                        )
                      ],
                    ),
                  Expanded(
                      child: constraints.maxWidth > MyApp.width
                          ? Row(
                              children: [
                                Container(
                                  width: 350,
                                  margin: const EdgeInsets.only(right: 20),
                                  height: double.infinity,
                                  child: ComicSetDetail(
                                    id: int.parse(widget.id),
                                  ),
                                ),
                                Expanded(
                                    child: ComicList(
                                        filesId: int.parse(widget.filesId)))
                              ],
                            )
                          : PageView(
                              controller: pageController,
                              scrollDirection: Axis.horizontal,
                              children: [
                                KeepActivePage(
                                    widget: ComicSetDetail(
                                  id: int.parse(widget.id),
                                )),
                                KeepActivePage(
                                    widget: ComicList(
                                        filesId: int.parse(widget.filesId)))
                              ],
                            )),
                ],
              );
            })));
  }
}
