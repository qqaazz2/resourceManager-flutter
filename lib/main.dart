import 'dart:convert';
import 'dart:js';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:resourcemanager/routes/books/BooksPage.dart';
import 'package:resourcemanager/routes/HomePage.dart';
import 'package:resourcemanager/routes/LoginPage.dart';
import 'package:resourcemanager/widgets/LeftDrawer.dart';
import 'package:resourcemanager/widgets/TopTool.dart';
import 'common/Global.dart';

void main() => Global.init().then((value) => runApp(MyApp()));
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  MyApp({super.key});

  static double width = 600;
  static String current = "/";
  final _rootNavigatorKey = GlobalKey<NavigatorState>();
  final _sectionNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoRouter router;

  @override
  void initState() {
    super.initState();
    router = GoRouter(
      navigatorKey: widget._rootNavigatorKey,
      initialLocation: '/',
      routes: [
        GoRoute(
            path: "/login",
            name: "login",
            builder: (context, state) => const LoginPage()),
        StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return MainApp(
                navigationShell: navigationShell,
              );
            },
            branches: [
              StatefulShellBranch(
                  navigatorKey: widget._sectionNavigatorKey,
                  routes: [
                    GoRoute(
                        path: "/",
                        name: "home",
                        builder: (context, state) => const HomePage()),
                  ]),
              StatefulShellBranch(routes: [
                GoRoute(
                    path: "/books",
                    name: "books",
                    builder: (context, state) => const BooksPage()),
              ])
            ]),
      ],
      redirect: (context, state) {
        if (Global.token.isEmpty) return '/login';
        return null;
      },
    );
  }

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
      // onGenerateRoute: (RouteSettings settings) {
      //   final String? name = settings.name;
      //   late Function pageContentBuilder;
      //   final Route route;
      //
      //   if (settings.arguments != null) {
      //     route = MaterialPageRoute(
      //         builder: (context) =>
      //             pageContentBuilder(context, arguments: settings.arguments));
      //   } else {
      //     route = MaterialPageRoute(
      //         builder: (context) => pageContentBuilder(context));
      //   }
      //   current = name!;
      //
      //   if (MediaQuery.of(context).size.width > width && !["/","/login"].contains(name)) {
      //     return null;
      //   }
      //
      //   return route;
      // },
      builder: EasyLoading.init(),
    );
  }
}

class MainApp extends StatefulWidget {
  MainApp({super.key, required this.navigationShell});

  StatefulNavigationShell navigationShell;

  @override
  State<StatefulWidget> createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < MyApp.width) {
        Item item = Global.itemList[widget.navigationShell.currentIndex];
        widget.navigationShell;
        return TopTool(widget: widget.navigationShell, title: item.title);
      } else {
        return Scaffold(
          key: MyApp.scaffoldKey,
          endDrawer: const Drawer(),
          body: Row(children: [
            NavigationRail(
              destinations: Global.itemList
                  .map((e) => NavigationRailDestination(
                      icon: e.icon, label: Text(e.title)))
                  .toList(),
              selectedIndex: widget.navigationShell.currentIndex,
              extended: true,
              onDestinationSelected: (int index) {
                widget.navigationShell.goBranch(
                  index,
                  initialLocation: index == widget.navigationShell.currentIndex,
                );
              },
            ),
            Expanded(child: widget.navigationShell)
          ]),
        );
      }
    });
  }
}
