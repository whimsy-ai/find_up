import 'dart:async';

import 'package:steamworks/steamworks.dart';

import '../../utils/steam_ex.dart';
import '../../utils/steam_tags.dart';

class CollectionItem {
  final int id;
  final int ownerId;
  final String name, image;

  CollectionItem({
    required this.id,
    required this.name,
    required this.image,
    required this.ownerId,
  });

  static Future<CollectionItem> load(int id) async {
    Completer<CollectionItem> completer = Completer();
    SteamClient.instance
        .registerCallResult<RemoteStorageGetPublishedFileDetailsResult>(
      asyncCallId: SteamClient.instance.steamRemoteStorage
          .getPublishedFileDetails(id, 10),
      cb: (res, failed) {
        if (failed) return completer.completeError(TimeoutException('timeout'));
        completer.complete(CollectionItem(
          id: res.publishedFileId,
          image: '',
          name: res.title.toDartString(),
          ownerId: res.steamIdOwner,
        ));
      },
    );
    return completer.future;
  }

  bool download() => SteamClient.instance.steamUgc.downloadItem(id, true);
}

class SteamCollections {
  final int total;
  final List<SteamCollection> list;

  SteamCollections({required this.total, required this.list});
}

class SteamCollection {
  final int id;
  final String name, description;
  final int ownerId;
  final String? previewImage; // 封面
  final int version, votesUp, votesDown;
  final List<int> childrenItemId;
  final DateTime publishTime, updateTime;
  final List<CollectionItem>? items;
  final scores = <ChallengeScore>[];
  final TagAgeRating ageRating;
  final List<TagStyle> styles;
  final List<TagShape> shapes;

  SteamCollection({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.version,
    required this.childrenItemId,
    required this.publishTime,
    required this.updateTime,
    required this.ageRating,
    required this.styles,
    required this.shapes,
    this.votesUp = 0,
    this.votesDown = 0,
    this.previewImage,
    this.description = '',
    this.items,
  });
}

class ChallengeScore {
  final int seed;
  final int steamId;
  final String name;
  final Duration duration;
  final String version; // 游戏版本

  ChallengeScore({
    required this.seed,
    required this.steamId,
    required this.name,
    required this.duration,
    required this.version,
  });

  Map toJson() => ({
        's': seed,
        'i': steamId,
        'n': name,
        'd': duration.inMilliseconds,
        'v': version,
      });

  @override
  String toString() {
    return 'ChallengeScore${toJson()}';
  }

  factory ChallengeScore.fromJson(Map data) {
    return ChallengeScore(
      seed: data['s'],
      steamId: data['i'],
      name: data['n'],
      duration: Duration(milliseconds: data['d']),
      version: data['v'],
    );
  }
}
