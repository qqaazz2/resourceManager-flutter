import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:resourcemanager/common/Global.dart';
import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/models/picture/PictureList.dart';
import 'package:resourcemanager/state/picture/PictureListState.dart';
import 'package:resourcemanager/state/picture/PictureState.dart';
import 'package:resourcemanager/widgets/ListWidget.dart';

class PictureItem extends FilesItem<PictureData> {
  const PictureItem(
      {super.key,
      required super.data,
      required super.index,
      required super.show,
      required super.isPc,
      this.id});

  final String? id;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => PictureItemState();
}

class PictureItemState extends ConsumerState<PictureItem> {
  Map<String, String> map = {"Authorization": "Bearer ${Global.token}"};

  @override
  Widget build(BuildContext context) {
    PictureData data = widget.data;
    String path = checkIsFolder(data);
    return GestureDetector(
        child: Stack(
          children: [
            imageModule(path, data.isFolder, data.fileName),
            Icon(data.isFolder == 1
                ? Icons.folder_outlined
                : Icons.image_outlined),
            if(data.isFolder == 2) Positioned(
                bottom: 0,
                right: 0,
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    data.love == 2 ? Icons.favorite_border : Icons.favorite,
                    color: data.love == 2 ? Colors.white : Colors.red,
                  ),
                )),
          ],
        ),
        onTap: () {
          if (data.isFolder == 2) {
            ref
                .read(pictureStateProvider(widget.id).notifier)
                .setCurrent(widget.index);
            context.push("/picture/details?id=${widget.id}");
          } else {
            context.push("/picture?id=${data.id}");
          }
        });
  }

  String checkIsFolder(PictureData data) {
    String originalString =
        "${HttpApi.options.baseUrl}${data.isFolder == 1 ? data.cover : data.filePath}";
    String modifiedString = originalString.replaceFirst('\\', '');
    modifiedString = modifiedString.replaceAll('\\', '/');
    return modifiedString;
  }

  Widget imageModule(String path, int isFolder, String fileName) {
    if (isFolder == 1) {
      return Column(
        children: [
          const Expanded(
              child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: FittedBox(child: Icon(Icons.folder)),
          )),
          Text(
            fileName,
            style: const TextStyle(fontSize: 15),
          )
        ],
      );
    }
    // if(kIsWeb){
    //   return Image.network(path,width: double.infinity,height: double.infinity,headers: map,errorBuilder:(context,object,stackTrace) => Image.asset("images/1.png"));
    // }else{
    return CachedNetworkImage(
      width: double.infinity,
      height: double.infinity,
      imageUrl: path,
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          CircularProgressIndicator(value: downloadProgress.progress),
      httpHeaders: map,
      errorWidget: (context, url, error) =>
          Image.asset("images/1.png", fit: BoxFit.fill),
      fit: BoxFit.cover,
    );
    // }
  }
}
