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

class SteamSimpleFile implements ExplorerFile {
  static Pointer<ISteamUgc> get ugc => SteamClient.instance.steamUgc;
  final int id;
  final TagType type;
  int downloadedBytes = 0, totalBytes = 0;

  @override
  ILP? ilp;

  String? ilpFile;

  SteamSimpleFile({
    required this.id,
    this.type = TagType.file,
  });

  Future<void> updateDownloadBytes() async {
    final c = Completer();
    using((arena) {
      final downloaded = arena<UnsignedLongLong>();
      final total = arena<UnsignedLongLong>();
      final res = ugc.getItemDownloadInfo(id, downloaded, total);
      if (res) {
        downloadedBytes = downloaded.value;
        totalBytes = total.value;
        // print('获取下载数据 ${downloaded.value} ${total.value}');
      }
      c.complete();
    });
    return c.future;
  }

  @override
  Future<void> load({force = false}) async {
    if (isDownLoading) {
      return updateDownloadBytes();
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

  int get _state => SteamClient.instance.steamUgc.getItemState(id);

  bool get isInstalled => hasFlag(_state, EItemState.installed.value);

  bool get isDownLoading => hasFlag(_state, EItemState.downloading.value);

  bool get isSubscribed => hasFlag(_state, EItemState.subscribed.value);

  bool get isNeedsUpdate => hasFlag(_state, EItemState.needsUpdate.value);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class SteamFile extends SteamSimpleFile {
  TagShape? shape;
  TagStyle? style;
  TagAgeRating? ageRating;
  int? levelCount;

  @override
  String cover;

  @override
  String name;

  @override
  int version;

  @override
  int fileSize;

  int comments;

  DateTime publishTime;
  DateTime updateTime;

  final int steamIdOwner;
  int voteUp, voteDown;

  String? description;

  @override
  double unlock = 0.0;

  List<ILPInfo> infos;

  final List<int> childrenId;

  List<SteamSimpleFile> get children =>
      childrenId.map((e) => SteamSimpleFile(id: e)).toList();

  SteamFile({
    required super.id,
    required super.type,
    required this.name,
    required this.cover,
    required this.version,
    required this.infos,
    required this.description,
    required this.steamIdOwner,
    required this.fileSize,
    required this.updateTime,
    required this.publishTime,
    required this.comments,
    required this.childrenId,
    this.voteUp = 0,
    this.voteDown = 0,
    this.ageRating,
    this.style,
    this.shape,
    this.levelCount,
  }) {
    unlock = infos.map((e) => getIlpInfoUnlock(e)).toList().sum / infos.length;
  }

  @override
  ILP? get ilp => ilpFile == null ? null : ILP.fromFileSync(ilpFile!);

  Future subscribeAndDownload() async {
    await SteamClient.instance.subscribe(id);
    SteamClient.instance.steamUgc.suspendDownloads(false);
    SteamClient.instance.steamUgc.downloadItem(id, true);
    load();
  }

  Future subscribe() async {
    await SteamClient.instance.subscribe(id);
  }

  Future unSubscribe() async {
    await SteamClient.instance.unsubscribe(id);
  }
}
