import 'dart:io';

import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:game/build_flavor.dart';
import 'package:game/data.dart';
import 'package:game/game/controller.dart';
import 'package:game/game/page_game_entry.dart';
import 'package:game/http/http.dart';
import 'package:game/save_image/save_image_controller.dart';
import 'package:game/ui.dart';
import 'package:get/get.dart';
import 'package:ilp_file_codec/ilp_codec.dart';
import 'package:oktoast/oktoast.dart';
import 'package:steamworks/steamworks.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

import 'pages/explorer/controller.dart';
import 'pages/explorer/page_ilp_explorer.dart';
import 'pages/game/page_game.dart';
import 'pages/ilp_editor/controller.dart';
import 'pages/ilp_editor/page_ilp_editor.dart';
import 'pages/page_about.dart';
import 'pages/page_test.dart';
import 'pages/save_image/page_save_image.dart';
import 'pages/settings/page_settings.dart';
import 'ui.dart';
import 'utils/asset_path.dart';
import 'utils/sound.dart';
import 'utils/update_window_title.dart';

final steamAppId = [2550370];

runMain(List<String> args) async {
  if (env.isSteam) {
    if (!steamAppId.contains(SteamClient.instance.steamUtils.getAppId())) {
      return exit(-1);
    }
  }
  print('启动参数 $args');
  WidgetsFlutterBinding.ensureInitialized();
  await WindowsSingleInstance.ensureSingleInstance(
    args,
    "gzlock.find_up.windows",
    onSecondWindow: (args) => _openFromArgs(args),
  );
  await Data.init();
  await Http.init();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = WindowOptions(
    minimumSize: Size(800, 600),
    center: true,
    skipTaskbar: false,
    title: 'Find Up!',
  );
  await windowManager.setIcon(assetPath(paths: ['assets', 'icon.ico']));
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    updateWindowTitle();
  });

  runApp(MyApp(args: args));
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class MyApp extends StatelessWidget {
  final List<String> args;

  const MyApp({super.key, required this.args});

  static final _defaultLightColorScheme = ColorScheme.fromSwatch(
    primarySwatch: Colors.blueGrey,
  );

  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(
    primarySwatch: Colors.blueGrey,
    brightness: Brightness.dark,
  );

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return OKToast(
        position: ToastPosition.bottom,
        textAlign: TextAlign.start,
        textPadding: EdgeInsets.all(8),
        dismissOtherOnShow: true,
        child: GetMaterialApp(
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: Data.locale,
          translations: WindowsUI(),
          supportedLocales: [Locale("zh", "CN"), Locale("en", "US")],
          fallbackLocale: Locale("en", "US"),
          debugShowCheckedModeBanner: false,
          scrollBehavior: MyCustomScrollBehavior(),
          title: UI.findUp.tr,
          theme: ThemeData(
            useMaterial3: false,
            colorScheme: lightColorScheme ?? _defaultLightColorScheme,
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(),
            ),
            // fontFamily: 'Source',
          ).useSystemChineseFont(),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(),
            ),
          ).useSystemChineseFont(),
          transitionDuration: Duration.zero,
          initialRoute: '/',
          getPages: [
            GetPage(name: '/', page: () => MyHomePage(args: args)),
            GetPage(
              name: '/explorer',
              page: () => PageILPExplorer(),
              binding: BindingsBuilder(() {
                Get.put(ILPExplorerController(ExplorerMode.openFile));
              }),
            ),
            GetPage(
              name: '/game',
              page: () => PageGame(tag: Get.arguments['tag']),
              popGesture: false,
              preventDuplicates: true,
              binding: BindingsBuilder(() {
                Get.put(
                  GameController(
                    ilp: Get.arguments['ilp'],
                    index: Get.arguments['index'],
                    timeMode: Get.arguments['timeMode'],
                    allowPause: Get.arguments['allowPause'],
                    allowDebug: Get.arguments['allowDebug'],
                    sound: Sound.instance,
                  ),
                  tag: Get.arguments['tag'],
                );
              }),
            ),
            GetPage(
              name: '/editor',
              page: () => PageILPEditor(),
              binding: BindingsBuilder(() {
                Get.put(ILPEditorController());
              }),
            ),
            GetPage(
              name: '/save',
              page: () => PageSaveImage(),
              binding: BindingsBuilder(() {
                Get.put(SaveImageController(
                  info: Get.arguments['info'],
                  layer: Get.arguments['layer'],
                ));
              }),
              preventDuplicates: true,
            ),
            GetPage(name: '/about', page: () => PageAbout()),
            GetPage(name: '/settings', page: () => PageSettings()),
            GetPage(name: '/test', page: () => PageTest()),
          ],
        ),
      );
    });
  }
}

class MyHomePage extends StatelessWidget {
  final List<String> args;

  MyHomePage({super.key, required this.args}) {
    _openFromArgs(args);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      return Scaffold(
        body: Stack(
          children: [
            Positioned(
              left: -350,
              bottom: -350,
              child: Transform.scale(
                scale: 0.7,
                child: Transform.rotate(
                  angle: 0.5,
                  child: Opacity(
                    opacity: 0.1,
                    child: Image.asset(
                      'assets/images/icon_transparent.png',
                      package: 'game',
                    ),
                  ),
                ),
              ),
            ),
            DropTarget(
              onDragEntered: (_) {
                Get.dialog(
                  Material(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: Text(
                        WindowsUI.releaseMouseToOpenFile.tr,
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      ),
                    ),
                  ),
                  barrierDismissible: false,
                );
              },
              onDragExited: (_) {
                Get.back();
              },
              onDragDone: (_) {
                if (_.files.isEmpty) {
                  return;
                } else if (_.files.length > 1) {
                  showToast('一次拖放只能打开一个ilp文件');
                }
                _openILP(_.files.first.path);
              },
              child: Center(
                child: SizedBox(
                  width: 400,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        ListTile(
                          title: Text(UI.startGame.tr),
                          onTap: () => Get.toNamed('/explorer'),
                        ),
                        ListTile(
                          title: Text(WindowsUI.ilpEditor.tr),
                          onTap: () => Get.toNamed('/editor'),
                        ),
                        ListTile(
                          title: Text(UI.settings.tr),
                          onTap: () => Get.toNamed('/settings'),
                        ),
                        ListTile(
                          title: Text(UI.about.tr),
                          onTap: () => Get.toNamed('/about'),
                        ),
                        ListTile(
                          title: Text(UI.exit.tr),
                          onTap: () => exit(0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (env.isSteam)
              Positioned(
                bottom: 10,
                right: 10,
                child: Text(
                  'Steam Version\n'
                  'App ${SteamClient.instance.steamUtils.getAppId()}\n'
                  // 'user ${SteamClient.instance.steamUser.getSteamId()}\n'
                  '${constrains.maxWidth} x ${constrains.maxHeight}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.2),
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        floatingActionButton: env.isProd
            ? null
            : FloatingActionButton(
                onPressed: () => Get.toNamed('/test'),
                child: Text('test'),
              ),
      );
    });
  }
}

_openFromArgs(List<String>? args) async {
  if (args == null || args.isEmpty) return;
  _openILP(args.first);
}

_openILP(String path) async {
  final ilp = await ILP.fromFile(path);
  try {
    if (await ilp.isILP) {
      PageGameEntry.play(ilp);
    } else {
      showToast('只支持ilp格式文件');
    }
  } on ILPConfigException catch (e) {
    showToast('文件打开失败 ${e.message}');
  }
}
