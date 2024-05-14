import 'package:flutter/material.dart';
import 'package:resourcemanager/common/Global.dart';

import '../main.dart';
import 'LeftDrawer.dart';

class TopTool extends StatefulWidget {
  const TopTool({super.key, required this.widget, required this.title});

  final Widget widget;
  final String title;

  @override
  State<StatefulWidget> createState() => TopToolState();
}

class TopToolState extends State<TopTool> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var width = constraints.maxWidth;
        if (width < MyApp.width) {
          return mobileWidget(
            widget: widget.widget,
            title: widget.title,
          );
        } else {
          return widget.widget;
        }
      },
    );
  }
}

class mobileWidget extends StatelessWidget {
  const mobileWidget({
    super.key,
    required this.widget,
    required this.title,
  });

  final Widget widget;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [
          Offstage(
            offstage: true,
          )
        ],
        title: Text(title),
        centerTitle: true,
      ),
      drawer: LeftDrawer(
        width: 250,
      ),
      body: widget,
    );
  }
}

class desktopWidget extends StatelessWidget {
  const desktopWidget({
    super.key,
    required this.widget,
  });

  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget
    );
  }
}
