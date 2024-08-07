import 'package:flutter/material.dart';
import 'package:resourcemanager/common/Global.dart';

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(child: const Text("退出"), onPressed: () => Global.logout(context));
  }
}
