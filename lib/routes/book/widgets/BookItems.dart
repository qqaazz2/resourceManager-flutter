import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:resourcemanager/common/Global.dart';
import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/entity/book/BookItem.dart';
import 'package:resourcemanager/entity/book/BookItem.dart';
import 'package:resourcemanager/entity/book/BookItem.dart';
import 'package:resourcemanager/models/picture/PictureList.dart';
import 'package:resourcemanager/routes/book/SeriesForm.dart';
import 'package:resourcemanager/state/book/SeriesContentState.dart';
import 'package:resourcemanager/state/book/SeriesListState.dart';
import 'package:resourcemanager/state/picture/PictureListState.dart';
import 'package:resourcemanager/state/picture/PictureState.dart';
import 'package:resourcemanager/widgets/ListWidget.dart';

class BookItems extends FilesItem<BookItem> {
   const BookItems(
      {super.key,
      required super.data,
      required super.index,
      required super.show,
      required super.isPc,
      required this.seriesId});

  final int seriesId;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => BookItemsState();
}

class BookItemsState extends ConsumerState<BookItems> {
  Map<String, String> map = {"Authorization": "Bearer ${Global.token}"};

  final status = {
    1: Colors.redAccent,
    2: Colors.transparent,
    3: Colors.amberAccent,
  };

  @override
  Widget build(BuildContext context) {
    BookItem data = widget.data;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: GestureDetector(
          child: data.isFolder == 2
              ? getBookWidget(data)
              : Column(
                  children: [
                    Image.asset("images/1.png", fit: BoxFit.fill),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        data.name!,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
          onTap: () {
            ref.read(seriesContentStateProvider(widget.seriesId).notifier).updateLastReadTime(widget.seriesId);
            context.push("/books/read?seriesId=${widget.seriesId}",extra: widget.data);
          }),
    );
  }

  Widget getBookWidget(BookItem data) {
    return Column(
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
                  backgroundColor: status[data.status],
                )),
            Positioned(
                bottom: 0,
                right: 0,
                child: Column(
                  children: [
                    IconButton(
                      iconSize: 20,
                      icon: const Icon(
                        Icons.image,
                      ),
                      color: Colors.grey,
                      onPressed: () {
                        ref.read(seriesContentStateProvider(widget.seriesId).notifier).setCover(widget.data);
                      }
                    )
                  ],
                )),
          ],
        )),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            data.name!,
            maxLines: 1,
          ),
        ),
      ],
    );
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
        return const Icon(Icons.my_library_books, size: 150);
      },
      fit: BoxFit.cover,
    );
    // }
  }
}
