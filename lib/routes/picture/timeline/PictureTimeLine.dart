import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resourcemanager/main.dart';
import 'package:resourcemanager/models/picture/PictureList.dart';
import 'package:resourcemanager/routes/picture/PictureDrawer.dart';
import 'package:resourcemanager/routes/picture/PictureItem.dart';
import 'package:resourcemanager/state/picture/PictureState.dart';
import 'package:resourcemanager/widgets/ToolBar.dart';
import 'package:resourcemanager/widgets/TopTool.dart';

class PictureTimeLine extends ConsumerStatefulWidget {
  const PictureTimeLine({super.key});

  @override
  ConsumerState<PictureTimeLine> createState() => PictureTimeLineState();
}

class PictureTimeLineState extends ConsumerState<PictureTimeLine>
    with TickerProviderStateMixin {
  late TabController _tabController;
  ValueNotifier<int> index = ValueNotifier(0);
  final Map<int, String> map = {0: "年", 1: "月", 2: "日"};
  int skipNum = 0;
  Map<String, List<int>> years = {};
  Map<String, List<int>> months = {};
  Map<String, List<int>> days = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    getData();
  }

  void getData() async {
    await ref.read(pictureStateProvider("000").notifier).getTimeLineList();
    final state = ref.watch(pictureStateProvider("000"));
    int skip = skipNum * 50;
    List<PictureData> list = state.list.skip(skip).toList();
    for (var action in list) {
      DateTime dateTime = DateTime.parse(action.createTime!);
      String yearKey = "${dateTime.year}年";
      if (years.containsKey(yearKey)) {
        years[yearKey]?.add(skip);
      } else {
        years[yearKey] = [skip];
      }

      String monthKey = "${dateTime.year}年${dateTime.month}月";
      if (months.containsKey(monthKey)) {
        months[monthKey]?.add(skip);
      } else {
        months[monthKey] = [skip];
      }

      String dayKey = "${dateTime.year}年${dateTime.month}月${dateTime.day}日";
      if (days.containsKey(dayKey)) {
        days[dayKey]?.add(skip);
      } else {
        days[dayKey] = [skip];
      }
      skip += 1;
    }
    isLoading = true;
    skipNum++;
  }

  int getNum(constraints) {
    int num = 10;
    if (1300 > constraints.maxWidth && constraints.maxWidth > MyApp.width) {
      num = 6;
    } else if (2160 > constraints.maxWidth && constraints.maxWidth > 1300) {
      num = 10;
    } else if (constraints.maxWidth < MyApp.width) {
      num = 3;
    }
    return num;
  }

  @override
  Widget build(BuildContext context) {
    final pictureState = ref.watch(pictureStateProvider("000"));
    return TopTool(
      title: "图片",
      endDrawer: const PictureDrawer(id: "000"),
      floatingActionButton: Builder(builder: (context) {
        return FloatingActionButton(
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
          },
          child: const Icon(Icons.list),
        );
      }),
      child: Column(
        children: [
          if (MediaQuery.of(context).size.width > MyApp.width)
            ToolBar(
              widgetList: [
                SizedBox(
                  width: 300,
                  child: ValueListenableBuilder(
                      valueListenable: index,
                      builder: (context, value, child) {
                        return TabBar(
                          controller: _tabController,
                          indicator: const BoxDecoration(),
                          indicatorWeight: 0,
                          padding: EdgeInsets.zero,
                          onTap: (value) => index.value = value,
                          tabs: [0, 1, 2].map((item) {
                            return Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: item == index.value
                                    ? Theme.of(context)
                                        .buttonTheme
                                        .colorScheme!
                                        .primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                child: Text(
                                  map[item]!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: index.value == item
                                        ? Colors.white
                                        : Theme.of(context)
                                            .buttonTheme
                                            .colorScheme!
                                            .primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                ),
                IconButton(
                  onPressed: () => GoRouter.of(context).push("/picture/random"),
                  icon: const Icon(Icons.shuffle_sharp),
                  tooltip: "随机十张图片",
                ),
                IconButton(
                  onPressed: () => context.go("/picture"),
                  icon: const Icon(Icons.folder),
                  tooltip: "切换为文件夹",
                ),
                IconButton(
                    onPressed: () {
                      pictureState.page = 1;
                      pictureState.list = [];
                      getData();
                    },
                    icon: const Icon(Icons.refresh),
                    tooltip: "刷新"),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.featured_play_list_sharp),
                    tooltip: "扫描图片文件夹"),
              ],
            ),
          Expanded(
              child: GestureDetector(
            onScaleUpdate: (ScaleUpdateDetails details) {
              if (details.scale > 1 && index.value != 2) {
                index.value++;
              } else if (details.scale < 1 && index.value != 0) {
                index.value--;
              }
            },
            child: ValueListenableBuilder(
                valueListenable: index,
                builder: (content, value, child) {
                  Map<String, List<int>> data;
                  int count = 0;
                  if (value == 0) {
                    data = years;
                    count = years.length;
                  } else if (value == 1) {
                    data = months;
                    count = months.length;
                  } else {
                    data = days;
                    count = days.length;
                  }
                  return LayoutBuilder(builder: (context, constraints) {
                    int num = getNum(constraints);
                    return NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (pictureState.list.length < pictureState.count &&
                              notification.metrics.atEdge &&
                              notification.metrics.pixels ==
                                  notification.metrics.maxScrollExtent &&
                              isLoading) {
                            isLoading = false;
                            getData();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            String key = data.keys.elementAt(index);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    key,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Wrap(
                                    children: data[key]!.map((value) {
                                      double size = constraints.maxWidth / num;
                                      return Container(
                                        padding: const EdgeInsets.all(2),
                                        width: size,
                                        height: size,
                                        child: PictureItem(
                                          id: "000",
                                          index: value,
                                          data: pictureState.list[value],
                                          show: false,
                                          isPc: true,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                )
                              ],
                            );
                          },
                          itemCount: count,
                        ));
                  });
                }),
          ))
        ],
      ),
    );
  }
}
