import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';
import 'package:game/build_flavor.dart';
import 'package:steamworks/steamworks.dart';

enum SteamAchievement {
  contentCreator('ACHIEVEMENT_CREATOR'),
  ocdGamer('ACHIEVEMENT_OCD_GAMER'),
  layers10('ACHIEVEMENT_10_LAYERS'),
  layers50('ACHIEVEMENT_50_LAYERS'),
  layers100('ACHIEVEMENT_100_LAYERS'),
  saveImage('ACHIEVEMENT_SAVE_IMAGE'),
  challenger('ACHIEVEMENT_CHALLENGER'),
  ;

  final String value;

  const SteamAchievement(this.value);

  void achieved() {
    if (!env.isSteam) return;
    print('达成成就 $value');
    SteamClient.instance.steamUserStats
      ..setAchievement(value.toNativeUtf8())
      ..storeStats();
  }

  static void updateInt(String name, int value) {
    if (!env.isSteam) return;
    SteamClient.instance.steamUserStats
      ..setStatInt32(name.toNativeUtf8(), value)
      ..storeStats();
  }

  static int getInt(String name) {
    if (!env.isSteam) return 0;
    ffi.Pointer<ffi.Int> pointer =
        malloc.allocate<ffi.Int>(ffi.sizeOf<ffi.Int>());
    SteamClient.instance.steamUserStats
        .getStatInt32(name.toNativeUtf8(), pointer);
    var value = pointer.value;
    malloc.free(pointer);
    return value;
  }
}
