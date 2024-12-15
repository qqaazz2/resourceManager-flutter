import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resourcemanager/common/Global.dart';
import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/main.dart';
import 'package:resourcemanager/state/comic/ComicSetDetailState.dart';
import 'package:resourcemanager/widgets/ToolBar.dart';
import 'package:resourcemanager/widgets/TopTool.dart';

class ComicSetDetail extends ConsumerStatefulWidget {
  const ComicSetDetail({super.key, required this.id});

  final int id;

  @override
  ConsumerState<ComicSetDetail> createState() => ComicSetDetailState();
}

class ComicSetDetailState extends ConsumerState<ComicSetDetail> {
  Map<String, String> map = {"Authorization": "Bearer ${Global.token}"};
  Map<int, String> statusMap = {1: "连载中", 2: "完结", 3: "有生之年", 4: "弃坑"};
  Map<int, String> readMap = {1: "未读", 2: "已读", 3: "在读"};
  List readStatus = [
    Colors.redAccent,
    Colors.transparent,
    Colors.amberAccent,
  ];

  @override
  void initState() {
    super.initState();
    ref.read(comicSetDetailStateProvider.notifier).getDetail(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(comicSetDetailStateProvider);

    if (state == null) {
      return const Align(
          child: SizedBox(
        width: 150,
        height: 150,
        child: CircularProgressIndicator(),
      ));
    }

    return Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        decoration: const BoxDecoration(color: Colors.white),
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3), // 更深的阴影颜色
                          blurRadius: 16.0, // 增加模糊半径
                          offset: const Offset(0, 6), // 阴影的偏移量，适当增加偏移来突出阴影效果
                        ),
                      ],
                    ),
                    width: 300,
                    height: 420,
                    child: imageModule(splicingPath(state.coverPath)),
                  ),
                  Positioned(
                      right: 5,
                      top: 5,
                      child: Badge(
                        smallSize: 10,
                        backgroundColor: readStatus[state.readStatus - 1],
                      )),
                  Positioned(
                    bottom: 20,
                    right: 0,
                    child: IconButton(
                        onPressed: () => ref
                            .read(comicSetDetailStateProvider.notifier)
                            .setLove(widget.id),
                        icon: Icon(
                          state.love == 2
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.redAccent,
                        )),
                  ),
                ],
              )),
              Text(state.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    "漫画数量：${state.comicCount}",
                    style: const TextStyle(fontSize: 14),
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    "系列状态：${statusMap[state.status]}",
                    style: const TextStyle(fontSize: 14),
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    "阅读状态：${readMap[state.readStatus]}",
                    style: const TextStyle(fontSize: 14),
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    "作者：${state.author ?? "无"}",
                    style: const TextStyle(fontSize: 14),
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    "语言：${state.language ?? "无"}",
                    style: const TextStyle(fontSize: 14),
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    "出版社：${state.press ?? "无"}",
                    style: const TextStyle(fontSize: 14),
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    "最后一次阅读：${state.lastReadTime ?? "无"}",
                    style: const TextStyle(fontSize: 14),
                  )),
              const Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    "系列概要：",
                    style: TextStyle(fontSize: 14),
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    state.note ?? "无",
                    style: const TextStyle(fontSize: 14),
                  )),
            ],
          ),
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
    if (path == null) return const Icon(Icons.folder, size: 150);
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
}
