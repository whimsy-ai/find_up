import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:game/build_flavor.dart';
import 'package:game/data.dart';
import 'package:game/game/controller.dart';
import 'package:game/save_image/save_image_controller.dart';
import 'package:game/ui.dart';
import 'package:get/get.dart';
import 'package:mobile/utils/version.dart';
import 'package:oktoast/oktoast.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'firebase_options.dart';
import 'pages/about/page_about.dart';
import 'pages/explorer/controller.dart';
import 'pages/explorer/page_ilp_explorer.dart';
import 'pages/game/page_game.dart';
import 'pages/page_save_image.dart';
import 'pages/settings/page_settings.dart';
import 'sound.dart';
import 'ui.dart';
import 'utils/landscape.dart';

runMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  packageInfo = await PackageInfo.fromPlatform();
  if (GetPlatform.isMobile) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  await Data.init();
  runApp(HomePage());
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return OKToast(
        position: ToastPosition.bottom,
        textPadding: EdgeInsets.all(8),
        dismissOtherOnShow: true,
        child: GetMaterialApp(
          title: 'Find Up!',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme ?? darkColorScheme,
          ),
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: Data.locale,
          translations: MobileUI(),
          supportedLocales: [Locale("zh", "CN"), Locale("en", "US")],
          fallbackLocale: Locale("en", "US"),
          home: MyHomePage(),
          getPages: [
            GetPage(
              name: '/explorer',
              page: () => PageILPExplorer(),
              binding: BindingsBuilder(() {
                Get.put(ExplorerController());
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
            GetPage(name: '/about', page: () => PageAbout()),
            GetPage(name: '/settings', page: () => PageSettings()),
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
          ],
        ),
      );
    });
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState() {
    _load();
  }

  @override
  Widget build(BuildContext context) {
    landscape();
    return LayoutBuilder(builder: (context, constrains) {
      return Scaffold(
        body: Stack(
          children: [
            Positioned(
              right: 10,
              bottom: 10,
              child: Text(
                [
                  'version ${packageInfo.version}',
                  if (env.isDev)
                    '${constrains.maxWidth} x ${constrains.maxHeight}',
                ].join('\n'),
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Positioned(
              left: -350,
              bottom: -350,
              child: Transform.scale(
                scale: 0.5,
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
            Center(
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: 0,
                    maxWidth: 300,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text(UI.startGame.tr),
                        onTap: () => Get.toNamed('/explorer'),
                      ),
                      ListTile(
                        title: Text(UI.settings.tr),
                        onTap: () => Get.toNamed('/settings'),
                      ),
                      ListTile(
                        title: Text(UI.about.tr),
                        onTap: () => Get.toNamed('/about'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  _load() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    print('资源列表 $manifestContent');
  }
}
