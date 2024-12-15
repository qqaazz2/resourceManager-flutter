import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:resourcemanager/common/Global.dart';
import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/entity/comic/ComicItem.dart';
import 'package:resourcemanager/main.dart';
import 'package:resourcemanager/state/comic/ComicListState.dart';
import 'package:resourcemanager/widgets/ListTitleWidget.dart';

class ComicRender extends ConsumerStatefulWidget {
  const ComicRender({super.key, required this.comicItem, required this.index});

  final ComicItem comicItem;
  final int index;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => ComicRenderState();
}

class ComicRenderState extends ConsumerState<ComicRender> {
  Map<String, String> map = {"Authorization": "Bearer ${Global.token}"};
  late PageController pageController;
  bool isLoading = true;
  int layout = 1;
  int turning = 1;
  ValueNotifier<bool> isChange = ValueNotifier(false);
  Map<int, String> layoutMap = {1: "适应", 2: "双页", 3: "单页"};
  Map<int, String> turningMap = {1: "左右翻页", 2: "上下翻页", 3: "滚动查看"};
  List<String> list = [];
  ValueNotifier<int> currentIndex = ValueNotifier(0);
  Timer? _timer;
  int comicListCount = 0;
  bool isSwitch = false;

  late ComicItem comicItem;
  late int index;
  int countPage = 0;

  Timer? isShowTimer;

  ValueNotifier<bool> isShow = ValueNotifier(false);
  late final AppLifecycleListener appLifecycleListener;

  @override
  void initState() {
    super.initState();
    comicItem = widget.comicItem;
    index = widget.index;
    pageController = PageController(initialPage: widget.comicItem.number ?? 0);
    comicListCount = ref.read(comicListStateProvider.notifier).getCount();
    HardwareKeyboard.instance.addHandler(_handleEvent);
    currentIndex.value = comicItem.number ?? 0;
    appLifecycleListener = AppLifecycleListener(
      onHide: () => updateNumber(),
      onInactive: () => updateNumber()
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    HardwareKeyboard.instance.removeHandler(_handleEvent);

    appLifecycleListener.dispose();
    super.dispose();
  }

  bool _handleEvent(event) {
    if (HardwareKeyboard.instance.logicalKeysPressed
        .contains(LogicalKeyboardKey.arrowLeft)) {
      previousPage();
      return false;
    } else if (HardwareKeyboard.instance.logicalKeysPressed
        .contains(LogicalKeyboardKey.arrowRight)) {
      nextPage();
      return false;
    }

    return false;
  }

  void previousPage() {
    if (currentIndex.value == 0 && turning != 3) switchComic(index - 1);
    pageController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.linear);
  }

