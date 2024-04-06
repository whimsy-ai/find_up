import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:steamworks/steamworks.dart';

import '../utils/steam_achievement.dart';

class PageTest2 extends StatefulWidget {
  @override
  State<PageTest2> createState() => _PageTest2State();
}

class _PageTest2State extends State<PageTest2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final res = SteamClient.instance.steamUserStats.setAchievement(
              SteamAchievement.gamer.value.toNativeUtf8());
          print('设置成就，结果: $res');
        },
        child: Text('测试成就'),
      ),
    );
  }
}
