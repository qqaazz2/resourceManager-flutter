import 'package:flutter/material.dart';
import 'package:resourcemanager/common/Global.dart';
import 'package:resourcemanager/widgets/SetBaseUrl.dart';

import '../widgets/TopTool.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    if (Global.baseUrl.isEmpty) {
      // 这里使用 WidgetsBinding 来延迟执行 showDialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
       Global.showSetBaseUrlDialog(context);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return TopTool(
        title: "首页",
        child: ElevatedButton(
            child: const Text("退出"), onPressed: () => Global.logout(context)));
  }
}
