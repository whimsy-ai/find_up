import 'dart:io';

import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:game/build_flavor.dart';
import 'package:game/data.dart';
import 'package:game/discord_link.dart';
import 'package:game/explorer/ilp_file.dart';
import 'package:game/game/game_mode.dart';
import 'package:game/game/page_game_entry.dart';
import 'package:game/game/resources.dart';
import 'package:game/http/http.dart';
import 'package:get/get.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:ilp_file_codec/ilp_codec.dart';
import 'package:oktoast/oktoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:steamworks/steamworks.dart';
import 'package:ui/ui.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

import 'pages/challenge/challenge_editor_controller.dart';
import 'pages/challenge/page_challenge_editor.dart';
import 'pages/challenge/page_challenge_explorer.dart';
import 'pages/challenge/page_play_challenge.dart';
import 'pages/challenge/pc_game_controller.dart';
import 'pages/challenge/random_challenge.dart';
import 'pages/explorer/ilp_explorer_controller.dart';
import 'pages/explorer/page_ilp_explorer.dart';
import 'pages/ilp_editor/ilp_editor_controller.dart';
import 'pages/ilp_editor/page_ilp_editor.dart';
import 'pages/page_about.dart';
import 'pages/page_settings.dart';
import 'pages/page_test.dart';
import 'pages/page_test2.dart';
import 'pages/save_image/page_save_image.dart';
import 'pages/save_image/pc_save_image_controller.dart';
import 'utils/asset_path.dart';
import 'utils/update_window_title.dart';
import 'utils/window_frame.dart';

const steamAppId = 2550370;

Future runMain(List<String> args) async {
  if (env.isSteam) {
    if (steamAppId != SteamClient.instance.steamUtils.getAppId()) {
      return exit(-1);
    }
    SteamClient.instance.steamUserStats.requestCurrentStats();
  }
  print('启动参数 $args');
  WidgetsFlutterBinding.ensureInitialized();
  packageInfo = await PackageInfo.fromPlatform();
  await hotKeyManager.unregisterAll();
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
    titleBarStyle: TitleBarStyle.hidden,
    title: 'Find Up!',
  );
  await windowManager.setIcon(assetPath(paths: ['assets', 'icon.ico']));
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    updateWindowTitle();
  });
  runApp(MyApp(args: args));

  /// 预读取游戏资源
  Resources.init();
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class MyApp extends StatefulWidget {
  final List<String> args;

  const MyApp({super.key, required this.args});

  static final _lightScheme = ColorScheme.fromSwatch(
    primarySwatch: Colors.blueGrey,
  );

  static final _darkScheme = ColorScheme.fromSwatch(
    primarySwatch: Colors.blueGrey,
    brightness: Brightness.dark,
  );

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? _home;

  @override
  Widget build(BuildContext context) {
    _home ??= MyHomePage(args: widget.args);
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
          translations: UI(),
          fallbackLocale: Locale('en'),
          debugShowCheckedModeBanner: false,
          scrollBehavior: MyCustomScrollBehavior(),
          title: UI.findUp.tr,
          themeMode: Data.isDark ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme ?? MyApp._lightScheme,
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(),
            ),
            // fontFamily: 'Source',
          ).useSystemChineseFont(Brightness.light),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme ?? MyApp._darkScheme,
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(),
            ),
          ).useSystemChineseFont(Brightness.dark),
          transitionDuration: Duration.zero,
          home: _home,
        ),
      );
    });
  }
}

class MyHomePage extends StatefulWidget {
  final List<String> args;

