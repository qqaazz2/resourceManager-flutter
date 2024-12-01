import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:resourcemanager/common/Global.dart';
import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/main.dart';
import 'package:resourcemanager/models/GetBooksList.dart';
import 'package:resourcemanager/models/picture/PictureList.dart';
import 'package:resourcemanager/routes/picture/PictureForm.dart';
import 'package:resourcemanager/state/picture/PictureState.dart';

class PictureRandom extends ConsumerStatefulWidget {
  const PictureRandom({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => PictureRandomState();
}

class PictureRandomState extends ConsumerState<PictureRandom> {
  PageController pageController = PageController();
  ValueNotifier<bool> showBar = ValueNotifier(false);
  bool _isSidebarVisible = false;
  ValueNotifier<int> current = ValueNotifier(0);
  List<PictureData> list = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleEvent);
    getData();
  }

  void getData() async {
    list = await ref.read(pictureStateProvider("-1").notifier).randomData();
    setState(() {
      isLoading = false;
    });
  }

  bool _handleEvent(event) {
    if (HardwareKeyboard.instance.logicalKeysPressed
        .contains(LogicalKeyboardKey.arrowLeft)) {
      pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.linear);
    } else if (HardwareKeyboard.instance.logicalKeysPressed
        .contains(LogicalKeyboardKey.arrowRight)) {
      pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.linear);
    }

    return false;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (isLoading) {
      return const SizedBox(
          width: 100, height: 100, child: CircularProgressIndicator());
    }

    return SafeArea(
        child: Listener(onPointerHover: (value) {
      showBar.value = true;
      _resetIdleTimer();
    }, onPointerMove: (value) {
      showBar.value = true;
    }, onPointerSignal: (PointerSignalEvent event) {
      if (event is PointerScrollEvent) {
        // 判断鼠标滚动
        if (event.scrollDelta.dy < 0) {
          pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear);
        } else if (event.scrollDelta.dy > 0) {
          pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear);
        }
      }
    }, child: Consumer(builder: (context, ref, child) {
      return Stack(
        children: [
          Row(
            children: [
              Expanded(
                  child: GestureDetector(
                onTapUp: (details) {
                  double dx = details.globalPosition.dx;
                  if (dx < screenWidth / 3) {
                    pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.linear);
                  } else if (dx > 2 * screenWidth / 3 && dx < screenWidth) {
                    pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.linear);
                  } else if (dx > screenWidth / 3 && dx < screenWidth) {
                    showBar.value = true;
                    _resetIdleTimer();
                  }
                },
                child: PhotoViewGallery.builder(
                  itemCount: list.length,
                  builder: (context, index) {
                    PictureData pictureData = list[index];
                    if (pictureData.display != 2) {
                      ref
                          .read(pictureStateProvider("-1").notifier)
                          .setDisplay(pictureData.id, 2);
                      pictureData.display = 2;
                    }
                    return PhotoViewGalleryPageOptions.customChild(
                        child: PictureInfo(pictureData: list[index]),
                        heroAttributes: PhotoViewHeroAttributes(
                            tag: "${pictureData.id}_${pictureData.filePath}"));
                  },
                  scrollPhysics: const BouncingScrollPhysics(),
                  pageController: pageController,
                  onPageChanged: (index) {
                    current.value = index;
                  },
                  backgroundDecoration:
                      const BoxDecoration(color: Colors.black),
                ),
              )),
            ],
          ),
          Positioned(
              child: ValueListenableBuilder(
            valueListenable: showBar,
            builder: (BuildContext context, bool value1, Widget? child) {
              return AnimatedOpacity(
                opacity: value1 ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: ValueListenableBuilder(
                    valueListenable: current,
                    builder: (context, currentValue, child) {
                      return PictureBar(
                        pictureData: list[currentValue],
                        deletePicture: deletePicture,
                      );
                    }),
              );
            },
          ))
        ],
      );
    })));
  }

  void deletePicture() {}

  Timer? _timer;

  void _resetIdleTimer() {
    // 如果之前有计时器，取消它
    _timer?.cancel();

    // 设置一个新的计时器，假设 2 秒后将 currentValue 设为 false
    _timer = Timer(const Duration(seconds: 2), () {
      showBar.value = false;
    });
  }
}

class PictureBar extends StatelessWidget {
  const PictureBar(
      {super.key, required this.pictureData, required this.deletePicture});

  final PictureData pictureData;
  final VoidCallback deletePicture;

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
            pictureData.fileName,
            textAlign: TextAlign.center,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
          )),
          Row(
            children: [
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
