import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:ffi/ffi.dart';
import 'package:game/explorer/file.dart';
import 'package:game/get_ilp_info_unlock.dart';
import 'package:ilp_file_codec/ilp_codec.dart';
import 'package:path/path.dart' as path;
import 'package:steamworks/steamworks.dart';

import '../../../utils/has_flag.dart';
import '../../../utils/steam_ex.dart';
import '../../../utils/steam_tags.dart';

class SteamFiles {
  final int current, total;
  final List<SteamFile> files;
  final EResult result;

  SteamFiles({
    required this.current,
    required this.total,
    required this.files,
    required this.result,
  });
}

class SteamFile implements ExplorerFile {
  TagShape? shape;
  TagStyle? style;
  TagAgeRating? ageRating;

  int id;
  @override
  String cover;

  @override
  String name;

  @override
  int version;

  @override
  int fileSize;

  final int steamIdOwner;
  int voteUp, voteDown;

  String? description;

  @override
  double unlock = 0.0;

  List<ILPInfo> infos;

  int get _state => SteamClient.instance.steamUgc.getItemState(id);

  Pointer<ISteamUgc> get ugc => SteamClient.instance.steamUgc;

  SteamFile({
    required this.id,
    required this.name,
    required this.cover,
    required this.version,
    required this.infos,
    required this.description,
    required this.steamIdOwner,
    required this.fileSize,
    this.voteUp = 0,
    this.voteDown = 0,
    this.ageRating,
    this.style,
    this.shape,
  }) {
    unlock = infos.map((e) => getIlpInfoUnlock(e)).toList().sum / infos.length;
  }

  bool get isInstalled =>
      isSubscribed && hasFlag(_state, EItemState.installed.value);

  bool get isDownLoading =>
      isSubscribed && hasFlag(_state, EItemState.downloading.value);

  bool get isSubscribed => hasFlag(_state, EItemState.subscribed.value);

  bool get isNeedsUpdate => hasFlag(_state, EItemState.needsUpdate.value);

  @override
  ILP? get ilp => ilpFile == null ? null : ILP.fromFileSync(ilpFile!);

  String? ilpFile;
  int? downloadedBytes, totalBytes;

  load() {
    if (isSubscribed) {
      if (isDownLoading) {
        _getDownloadBytes();
      } else if (isInstalled) {
        // print('get install info $id');
        if (ilpFile == null) {
          using((arena) {
            final size = arena<UnsignedLongLong>();
            final folder = arena<Uint8>(1000).cast<Utf8>();
            final timeStamp = arena<UnsignedInt>();
            final installed = ugc.getItemInstallInfo(
              id,
              size,
              folder,
              1000,
              timeStamp,
            );
            if (installed) {
              final file = File(path.join(folder.toDartString(), 'main.ilp'));
              ilpFile = file.existsSync() ? file.absolute.path : null;
            }
          });
        }
      }
    }
  }

  _getDownloadBytes() {
    using((arena) {
      final current = arena<UnsignedLongLong>();
      final total = arena<UnsignedLongLong>();
      final res = ugc.getItemDownloadInfo(id, current, total);
      if (res) {
        downloadedBytes = current[0];
        totalBytes = current[1];
      }
    });
  }

  Future subscribeAndDownload() async {
    await SteamClient.instance.subscribe(id);
    SteamClient.instance.steamUgc.suspendDownloads(false);
    SteamClient.instance.steamUgc.downloadItem(id, true);
    load();
  }

  Future unSubscribe() async {
    await SteamClient.instance.unsubscribe(id);
    load();
  }
}
