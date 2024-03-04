import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:steamworks/steamworks.dart';
import 'package:url_launcher/url_launcher_string.dart';

enum ApiLanguage {
  english,
  schinese,
}

enum SteamUGCSort {
  publishTime,
  updateTime,
  vote,
}

extension ArrayCharExtensions on Array<Char> {
  String toDartString() {
    var bytesBuilder = BytesBuilder();
    int index = 0;
    while (this[index] != 0) {
      bytesBuilder.addByte(this[index]);
      ++index;
    }

    var bytes = bytesBuilder.takeBytes();
    return utf8.decode(bytes);
  }
}

class SteamDownloadListener {
  SteamDownloadListener._();

  static bool _init = false;
  static final Map<int, List<void Function()>> _events = {};

  static void init() {
    if (_init) return;
    _init = true;
    SteamClient.instance.registerCallback<DownloadItemResult>(
      cb: (result) {
        if (result.appId != SteamClient.instance.steamUtils.getAppId()) return;
        _events[result.publishedFileId]
            ?.toList()
            .forEach((element) => element());
      },
    );
  }

  static void add(int fileId, void Function() cb, {bool once = false}) {
    if (once) {
      late void Function() newCB;
      newCB = () {
        cb();
        remove(fileId, newCB);
      };
      _events.putIfAbsent(fileId, () => []).add(newCB);
    } else {
      _events.putIfAbsent(fileId, () => []).add(cb);
    }
  }

  static void remove(int fileId, void Function() cb) {
    _events[fileId]?.remove(cb);
  }

  static void removeAll([int? fileId]) {
    if (fileId == null) {
      _events.clear();
    } else {
      _events.remove(fileId);
    }
  }
}

class SubmitResult {
  final EResult result;
  final int publishedFileId;
  final bool userNeedsToAcceptWorkshopLegalAgreement;

  SubmitResult({
    required this.result,
    required this.publishedFileId,
    required this.userNeedsToAcceptWorkshopLegalAgreement,
  });
}

extension SteamClientEx on SteamClient {
  int get userId => steamUser.getSteamId();

  int get appId => steamUtils.getAppId();

  /// return steam ugc item file id
  Future<int> createItemReturnId() async {
    final completer = Completer<int>();
    registerCallResult<CreateItemResult>(
      asyncCallId: steamUgc.createItem(
        steamUtils.getAppId(),
        EWorkshopFileType.community,
      ),
      cb: (result, hasFailed) {
        print('steamUgc.createItem\n'
            'publishedFileId: ${result.publishedFileId}');
        if (result.result == EResult.eResultOK) {
          completer.complete(result.publishedFileId);
        } else {
          completer.completeError(Exception('create item failed'));
        }
      },
    );
    return completer.future;
  }

  Future removeItem(int itemId) async {
    assert(itemId > 0);
    final Completer completer = Completer();
    registerCallResult<DeleteItemResult>(
      asyncCallId: steamUgc.deleteItem(itemId),
      cb: (result, hasFailed) {
        print('删除创意工坊 $itemId ${result.result}');
        completer.complete(result.result);
      },
    );
    return completer.future;
  }

  Future subscribe(int id) async {
    final complete = Completer<EResult>();
    registerCallResult<RemoteStorageUnsubscribePublishedFileResult>(
      asyncCallId: steamUgc.subscribeItem(id),
      cb: (r, f) {
        // print('subscribe $id ${r.result}');
        complete.complete(r.result);
      },
    );
    return complete.future;
  }

  Future unsubscribe(int id) async {
    final complete = Completer<EResult>();
    registerCallResult<RemoteStorageUnsubscribePublishedFileResult>(
      asyncCallId: steamUgc.unsubscribeItem(id),
      cb: (r, f) {
        // print('unsubscribe ugc item $id ${r.result}');
        complete.complete(r.result);
      },
    );
    return complete.future;
  }

  openUrl(String url, [mode = EActivateGameOverlayToWebPageMode.default_]) {
    if (url.startsWith('https://')) url = 'steam://openurl/$url';
    launchUrlString(url);

    /// bug
    // steamFriends.activateGameOverlayToWebPage(
    //   url.toNativeUtf8(),
    //   mode,
    // );
  }

  startPlaytimeTracking(int itemId) {
    final id = calloc<UnsignedLongLong>()..value = itemId;
    final SteamApiCall res = steamUgc.startPlaytimeTracking(id, 1);
    print('追踪游戏时间，结果:$res');
  }

  stopPlaytimeTracking() {
    steamUgc.stopPlaytimeTrackingForAllItems();
  }

  Future<void> downloadUGCItem(int id, {bool highPriority = false}) async {
    final completer = Completer<void>();
    SteamDownloadListener.add(id, () {
      completer.complete();
    }, once: true);
    steamUgc.downloadItem(id, highPriority);
    return completer.future;
  }

  openEulaUrl() {
    openUrl(
      'https://steamcommunity.com/sharedfiles/workshoplegalagreement?appid=${SteamClient.instance.appId}',
    );
  }
}

List<String> getSteamItemTags(Arena arena, int handle, int index) {
  final list = <String>[];
  final tags = SteamClient.instance.steamUgc.getQueryUgcNumTags(handle, index);
  for (var i = 0; i < tags; i++) {
    final tag = arena<Uint8>(255).cast<Utf8>();
    SteamClient.instance.steamUgc.getQueryUgcTag(handle, index, i, tag, 255);
    list.add(tag.toDartString());
  }
  return list;
}
