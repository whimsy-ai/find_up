import 'package:game/ui.dart';
import 'package:get/get.dart';

class MobileUI extends Translations {
  static const
      explorer = 'explorer';

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          ...UI.keys['en_US']!,
          explorer: 'Explorer',

        },
        'zh_CN': {
          ...UI.keys['zh_CN']!,
          explorer: '游戏资源',
        },
      };
}
