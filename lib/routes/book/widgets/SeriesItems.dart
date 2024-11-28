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
import 'package:resourcemanager/models/picture/PictureList.dart';
import 'package:resourcemanager/routes/book/SeriesForm.dart';
import 'package:resourcemanager/state/book/SeriesListState.dart';
import 'package:resourcemanager/state/picture/PictureListState.dart';
import 'package:resourcemanager/state/picture/PictureState.dart';
import 'package:resourcemanager/widgets/ListWidget.dart';

class SeriesItems extends FilesItem<SeriesItem> {
  const SeriesItems(
      {super.key,
      required super.data,
      required super.index,
      required super.show,
      required super.isPc});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => SeriesItemsState();
}

class SeriesItemsState extends ConsumerState<SeriesItems> {
  Map<String, String> map = {"Authorization": "Bearer ${Global.token}"};

  final over = [
    "连载中",
    "完结",
    "弃坑",
  ];

  final status = [
    Colors.redAccent,
    Colors.amberAccent,
    Colors.transparent,
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(seriesListStateProvider);
    SeriesItem data = widget.data;
    return GestureDetector(
        child: Column(
          children: [
            Expanded(
                child: Stack(
              children: [
                imageModule(splicingPath(data.filePath)),
                Positioned(
                    right: 5,
                    top: 5,
                    child: Badge(
                      smallSize: 10,
                      backgroundColor: status[data.status - 1],
                    )),
                Positioned(
                    left: 0,
                    bottom: 0,
                    child: Text(
                      over[data.overStatus - 1],
                      style: const TextStyle(color: Colors.grey),
                    )),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: Column(
                      children: [
                        GestureDetector(
                            onTap: () => ref
                                .read(seriesListStateProvider.notifier)
                                .setLove(widget.index),
                            child: Icon(
                              data.love == 1
                                  ? Icons.favorite_border
                                  : Icons.favorite,
                              size: 25,
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
                                return SeriesForm(
                                  index: widget.index,
                                  seriesItem: data,
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
          context.push("/books/content?seriesId=${data.id}&filesId=${data.filesId}&index=1");
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