  void nextPage() {
    if (countPage == currentIndex.value + 1 && turning != 3)
      switchComic(index + 1);
    pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.linear);
  }

  Widget getLayout(BoxConstraints constraints) {
    if (turning == 1 || turning == 2) {
      bool isDouble = false;
      if ((layout == 2) ||
          (layout == 1 && constraints.maxWidth > MyApp.width)) {
        isDouble = true;
      }
      return pageWidget(isDouble, constraints);
    } else {
      return rollingWidget();
    }
  }

  Widget rollingWidget() {
    return ListView.builder(
      itemBuilder: (context, index) {
        currentIndex.value = index;
        return imageModule(list[index]);
      },
      itemCount: list.length,
    );
  }

  Widget pageWidget(bool isDouble, BoxConstraints constraints) {
    countPage = isDouble ? (list.length / 2).floor() : list.length;
    return Listener(
        onPointerSignal: (PointerSignalEvent event) {
          if (event is PointerScrollEvent) {
            // 判断鼠标滚动
            if (event.scrollDelta.dy < 0) {
              previousPage();
            } else if (event.scrollDelta.dy > 0) {
              nextPage();
            }
          }
        },
        child: PageView.builder(
          controller: pageController,
          scrollDirection: turning == 2 ? Axis.vertical : Axis.horizontal,
          onPageChanged: (value) {
            currentIndex.value = value;
          },
          itemCount: countPage,
          itemBuilder: (BuildContext context, int index) {
            return isDouble
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: imageModule(list[index * 2],
                                  height: double.infinity,
                                  boxFit: BoxFit.fitHeight))),
                      if (index * 2 + 1 <= list.length)
                        Expanded(
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: imageModule(list[index * 2 + 1],
                                    height: double.infinity,
                                    boxFit: BoxFit.fitHeight))),
                    ],
                  )
                : imageModule(list[index],
                    boxFit: constraints.maxWidth > MyApp.width
                        ? BoxFit.fitHeight
                        : BoxFit.fitWidth);
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: ref
            .read(comicListStateProvider.notifier)
            .getPageList(comicItem.filePath),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            list = List<String>.from(snapshot.data);
            return PopScope(
                onPopInvokedWithResult: (bool didPop, Object? result) =>
                    updateNumber(isChange: true),
                child: LayoutBuilder(builder: (context, constraints) {
                  return Listener(
                      onPointerHover: (value) {
                        isShow.value = true;
                        _resetIdleTimer();
                      },
                      onPointerMove: (value) {
                        isShow.value = true;
                      },
                      onPointerDown: (details) {
                        if (turning != 3 && !isShow.value) {
                          double screenWidth =
                              MediaQuery.of(context).size.width;
                          double clickX = details.localPosition.dx;
                          if (clickX < screenWidth / 3) {
                            previousPage();
                          } else if (clickX < 2 * screenWidth / 3) {
                            isShow.value = !isShow.value;
                          } else {
                            nextPage();
                          }
                        }
                      },
                      child: Stack(
                        children: [
                          ValueListenableBuilder(
                              valueListenable: isChange,
                              builder: (context, value, child) {
                                return Container(
                                  color: Colors.black,
                                  child: Center(
                                    child: getLayout(constraints),
                                  ),
                                );
                              }),
                          Positioned(
                              top: 0,
                              left: 0,
                              child: Listener(
                                child: ValueListenableBuilder(
                                    valueListenable: isShow,
                                    builder: (context, value, child) {
                                      return AnimatedOpacity(
                                          opacity: value ? 1 : 0,
                                          duration:
                                              const Duration(milliseconds: 300),
                                          child: Container(
                                              width: constraints.maxWidth,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              color: Theme.of(context)
                                                  .cardColor
                                                  .withOpacity(0.8),
                                              child: Row(
                                                children: [
                                                  IconButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                      icon: const Icon(Icons
                                                          .arrow_back_ios_new)),
                                                  Expanded(
                                                    child: Text(
                                                      comicItem.name,
                                                      style: const TextStyle(
                                                          fontSize: 18),
                                                      maxLines: 2,
                                                    ),
                                                  )
                                                ],
                                              )));
                                    }),
                              )),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Listener(
                                child: ValueListenableBuilder(
                                    valueListenable: isShow,
                                    builder: (context, value, child) {
                                      return AnimatedOpacity(
                                          opacity: value ? 1 : 0,
                                          duration:
                                              const Duration(milliseconds: 300),
                                          child: Container(
                                              width: constraints.maxWidth,
                                              padding: const EdgeInsets.all(10),
                                              color: Theme.of(context)
                                                  .cardColor
                                                  .withOpacity(0.8),
                                              child: ValueListenableBuilder(
                                                  valueListenable: currentIndex,
                                                  builder:
                                                      (context, value, child) {
                                                    return Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              IconButton(
                                                                  onPressed: () =>
                                                                      pageController
                                                                          .jumpToPage(
                                                                              0),
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .keyboard_double_arrow_left_outlined)),
                                                              Expanded(
                                                                  child:
                                                                      Listener(
                                                                onPointerDown:
                                                                    (event) {},
                                                                child: Slider(
                                                                    label:
                                                                        "${currentIndex.value}",
                                                                    value: currentIndex
                                                                        .value
                                                                        .toDouble(),
                                                                    onChanged:
                                                                        (value) {
                                                                      pageController
                                                                          .jumpToPage(
                                                                              value.toInt());
                                                                    },
                                                                    max: countPage
                                                                            .toDouble() -
                                                                        1),
                                                              )),
                                                              IconButton(
                                                                  onPressed: () =>
                                                                      pageController.jumpToPage(
                                                                          countPage -
                                                                              1),
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .keyboard_double_arrow_right_outlined)),
                                                            ]),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 5),
                                                          child: Row(children: [
                                                            const Text("页面张数:"),
                                                            SizedBox(
                                                                width: 200,
                                                                child:
                                                                    DropdownMenu(
                                                                        width:
                                                                            200,
                                                                        dropdownMenuEntries:
                                                                            ListTitleWidget.buildMenuList(
                                                                                layoutMap),
                                                                        initialSelection:
                                                                            layout,
                                                                        onSelected:
                                                                            (value) {
                                                                          layout =
                                                                              value!;
                                                                          isChange.value =
                                                                              !isChange.value;
                                                                        }))
                                                          ]),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 5),
                                                          child: Row(children: [
                                                            const Text("阅读方式:"),
                                                            SizedBox(
                                                                width: 200,
                                                                child:
                                                                    DropdownMenu(
                                                                  width: 200,
                                                                  dropdownMenuEntries:
                                                                      ListTitleWidget
                                                                          .buildMenuList(
                                                                              turningMap),
                                                                  initialSelection:
                                                                      turning,
                                                                  onSelected:
                                                                      (value) {
                                                                    turning =
                                                                        value!;
                                                                    isChange.value =
                                                                        !isChange
                                                                            .value;
                                                                  },
                                                                ))
                                                          ]),
                                                        ),
                                                        Text(
                                                          "当前阅读进度:${currentIndex.value + 1}/$countPage",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 16),
                                                        ),
                                                        // Text(
                                                        //   "${double.parse((currentIndex.value / _list.length).toStringAsFixed(3))}",
                                                        //   style:
                                                        //   const TextStyle(fontSize: 16),
                                                        // ),
                                                      ],
                                                    );
                                                  })));
                                    })),
                          )
                        ],
                      ));
                }));
          } else {
            return const Align(
              child: SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }

  void switchComic(int index) async {
    if (index == -1) {
      EasyLoading.showToast('没有上一章了', duration: const Duration(seconds: 1));
      return;
    } else if (comicListCount == index) {
      EasyLoading.showToast('这是最后一章', duration: const Duration(seconds: 1));
      return;
    }

    if (!isSwitch) {
      isSwitch = true;
      EasyLoading.showToast('再点击一次切换上一章或下一章',
          duration: const Duration(seconds: 1));
    } else {
      updateNumber();
      ComicItem? item =
          await ref.read(comicListStateProvider.notifier).getByIndex(index);
      if (item != null) {
        setState(() {
          comicItem = item;
          this.index = index;
          currentIndex.value = 0;
        });
      }
    }
    _timer = Timer(const Duration(seconds: 1), () => isSwitch = false);
  }

  void _resetIdleTimer() {
    // 如果之前有计时器，取消它
    isShowTimer?.cancel();

    // 设置一个新的计时器，假设 2 秒后将 currentValue 设为 false
    isShowTimer = Timer(const Duration(seconds: 2), () {
      isShow.value = false;
    });
  }

  void updateNumber({isChange = false}) {
    ref.read(comicListStateProvider.notifier).updateNumber(
        comicItem.id,
        comicItem.filesId,
        countPage == currentIndex.value + 1,
        currentIndex.value,
        index,
        isChange: isChange);
  }

  Widget imageModule(String filePath,
      {double? width, double? height, BoxFit? boxFit}) {
    String originalString = "${HttpApi.options.baseUrl}$filePath";
    String path = originalString.replaceFirst('\\', '');
    path = path.replaceAll('\\', '/');

    return CachedNetworkImage(
      width: width,
      height: width,
      imageUrl: path,
      progressIndicatorBuilder: (context, url, downloadProgress) => SizedBox(
          width: 150,
          height: 150,
          child: CircularProgressIndicator(value: downloadProgress.progress)),
      httpHeaders: map,
      errorWidget: (context, url, error) {
        CachedNetworkImage.evictFromCache(url);
        return const Icon(Icons.folder, size: 150);
      },
      fit: boxFit ?? BoxFit.cover,
    );
  }
}
