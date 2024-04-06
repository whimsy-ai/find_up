import 'package:ffi/ffi.dart';
import 'package:steamworks/steamworks.dart';

enum SteamAchievement {
  contentCreator('ACHIEVEMENT_CREATOR'),
  gamer('ACHIEVEMENT_GAMER'),
  ocdGamer('ACHIEVEMENT_OCD_GAMER'),
  layers10('ACHIEVEMENT_10_LAYERS'),
  layers50('ACHIEVEMENT_50_LAYERS'),
  layers100('ACHIEVEMENT_100_LAYERS'),
  ;

  final String value;

  const SteamAchievement(this.value);

  void achieved(){
    print('达成成就 $value');
    SteamClient.instance.steamUserStats
      ..setAchievement(value.toNativeUtf8())
      ..storeStats();
  }
}
