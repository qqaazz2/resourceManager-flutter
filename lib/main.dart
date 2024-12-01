import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:resourcemanager/entity/book/BookItem.dart';
import 'package:resourcemanager/routes/book/BookRead.dart';
import 'package:resourcemanager/routes/book/SeriesConent.dart';
import 'package:resourcemanager/routes/book/SeriesPage.dart';
import 'package:resourcemanager/routes/books/BooksPage.dart';
import 'package:resourcemanager/routes/HomePage.dart';
import 'package:resourcemanager/routes/LoginPage.dart';
import 'package:resourcemanager/routes/books/details/BooksInfo.dart';
import 'package:resourcemanager/routes/books/details/BooksRead.dart';
import 'package:resourcemanager/routes/picture/PictureDetails.dart';
import 'package:resourcemanager/routes/picture/PicturePage.dart';
import 'package:resourcemanager/routes/picture/PictureRandom.dart';
import 'package:resourcemanager/routes/picture/timeline/PictureTimeLine.dart';
import 'package:resourcemanager/state/BooksState.dart';
import 'package:resourcemanager/state/picture/PictureListState.dart';
import 'package:resourcemanager/widgets/LeftDrawer.dart';
import 'package:resourcemanager/widgets/TopTool.dart';
import 'common/Global.dart';

// void main() => Global.init().then((value) => runApp(MultiProvider(providers: [
//       ChangeNotifierProvider(create: (context) => BooksState()),
//       ChangeNotifierProvider(create: (context) => PictureListState()),
//     ], child: MyApp())));
void main() =>
    Global.init().then((value) => runApp(ProviderScope(child: MyApp())));
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  MyApp({super.key});

  static double width = 600;
  static String current = "/";
  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  final _sectionNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();
  static Widget? drawer;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoRouter router;

  @override
  void initState() {
    super.initState();
    router = GoRouter(
      navigatorKey: MyApp.rootNavigatorKey,
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
                    builder: (context, state) => const SeriesPage(),
                    routes: <RouteBase>[
                      GoRoute(
                          path: "content",
                          name: "booksContent",
                          builder: (context, state) {
                            int seriesId = int.parse(state.uri.queryParameters["seriesId"]!);
                            int filesId = int.parse(state.uri.queryParameters["filesId"]!);
                            int index = int.parse(state.uri.queryParameters["index"]!);
                            return SeriesContent(seriesId: seriesId,filesId: filesId,index:index);
                          }),
                      GoRoute(
                          path: "read",
                          name: "booksRead",
                          builder: (context, state) {
                            int seriesId = int.parse(state.uri.queryParameters["seriesId"]!);
                            BookItem bookItem = state.extra as BookItem;
                            return BookRead(bookItem: bookItem,seriesId: seriesId,);
                          })
                    ]),
              ]),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: "/picture",
                    name: "picture",
                    builder: (context, state) {
                      final String? id = state.uri.queryParameters["id"];
                      return PicturePage(id: id ?? "-1");
                    },
                    // 将 details 作为子路由
                    routes: <RouteBase>[
                      GoRoute(
                          path: "details",
                          name: "pictureDetails",
                          builder: (context, state) {
                            final String? id = state.uri.queryParameters["id"];
                            return PictureDetails(id: id);
                          }),
                      GoRoute(
                          path: "random",
                          name: "PictureRandom",
                          builder: (context, state) {
                            return const PictureRandom();
                          }),
                      GoRoute(
                          path: "timeline",
                          name: "pictureTimeLine",
                          builder: (context, state) {
                            return const PictureTimeLine();
                          }),
                    ],
                  ),
                ],
              )
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
  const MainApp({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<StatefulWidget> createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  bool extended = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // return widget.navigationShell;

      if (constraints.maxWidth < MyApp.width) {
        // Item item = Global.itemList[widget.navigationShell.currentIndex];
        return widget.navigationShell;
      } else {
        return Scaffold(
          key: MyApp.scaffoldKey,
          endDrawer: MyApp.drawer,
          body: Row(children: [
            NavigationRail(
              destinations: Global.itemList
                  .map((e) => NavigationRailDestination(
                      icon: e.icon, label: Text(e.title)))
                  .toList(),
              selectedIndex: widget.navigationShell.currentIndex,
              trailing: IconButton(
                  icon: Icon(extended ? Icons.arrow_back : Icons.arrow_forward),
                  onPressed: () {
                    setState(() {
                      extended = !extended;
                    });
                  }),
              extended: extended,
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