  MyHomePage({super.key, required this.args}) {
    _openFromArgs(args);
  }

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VirtualWindowFrame(
          child: Navigator(
        key: Get.nestedKey(1),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          final arguments = settings.arguments as dynamic;
          var route = switch (settings.name) {
            '/explorer' => GetPageRoute(
                page: () => PageILPExplorer(),
                binding: BindingsBuilder(() {
                  Get.put(ILPExplorerController(ExplorerMode.openFile));
                }),
              ),
            '/editor' => GetPageRoute(
                page: () => PageILPEditor(),
                binding: BindingsBuilder(() {
                  Get.put(ILPEditorController());
                }),
              ),
            '/save' => GetPageRoute(
                page: () => PageSaveImage(),
                binding: BindingsBuilder(() {
                  Get.put(PCSaveImageController(
                    file: arguments['file'],
                    index: arguments['index'],
                  ));
                }),
              ),
            '/about' => GetPageRoute(page: () => PageAbout()),
            '/settings' => GetPageRoute(page: () => PageSettings()),
            '/test' => GetPageRoute(page: () => PageTest()),
            '/test2' => GetPageRoute(page: () => PageTest2()),

            /// for steam
            '/create_challenge' => GetPageRoute(
                page: () => PageCreateChallenge(),
                binding: BindingsBuilder(() {
                  Get.put(ChallengeEditorController());
                }),
              ),
            '/challenge_explorer' => GetPageRoute(
                page: () => PageChallengeExplorer(),
                binding: BindingsBuilder(() {
                  Get.put(SteamExplorerController(multipleSelect: true));
                }),
              ),
            '/play_challenge' => GetPageRoute(
                settings: settings,
                page: () => PagePlayChallenge<PCGameController>(),
                binding: BindingsBuilder(() {
                  Get.put(PCGameController(
                    files: arguments['files'],
                    mode: arguments['mode'],
                    ilpIndex: arguments['ilpIndex'],
                  ));
                }),
              ),
            _ => GetPageRoute(
                page: () => _HomeWidget(),
              ),
          };
          return GetPageRoute(
            settings: settings,
            page: route.page,
            binding: route.binding,
            transitionDuration: Duration.zero,
          );
        },
      )),
    );
  }
}

class _HomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WindowFrame(
      backIcon: false,
      title: '${UI.findUp.tr} v${packageInfo.version}',
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
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
                        UI.releaseMouseToOpenFile.tr,
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
                  return;
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
                        /// 挑战
                        if (env.isSteam)
                          ListTile(
                            title: Text(UI.steamChallenge.tr),
                            onTap: () => Get.toNamed(
                              '/challenge_explorer',
                              id: 1,
                            ),
                          ),
                        if (kDebugMode || !env.isSteam)
                          ListTile(
                            title: Text(UI.randomChallenge.tr),
                            onTap: RandomChallengeDialog.show,
                          ),
                        ListTile(
                          title: Text(UI.gallery.tr),
                          onTap: () => Get.toNamed(
                            '/explorer',
                            id: 1,
                          ),
                        ),
                        ListTile(
                          title: Text(UI.ilpEditor.tr),
                          onTap: () => Get.toNamed(
                            '/editor',
                            id: 1,
                          ),
                        ),
                        ListTile(
                          title: Text(UI.settings.tr +
                              (Data.locale.languageCode == 'en'
                                  ? ''
                                  : ' / Settings')),
                          onTap: () => Get.toNamed(
                            '/settings',
                            id: 1,
                          ),
                        ),
                        ListTile(
                          title: Text(
                            UI.about.tr,
                          ),
                          onTap: () => Get.toNamed(
                            '/about',
                            id: 1,
                          ),
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
            Positioned(
              left: 10,
              bottom: 10,
              child: Text(
                '${env.isSteam ? 'Steam' : 'MS store'} version\n',
                style: TextStyle(
                  color: Theme.of(context).highlightColor,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Wrap(
          spacing: 10,
          children: [
            DiscordLink(),
            if (kDebugMode) ...[
              FloatingActionButton(
                onPressed: () async {
                  Get.toNamed(
                    '/test',
                    id: 1,
                  );
                },
                child: Text('test1'),
              ),
              FloatingActionButton(
                onPressed: () async {
                  Get.toNamed(
                    '/test2',
                    id: 1,
                  );
                },
                child: Text('test2'),
              ),
            ],
          ],
        ),
      ),
    );
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
      PageGameEntry.play([ILPFile(File(path))], mode: GameMode.gallery);
    } else {
      showToast('只支持ilp格式文件');
    }
  } on ILPConfigException catch (e) {
    showToast('文件打开失败 ${e.message}');
  }
}
