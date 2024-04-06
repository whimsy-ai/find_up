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
      appBar: AppBar(),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              SteamAchievement.updateInt('unlocked_layers', 15);
            },
            child: Text('设置统计数值'),
          ),
          ElevatedButton(
            onPressed: () {
              final layers = SteamAchievement.getInt('unlocked_layers');
              print('Steam统计 unlocked_layers $layers');
            },
            child: Text('读取统计数值'),
          ),
          ElevatedButton(
            onPressed: () {
              SteamClient.instance.steamUserStats.resetAllStats(true);
            },
            child: Text('清空统计'),
          ),
        ],
      ),
    );
  }
}
