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
import 'package:resourcemanager/models/picture/PictureList.dart';
import 'package:resourcemanager/routes/picture/PictureForm.dart';
import 'package:resourcemanager/state/picture/PictureListState.dart';
import 'package:resourcemanager/state/picture/PictureState.dart';
import 'package:resourcemanager/widgets/TopTool.dart';

class PictureDetails extends ConsumerStatefulWidget {
  const PictureDetails({super.key, this.id});

  final String? id;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => PictureDetailsState();
}

class PictureDetailsState extends ConsumerState<PictureDetails> {
  late PageController pageController;
  ValueNotifier<bool> showBar = ValueNotifier(false);
  bool _isSidebarVisible = false;
  ValueNotifier<int> current = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    final pictureData = ref.read(pictureStateProvider(widget.id));
    pageController = PageController(initialPage: pictureData.current);
    current.value = pictureData.current;
    HardwareKeyboard.instance.addHandler(_handleEvent);
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
    return TopTool(
        title: '',
        show: false,
        endDrawer: ValueListenableBuilder(
            valueListenable: current,
            builder: (context, currentValue, child) {
              return PictureForm(
                id: widget.id,
                voidCallback: () => checkInfo(currentValue),
                currentValue: currentValue,
              );
            }),
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
          final value = ref.watch(pictureStateProvider(widget.id));
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
                          } else if (dx > 2 * screenWidth / 3 &&
                              dx < screenWidth) {
                            pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.linear);
                          } else if (dx > screenWidth / 3 && dx < screenWidth) {
                            showBar.value = true;
                            _resetIdleTimer();
                          }
                        },
                        child: PhotoViewGallery.builder(
                          itemCount: value.list.length,
                          builder: (context, index) {
                            PictureData pictureData = value.list[index];
                            return PhotoViewGalleryPageOptions.customChild(
                                child:
                                    PictureInfo(pictureData: value.list[index]),
                                heroAttributes: PhotoViewHeroAttributes(
                                    tag:
                                        "${pictureData.id}_${pictureData.filePath}"));
                          },
                          scrollPhysics: const BouncingScrollPhysics(),
                          pageController: pageController,
                          onPageChanged: (index) {
                            current.value = index;
                            if (index == value.list.length - 1 && value.list.length < value.count) {
                              ref
                                  .read(
                                      pictureStateProvider(widget.id).notifier)
                                  .getList(widget.id);
                            }
                          },
                          backgroundDecoration:
                              const BoxDecoration(color: Colors.black),
                        )),
                  ),
                  // 侧边栏
                  // if (screenWidth > MyApp.width)
                  //   AnimatedContainer(
                  //     duration: const Duration(milliseconds: 300),
                  //     width: _isSidebarVisible ? 300 : 0,
                  //     color: Colors.blueGrey,
                  //     child: _isSidebarVisible
                  //         ?
                  //         : null,
                  //   ),
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
                              pictureData: value.list[currentValue],
                              deletePicture: deletePicture,
                              checkInfo: () =>
                                  Scaffold.of(context).openEndDrawer());
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

  void checkInfo(int currentValue) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < MyApp.width) {
      showDialog(
          context: context,
          builder: (context) {
            return PictureForm(
              id: widget.id,
              currentValue: currentValue,
              voidCallback: () => Navigator.of(context).pop(),
            );
          });
    } else {
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
            pictureData.fileName,
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
