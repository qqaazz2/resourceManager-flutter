import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:resourcemanager/common/FilesTypeInfo.dart';
import 'package:resourcemanager/common/HttpApi.dart';
import 'package:resourcemanager/entity/setting/Proportion.dart';
import 'package:resourcemanager/state/setting/SettingState.dart';

import '../../../entity/BaseResult.dart';

class SettingPieChart extends ConsumerStatefulWidget {
  const SettingPieChart({super.key, required this.boxConstraints});

  final BoxConstraints boxConstraints;

  @override
  ConsumerState<SettingPieChart> createState() => SettingPieChartState();
}

class SettingPieChartState extends ConsumerState<SettingPieChart> {
  int touchedIndex = 0;
  List<Proportion>? list;
  int count = 0;

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    if (list == null) {
      return const Align(
        child: SizedBox(
          width: 150,
          height: 150,
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("资源类型占比",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: getPicChart(), // 确保中心对齐
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  children: list!.map((value) {
                    return Indicator(
                      index: touchedIndex,
                      color: FilesTypeInfo(value.type).color,
                      text: FilesTypeInfo(value.type).text,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Positioned(
            right: 0,
            child: IconButton(
              onPressed: () => getData(),
              icon: const Icon(Icons.refresh),
              tooltip: "刷新图表",
            ))
      ],
    );
  }

  Widget getPicChart() {
    return AspectRatio(
        aspectRatio: 1, // 强制宽高比为 1:1
        child: LayoutBuilder(builder: (context, constraints) {
          return PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(
                show: false,
              ),
              sectionsSpace: 0,
              centerSpaceRadius: 0,
              sections: showingSections(constraints.maxWidth),
            ),
          );
        }));
  }

  List<PieChartSectionData>? showingSections(double width) {
    if (list == null) return null;
    int index = 0;
    return list?.map((value) {
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? width / 2 : width / 2 - 10;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      index++;

      return PieChartSectionData(
        color: FilesTypeInfo(value.type).color,
        value: (value.count / count),
        title: '${(value.count / count * 100).toStringAsFixed(2)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
        badgePositionPercentageOffset: .98,
      );
    }).toList();
  }

  void getData() async {
    BaseResult baseResult = await HttpApi.request("/setting/proportion",
        (json) => (json as List).map((e) => Proportion.fromJson(e)).toList());
    if (baseResult.code == "2000") {
      setState(() {
        list = baseResult.result;
        count = getTotalCount();
      });
    }
  }

  int getTotalCount() {
    if (list != null) {
      return list!.fold(0, (sum, item) => sum + item.count);
    }
    return 0;
  }
}

class Indicator extends StatelessWidget {
  const Indicator(
      {super.key,
      required this.color,
      required this.text,
      required this.index});

  final Color color;
  final String text;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: color,
          width: 15,
          height: 15,
          margin: const EdgeInsets.only(right: 10),
        ),
        Text(text)
      ],
    );
  }
}
