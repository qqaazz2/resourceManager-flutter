import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resourcemanager/common/Global.dart';
import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/entity/book/BookItem.dart';
import 'package:resourcemanager/main.dart';
import 'package:resourcemanager/routes/book/widgets/BookItems.dart';
import 'package:resourcemanager/routes/book/widgets/SeriesChangeCover.dart';
import 'package:resourcemanager/routes/book/widgets/SeriesDetails.dart';
import 'package:resourcemanager/state/book/SeriesContentState.dart';
import 'package:resourcemanager/state/book/SeriesListState.dart';
import 'package:resourcemanager/widgets/ListWidget.dart';

import 'SeriesForm.dart';

class SeriesContent extends ConsumerStatefulWidget {
  const SeriesContent(
      {super.key,
      required this.filesId,
      required this.seriesId,
      required this.index});

  final int seriesId;
  final int filesId;
  final int index;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => SeriesContentState();
}

class SeriesContentState extends ConsumerState<SeriesContent> {
  @override
  void initState() {
    super.initState();
    ref
        .read(seriesContentStateProvider(widget.seriesId).notifier)
        .getData(widget.filesId);
  }

  Map<String, String> map = {"Authorization": "Bearer ${Global.token}"};

  Map<int, String> overMap = {1: "连载中", 2: "完结", 3: "弃坑"};
  Map<int, String> readMap = {1: "未读", 2: "已读", 3: "在读"};

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(seriesContentStateProvider(widget.seriesId));
    if (state.seriesItem == null) return const CircularProgressIndicator();
    return PopScope(
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if(widget.index == 1) {
            ref
              .read(seriesListStateProvider.notifier)
              .setData(state.seriesItem!);
          }
        },
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              child: SafeArea(
                  child: NestedScrollView(
                body: Container(
                    constraints: const BoxConstraints(minWidth: 200),
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: Theme.of(context).shadowColor.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ]),
                    margin: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 15),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: ListWidget<BookItem>(
                                  list: state.bookItem!,
                                  count: state.bookItem!.length,
                                  scale: .7,
                                  widget: (BookItem data, index,
                                      {show = false, isPc = true}) {
                                    return BookItems(
                                      data: data,
                                      index: index,
                                      show: show,
                                      isPc: isPc,
                                      seriesId: widget.seriesId,
                                    );
                                  },
                                  getList: () => {}))
                        ])),
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return MyApp.width < MediaQuery.of(context).size.width
                      ? getPc(state)
                      : getMobile(state);
                },
              )),
              // child: Row(
              //   children: [
              //     SizedBox(
              //         width: 100,
              //         child: AspectRatio(
              //             aspectRatio: 9 / 13,
              //             child: imageModule(splicingPath(seriesItem.filePath)))),
              //     SingleChildScrollView(
              //       child: Column(
              //         mainAxisSize: MainAxisSize.max,
              //         children: [
              //           Padding(
              //               padding: const EdgeInsets.only(bottom: 10),
              //               child: Text(
              //                 seriesItem.name,
              //                 style: const TextStyle(fontSize: 20),
              //                 maxLines: 2,
              //               )),
              //           // Padding(padding: EdgeInsets)
              //         ],
              //       ),
              //     )
              //   ],
              // ),
            )
          ],
        ));
  }

  String splicingPath(String? filePath) {
    String originalString = "${HttpApi.options.baseUrl}$filePath";
    String modifiedString = originalString.replaceFirst('\\', '');
    modifiedString = modifiedString.replaceAll('\\', '/');
     
    return modifiedString;
  }

  Widget imageModule(String? path, {BoxFit? fit}) {
    // if(kIsWeb){
    //   return Image.network(path,width: double.infinity,height: double.infinity,headers: map,errorBuilder:(context,object,stackTrace) => Image.asset("images/1.png"));
    // }else{
    if (path == null) return Image.asset("images/1.png", fit: BoxFit.fill);
    return CachedNetworkImage(
      width: double.infinity,
      height: double.infinity,
      imageUrl: path,
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          CircularProgressIndicator(value: downloadProgress.progress),
      httpHeaders: map,
      errorWidget: (context, url, error) {
        CachedNetworkImage.evictFromCache(url);
        return const Icon(Icons.folder, size: 150);
      },
      fit: fit ?? BoxFit.cover,
    );
    // }
  }

  List<Widget> getPc(state) {
    return [
      SliverAppBar(
        pinned: true,
        expandedHeight: 400,
        flexibleSpace: FlexibleSpaceBar(
          background: SizedBox(
            // constraints: const BoxConstraints(minHeight: 100),
            // padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
            // decoration: BoxDecoration(
            //     color: Theme.of(context).cardColor,
            //     borderRadius: BorderRadius.circular(15),
            //     boxShadow: [
            //       BoxShadow(
            //           color: Theme.of(context).shadowColor.withOpacity(0.1),
            //           blurRadius: 10,
            //           offset: const Offset(0, 4))
            //     ]),
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    width: 300,
                    child: imageModule(splicingPath(state.seriesItem!.filePath),
                        fit: BoxFit.fitHeight)),
                Expanded(
                    child: Stack(
                  children: [
                    SizedBox(
                        height: 400,
                        child: SingleChildScrollView(
                            child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(state.seriesItem!.name,
                                style: const TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.w800)),
                            Padding(
                              padding: const EdgeInsets.only(top: 7, bottom: 8),
                              child: Text(
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                  "作者：${state.seriesItem!.author}"),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                  "阅读状态：${readMap[state.seriesItem!.status]}"),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                  "完结状态：${overMap[state.seriesItem!.overStatus]}"),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                  "最后一次阅读：${state.seriesItem!.lastReadTime ?? "无"}"),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                  "简介："),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                  state.seriesItem!.profile ?? "无"),
                            ),
                          ],
                        ))),
                    Positioned(
                        right: 0,
                        bottom: 0,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                ref
                                    .read(seriesContentStateProvider(
                                            widget.seriesId)
                                        .notifier)
                                    .setLove();
                              },
                              icon: Icon(state.seriesItem!.love == 1
                                  ? Icons.favorite_border
                                  : Icons.favorite),
                              color: Colors.redAccent,
                            ),
                            IconButton(
                                onPressed: () => showDialog(
                                    context: context,
                                    builder: (context) {
                                      return SeriesForm(
                                        index: widget.index,
                                        seriesId: widget.seriesId,
                                        seriesItem: state.seriesItem!,
                                      );
                                    }),
                                icon: const Icon(Icons.edit))
                          ],
                        )),
                  ],
                ))
              ],
            ),
          ),
          centerTitle: false,
        ),
      ),
    ];
  }

  List<Widget> getMobile(state) {
    return [
      SliverAppBar(
        pinned: true,
        expandedHeight: 400,
        flexibleSpace: FlexibleSpaceBar(
          background: imageModule(splicingPath(state.seriesItem!.filePath),
              fit: BoxFit.fitHeight),
          centerTitle: false,
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        sliver: SliverToBoxAdapter(
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).shadowColor.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ]),
              width: double.infinity,
              child: Consumer(builder: (content, ref, child) {
                return Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(state.seriesItem!.name,
                            style: const TextStyle(fontSize: 20)),
                        Padding(
                          padding: const EdgeInsets.only(top: 7, bottom: 8),
                          child: Text("作者：${state.seriesItem!.author}"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child:
                              Text("阅读状态：${readMap[state.seriesItem!.status]}"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                              "完结状态：${overMap[state.seriesItem!.overStatus]}"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                              "最后一次阅读：${state.seriesItem!.lastReadTime ?? "无"}"),
                        ),
                      ],
                    ),
                    Positioned(
                        right: 0,
                        bottom: 0,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                ref
                                    .read(seriesContentStateProvider(
                                            widget.seriesId)
                                        .notifier)
                                    .setLove();
                              },
                              icon: Icon(state.seriesItem!.love == 1
                                  ? Icons.favorite_border
                                  : Icons.favorite),
                              color: Colors.redAccent,
                            ),
                            IconButton(
                                onPressed: () => showDialog(
                                    context: context,
                                    builder: (context) {
                                      return SeriesForm(
                                        index: widget.index,
                                        seriesId: widget.seriesId,
                                        seriesItem: state.seriesItem!,
                                      );
                                    }),
                                icon: const Icon(Icons.edit))
                          ],
                        )),
                  ],
                );
              })),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        sliver: SliverToBoxAdapter(
          child: Container(
              constraints: const BoxConstraints(minHeight: 100),
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).shadowColor.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ]),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "简介",
                    style: TextStyle(fontSize: 17),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Text(state.seriesItem!.profile ?? "无"),
                  )
                ],
              )),
        ),
      ),
    ];
  }
}
