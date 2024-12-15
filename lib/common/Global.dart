import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resourcemanager/widgets/LeftDrawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Global {
  static late String token;
  static late SharedPreferences preferences;
  static List<Item> itemList = [];
  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();
    preferences = await SharedPreferences.getInstance();
    token = preferences.getString("token") ?? "";
    
    itemList.add(Item(title: "首页", path: "/", icon: const Icon(Icons.home)));
    itemList.add(Item(title: "图书", path: "/books", icon: const Icon(Icons.menu_book)));
    itemList.add(Item(title: "图片", path: "/picture", icon: const Icon(Icons.image)));
    itemList.add(Item(title: "漫画", path: "/comic", icon: const Icon(Icons.filter)));
    itemList.add(Item(title: "影音", path: "/video", icon: const Icon(Icons.video_collection)));
    itemList.add(Item(title: "游戏", path: "/games", icon: const Icon(Icons.games)));
    itemList.add(Item(title: "设置", path: "/setting", icon: const Icon(Icons.settings)));
    itemList.add(Item(title: "关于我的", path: "/aboutMe", icon: const Icon(Icons.person)));
  }

  static saveLoginStatus(String token){
    preferences.setString("token", token);
    Global.token = token;
  }

  static logout(BuildContext context){
    preferences.remove("token");
    GoRouter.of(context).go("/login");
  }
}
