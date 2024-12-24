import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resourcemanager/entity/UserInfo.dart';
import 'package:resourcemanager/widgets/LeftDrawer.dart';
import 'package:resourcemanager/widgets/SetBaseUrl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Global {
  static late String token;
  static late SharedPreferences preferences;
  static List<Item> itemList = [];

  static late Setting setting;

  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();
    preferences = await SharedPreferences.getInstance();
    token = preferences.getString("token") ?? "";
    String baseUrl = preferences.getString("baseUrl") ?? "";
    bool light = false;
    bool? getLight = preferences.getBool("light");
    if (getLight == null) {
      preferences.setBool("light", light);
    } else {
      light = getLight;
    }

    setting = Setting(baseUrl: baseUrl, light: light);

    itemList.add(Item(title: "首页", path: "/", icon: const Icon(Icons.home)));
    itemList.add(
        Item(title: "图书", path: "/books", icon: const Icon(Icons.menu_book)));
    itemList.add(
        Item(title: "图片", path: "/picture", icon: const Icon(Icons.image)));
    itemList
        .add(Item(title: "漫画", path: "/comic", icon: const Icon(Icons.filter)));
    itemList.add(Item(
        title: "影音", path: "/video", icon: const Icon(Icons.video_collection)));
    itemList
        .add(Item(title: "游戏", path: "/games", icon: const Icon(Icons.games)));
    itemList.add(
        Item(title: "设置", path: "/setting", icon: const Icon(Icons.settings)));
    // itemList.add(Item(title: "关于我的", path: "/aboutMe", icon: const Icon(Icons.person)));
  }

  static saveLoginStatus(String token,UserInfo userInfo) {
    Global.token = token;
    preferences.setString("token", token);

    setUserInfo(userInfo);
  }

  static setUserInfo(UserInfo userInfo) {
    Global.setting.userInfo = userInfo;
  }

  static logout(BuildContext context) {
    preferences.remove("token");
    GoRouter.of(context).go("/login");
  }

  static setBaseUrl(String url) {
    setting.baseUrl = url;
    preferences.setString("baseUrl", url);
  }

  static showSetBaseUrlDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return SetBaseUrl();
        });
  }

  static setMystery(mystery) {
    setting.userInfo!.mystery = mystery;
  }

  static setLight() {
    setting.light = !setting.light;
    preferences.setBool("light", setting.light);
  }
}

class Setting {
  String baseUrl;
  bool light = false;

  UserInfo? userInfo;

  Setting({this.baseUrl = "", this.light = false, UserInfo? userInfo});

  Setting copyWith({
    String? baseUrl,
    bool? light,
    UserInfo? userInfo,
  }) {
    return Setting(
        baseUrl: baseUrl ?? this.baseUrl,
        light: light ?? this.light,
        userInfo: userInfo ?? this.userInfo);
  }
}
