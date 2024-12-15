import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:resourcemanager/common/Global.dart';
import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/entity/book/SeriesItem.dart';
import 'package:resourcemanager/entity/book/SeriesItem.dart';
import 'package:resourcemanager/entity/book/SeriesItem.dart';
import 'package:resourcemanager/entity/comic/ComicSetItem.dart';
import 'package:resourcemanager/models/picture/PictureList.dart';
import 'package:resourcemanager/routes/book/SeriesForm.dart';
import 'package:resourcemanager/routes/comic/ComicSetForm.dart';
import 'package:resourcemanager/state/book/SeriesListState.dart';
import 'package:resourcemanager/state/comic/ComicSetListState.dart';
import 'package:resourcemanager/state/picture/PictureListState.dart';
import 'package:resourcemanager/state/picture/PictureState.dart';
import 'package:resourcemanager/widgets/ListWidget.dart';

class ComicSetItems extends FilesItem<ComicSetItem> {
  const ComicSetItems(
      {super.key,
      required super.data,
      required super.index,
      required super.show,
      required super.isPc});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => ComicSetItemsState();
}

class ComicSetItemsState extends ConsumerState<ComicSetItems> {
  Map<String, String> map = {"Authorization": "Bearer ${Global.token}"};

  final status = [
    "连载中",
    "完结",
    "有生之年",
    "弃坑",
  ];

  final readStatus = [
    Colors.redAccent,
    Colors.transparent,
    Colors.amberAccent,
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(comicSetListStateProvider);
    ComicSetItem data = widget.data;
    return GestureDetector(
        child: Column(
          children: [
            Expanded(
                child: Stack(
              children: [
                imageModule(splicingPath(data.coverPath)),
                Positioned(
                    right: 5,
                    top: 5,
                    child: Badge(
                      smallSize: 10,
                      backgroundColor: readStatus[data.readStatus - 1],
                    )),
                Positioned(
                    left: 0,
                    bottom: 0,
                    child: Text(
                      status[data.status - 1],
                      style: const TextStyle(color: Colors.grey),
                    )),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: Column(
                      children: [
                        IconButton(
                            iconSize: 25,
                            onPressed: () => ref
                                .read(comicSetListStateProvider.notifier)
                                .setLove(data.id,data.love),
                            icon: Icon(
                              data.love == 1
                                  ? Icons.favorite_border
                                  : Icons.favorite,
                              color: Colors.redAccent,
                            )),
                        IconButton(
                          iconSize: 25,
                          icon: const Icon(
                            Icons.edit_rounded,
                          ),
                          color: Colors.grey,
                          onPressed: () => showDialog(
                              context: context,
                              builder: (context) {
                                return ComicSetForm(
                                  index: widget.index,
                                  id: data.id,
                                );
                              }),
                        )
                      ],
                    )),
              ],
            )),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                data.name,
                maxLines: 1,
              ),
            ),
          ],
        ),
        onTap: () {
          context.push(
              "/comic/detail?id=${data.id}&isFirst=${widget.index}&filesId=${data.filesId}");
        });
  }

  String splicingPath(String? filePath) {
    String originalString = "${HttpApi.options.baseUrl}$filePath";
    String modifiedString = originalString.replaceFirst('\\', '');
    modifiedString = modifiedString.replaceAll('\\', '/');
    return modifiedString;
  }

  Widget imageModule(String? path) {
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
      fit: BoxFit.cover,
    );
    // }
  }
}
