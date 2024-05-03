import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:game/data.dart';
import 'package:game/game/resources.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oktoast/oktoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ui/ui.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

import 'firebase_options.dart';
import 'pages/explorer/gallery_controller.dart';
import 'pages/explorer/page_ilp_explorer.dart';
import 'pages/game/mobile_game_controller.dart';
import 'pages/game/page_play_challenge.dart';
import 'pages/game/random_challenge.dart';
import 'pages/page_about.dart';
import 'pages/save/mobile_save_image_controller.dart';
import 'pages/save/page_save_image.dart';
import 'pages/settings/page_settings.dart';
import 'utils/landscape.dart';
import 'utils/version.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  packageInfo = await PackageInfo.fromPlatform();
  if (GetPlatform.isMobile) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  await Data.init();
  runApp(HomePage());
  await UnityAds.setPrivacyConsent(PrivacyConsentType.gdpr, true);
  await UnityAds.setPrivacyConsent(PrivacyConsentType.ageGate, true);
  await UnityAds.setPrivacyConsent(PrivacyConsentType.ccpa, true);
  await UnityAds.setPrivacyConsent(PrivacyConsentType.pipl, true);
  await UnityAds.setPrivacyConsent(PrivacyConsentType.pipl, true);
  await UnityAds.init(
    firebaseTestLabMode: FirebaseTestLabMode.showAds,
    gameId: GetPlatform.isIOS ? '5516256' : '5516257',
    onComplete: () => print('Initialization Complete'),
    onFailed: (error, message) =>
        print('Initialization Failed: $error $message'),
  );
  // IronSource.setFlutterVersion('3.16.5');
  // await IronSource.validateIntegration();
  // await IronSource.setAdaptersDebug(true);
  // await IronSource.shouldTrackNetworkState(false);
  // await IronSource.setUserId('android-test-user-id-123');
  // await IronSource.init(
  //   appKey: '1d15edbcd',
  //   adUnits: [
  //     IronSourceAdUnit.RewardedVideo,
  //     IronSourceAdUnit.Banner,
  //   ],
  // );

  /// 预读取游戏资源
  Resources.init();
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
          translations: UI(),
          fallbackLocale: Locale("en", "US"),
          home: MyHomePage(),
          getPages: [
            GetPage(
              name: '/play_challenge',
              page: () => PagePlayChallenge<MobileGameController>(),
              binding: BindingsBuilder(() {
                Get.put(MobileGameController(
                  mode: Get.arguments['mode'],
                  files: Get.arguments['files'],
                  ilpIndex: Get.arguments['ilpIndex'],
                ));
              }),
            ),
            GetPage(
              name: '/explorer',
              page: () => PageILPExplorer(),
              binding: BindingsBuilder(() {
                Get.put(ExplorerController());
              }),
            ),
            GetPage(name: '/about', page: () => PageAbout()),
            GetPage(name: '/settings', page: () => PageSettings()),
            GetPage(
              name: '/save',
              page: () => PageSaveImage(),
              binding: BindingsBuilder(() {
                Get.put(MobileSaveImageController(
                  file: Get.arguments['file'],
                  index: Get.arguments['index'],
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
                  'version ${packageInfo.version}_${packageInfo.buildNumber}',
                  if (kDebugMode)
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
                        title: Text.rich(
                          TextSpan(
                            text: UI.challenge.tr,
                            children: [
                              TextSpan(
                                text: ' New',
                                style: GoogleFonts.lilitaOne(
                                  color: Colors.red,
                                ),
                              )
                            ],
                          ),
                        ),
                        onTap: RandomChallengeDialog.show,
                      ),
                      ListTile(
                        title: Text(UI.gallery.tr),
                        onTap: () => Get.toNamed('/explorer'),
                      ),
                      ListTile(
                        title: Text(UI.settings.tr),
                        onTap: () => Get.toNamed('/settings'),
                      ),
                      ListTile(
                        title: Text(
                          UI.about.tr,
                        ),
                        onTap: () => Get.toNamed('/about'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: UnityBannerAd(
                placementId: 'main_banner',
                onLoad: (placementId) => print('Banner loaded: $placementId'),
                onClick: (placementId) => print('Banner clicked: $placementId'),
                onShown: (placementId) => print('Banner shown: $placementId'),
                onFailed: (placementId, error, message) =>
                    print('Banner Ad $placementId failed: $error $message'),
              ),
            )
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
