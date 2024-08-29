import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:resourcemanager/common/Global.dart';
import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/main.dart';
import 'package:resourcemanager/models/picture/PictureList.dart';
import 'package:resourcemanager/routes/picture/PictureForm.dart';
import 'package:resourcemanager/state/picture/PictureListState.dart';

class PictureDetails extends StatefulWidget {
  const PictureDetails({super.key});

  @override
  State<StatefulWidget> createState() => PictureDetailsState();
}

class PictureDetailsState extends State<PictureDetails> {
  late PageController pageController;
  ValueNotifier<bool> showBar = ValueNotifier(false);
  bool _isSidebarVisible = false;

  @override
  void initState() {
    super.initState();
    PictureListState listState = Provider.of<PictureListState>(
        MyApp.rootNavigatorKey.currentContext!,
        listen: false);
    pageController = PageController(initialPage: listState.current);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(onTapUp: (TapUpDetails details) {
      double dx = details.globalPosition.dx;
      if (dx < screenWidth / 3) {
        pageController.previousPage(
            duration: const Duration(milliseconds: 500), curve: Curves.linear);
      } else if (dx > 2 * screenWidth / 3 && dx < screenWidth) {
        pageController.nextPage(
            duration: const Duration(milliseconds: 500), curve: Curves.linear);
      } else if (dx > screenWidth / 3 && dx < screenWidth) {
        showBar.value = !showBar.value;
      }
    }, child: Consumer<PictureListState>(builder: (context, value, child) {
      return Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: PhotoViewGallery.builder(
                  itemCount: value.pictures.length,
                  builder: (context, index) {
                    PictureData pictureData = value.pictures[index];
                    return PhotoViewGalleryPageOptions.customChild(
                        child: PictureInfo(pictureData: value.pictures[index]),
                        heroAttributes: PhotoViewHeroAttributes(
                            tag: "${pictureData.id}_${pictureData.filePath}"));
                  },
                  scrollPhysics: const BouncingScrollPhysics(),
                  pageController: pageController,
                  onPageChanged: (index) {
                    value.setCurrent(index);
                  },
                  backgroundDecoration:
                      const BoxDecoration(color: Colors.black),
                ),
              ),
              // 侧边栏
              if (screenWidth > MyApp.width)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isSidebarVisible ? 300 : 0,
                  color: Colors.blueGrey,
                  child: _isSidebarVisible ? PictureForm(voidCallback: () => checkInfo(),) : null,
                ),
            ],
          ),
          Positioned(
              child: ValueListenableBuilder(
            valueListenable: showBar,
            builder: (BuildContext context, bool value1, Widget? child) {
              return AnimatedOpacity(
                opacity: value1 ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                child: PictureBar(
                    pictureData: value.pictures[value.current],
                    deletePicture: deletePicture,
                    checkInfo: checkInfo),
              );
            },
          ))
        ],
      );
    }));
  }

  void deletePicture() {}

  void checkInfo() {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < MyApp.width) {
      showDialog(
          context: context,
          builder: (context) {
            return PictureForm(voidCallback: () => Navigator.of(context).pop(),);
          });
    }else{
      setState(() {
        _isSidebarVisible = !_isSidebarVisible;
      });
    }
  }
}

class PictureBar extends StatelessWidget {
  const PictureBar(
      {super.key,
      required this.pictureData,
      required this.deletePicture,
      required this.checkInfo});

  final PictureData pictureData;
  final VoidCallback deletePicture;
  final VoidCallback checkInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.black.withOpacity(0.3),
        child: Row(mainAxisSize: MainAxisSize.max, children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_sharp),
            color: Colors.white,
          ),
          Expanded(
              child: Text(
            pictureData.modifiableName,
            textAlign: TextAlign.center,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
          )),
          Row(
            children: [
              IconButton(
                  onPressed: checkInfo,
                  icon: const Icon(Icons.info),
                  color: Colors.white),
              IconButton(
                  onPressed: () => deletePicture,
                  icon: const Icon(Icons.delete_forever),
                  color: Colors.white),
            ],
          )
        ]));
  }
}

class PictureInfo extends StatelessWidget {
  PictureInfo({super.key, required this.pictureData});

  final PictureData pictureData;
  final Map<String, String> map = {"Authorization": "Bearer ${Global.token}"};

  @override
  Widget build(BuildContext context) {
    String path = getPath();
    return imageModule(path);
  }

  String getPath() {
    String originalString = "${HttpApi.options.baseUrl}${pictureData.filePath}";
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
      progressIndicatorBuilder: (context, url, downloadProgress) {
        return Container(
          width: 100,
          height: 100,
          alignment: Alignment.center,
          child: SizedBox(
            width: 50, // 设置进度条的宽度
            height: 50, // 设置进度条的高度
            child: CircularProgressIndicator(
              value: downloadProgress.progress,
            ),
          ),
        );
      },
      httpHeaders: map,
      errorWidget: (context, url, error) => Image.asset("images/1.png"),
      // fit: BoxFit.fitHeight,
    );
    // }
  }
}
