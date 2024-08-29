import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resourcemanager/common/Global.dart';
import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/models/picture/PictureList.dart';
import 'package:resourcemanager/state/picture/PictureListState.dart';
import 'package:resourcemanager/widgets/ListWidget.dart';

class PictureItem extends FilesItem<PictureData> {
  const PictureItem(
      {super.key,
      required super.data,
      required super.index,
      required super.show,
      required super.isPc});

  @override
  State<StatefulWidget> createState() => PictureItemState();
}

class PictureItemState extends State<PictureItem> {
  Map<String, String> map = {"Authorization": "Bearer ${Global.token}"};

  @override
  Widget build(BuildContext context) {
    PictureData data = widget.data;
    String path = checkIsFolder(data);
    return GestureDetector(
        child: Stack(
          children: [
            imageModule(path),
            Icon(data.isFolder == 1
                ? Icons.folder_outlined
                : Icons.image_outlined)
          ],
        ),
        onTap: () {
          PictureListState pictureListState = Provider.of<PictureListState>(context, listen: false);
          if(data.isFolder == 2){
            int index = widget.index > 0
                ? widget.index -
                (pictureListState.count - pictureListState.pictures.length)
                : 0;
            pictureListState.setCurrent(index);
            context.go("/picture/details");
            context.go("/picture/details");
          }else{
            context.go("/picture?id=${data.id}");
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

  Widget imageModule(String path) {
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
