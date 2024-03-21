import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/cupertino.dart';
import 'package:ilp_file_codec/ilp_codec.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:steamworks/steamworks.dart';

import '../pages/explorer/steam/steam_file.dart';
import 'compress_image.dart';
import 'steam_ex.dart';
import 'steam_tags.dart';

extension SteamFileEX on SteamClient {
  Future<SteamFiles> getAllItems({
    required int page,
    required SteamUGCSort sort,
    required TagType type,
    bool subscribed = false,
    int? userId,
    String? search,
    Set<String>? tags,
  }) async {
    // debugPrint('get page $page, sort $voteType');
    final completer = Completer<SteamFiles>();
    final appId = steamUtils.getAppId();
    int query;

    if (subscribed || userId != null) {
      EUserUgcListSortOrder _sort;
      switch (sort) {
        case SteamUGCSort.publishTime:
          _sort = EUserUgcListSortOrder.creationOrderDesc;
          break;
        case SteamUGCSort.vote:
          _sort = EUserUgcListSortOrder.voteScoreDesc;
          break;
        case SteamUGCSort.updateTime:
          _sort = EUserUgcListSortOrder.lastUpdatedDesc;
          break;
      }
      query = steamUgc.createQueryUserUgcRequest(
        subscribed ? this.userId : userId!,
        subscribed ? EUserUgcList.subscribed : EUserUgcList.published,
        EUgcMatchingUgcType.usableInGame,
        _sort,
        appId,
        appId,
        page,
      );
    } else {
      EUgcQuery _sort;
      switch (sort) {
        case SteamUGCSort.publishTime:
          _sort = EUgcQuery.rankedByPublicationDate;
          break;
        case SteamUGCSort.vote:
          _sort = EUgcQuery.rankedByVote;
          break;
        case SteamUGCSort.updateTime:
          _sort = EUgcQuery.rankedByLastUpdatedDate;
          break;
      }
      query = steamUgc.createQueryAllUgcRequestPage(
        _sort,
        EUgcMatchingUgcType.usableInGame,
        appId,
        appId,
        page,
      );
    }
    if (search != null) {
      steamUgc.setSearchText(query, search.toNativeUtf8());
    }
    steamUgc.setReturnKeyValueTags(query, true);
    steamUgc.setReturnMetadata(query, true);
    steamUgc.setAllowCachedResponse(query, 0);
    steamUgc.setReturnLongDescription(query, true);
    steamUgc.setReturnChildren(query, true);

    tags ??= {};
    tags.add(type.value);
    for (var tag in tags) {
      steamUgc.addRequiredTag(query, tag.toNativeUtf8());
    }
    debugPrint('steam query tags $tags');

    registerCallResult<SteamUgcQueryCompleted>(
        asyncCallId: steamUgc.sendQueryUgcRequest(query),
        cb: (result, failed) {
          debugPrint('Query ugc items result ${{
            'query_handle': query,
            'result_handle': result.handle,
            'result': result.result,
            'total': result.totalMatchingResults,
            'current': result.numResultsReturned,
          }}');
          final List<SteamFile> details = [];
          if (result.result == EResult.eResultOK) {
            for (var i = 0; i < result.numResultsReturned; i++) {
              // debugPrint('处理 $i');
              using((arena) {
                /// https://partner.steamgames.com/doc/api/ISteamUGC#GetQueryUGCStatistic
                final commentsNumber = arena<UnsignedLongLong>();
                steamUgc.getQueryUgcStatistic(result.handle, i,
                    EItemStatistic.numComments, commentsNumber);
                // debugPrint('评论数: ${commentsNumber.value}');

                /// https://partner.steamgames.com/doc/api/ISteamUGC#GetQueryUGCResult
                final detail = arena<SteamUgcDetails>();
                steamUgc.getQueryUgcResult(result.handle, i, detail);
                final previewUrl = arena<Uint8>(255).cast<Utf8>();
                steamUgc.getQueryUgcPreviewUrl(
                  result.handle,
                  i,
                  previewUrl,
                  256,
                );
                // debugPrint('$i previewUrl ${previewUrl.toDartString()}');

                int? version, levelCount;
                dynamic infos;

                /// get key value
                {
                  final kvNumbers =
                      steamUgc.getQueryUgcNumKeyValueTags(result.handle, i);
                  int? metaDataLength;
                  // debugPrint('kvNumbers $kvNumbers');
                  for (var tagIndex = 0; tagIndex < kvNumbers; tagIndex++) {
                    final key = arena<Uint8>(255).cast<Utf8>(),
                        value = arena<Uint8>(255).cast<Utf8>();
                    steamUgc.getQueryUgcKeyValueTag(
                      result.handle,
                      i,
                      tagIndex,
                      key,
                      50,
                      value,
                      100,
                    );
                    // debugPrint(
                    //   'key:${key.toDartString()},'
                    //   'value:${value.toDartString()}',
                    // );
                    if (key.toDartString() == 'metaDataLength') {
                      metaDataLength = int.parse(value.toDartString()) + 10;
                    }
                    if (key.toDartString() == 'levelCount') {
                      levelCount = int.parse(value.toDartString());
                    }
                  }
                  if (metaDataLength != null) {
                    final metaData =
                        arena<Uint8>(metaDataLength + 10).cast<Utf8>();
                    steamUgc.getQueryUgcMetadata(
                      result.handle,
                      i,
                      metaData,
                      metaDataLength,
                    );
                    final rawData = metaData.toDartString();
                    // debugPrint('metaData $rawData');
                    final base64DecodeData = base64Decode(rawData);
                    // debugPrint('base64Decode $base64DecodeData');
                    final gzipDecodeData = gzip.decode(base64DecodeData);
                    // debugPrint('gzip.decode $gzipDecodeData');
                    final utf8DecodeData =
                        utf8.decode(gzipDecodeData, allowMalformed: true);
                    // debugPrint('utf8.decode $utf8DecodeData');
                    try {
                      final data = jsonDecode(utf8DecodeData);
                      // debugPrint('data decode $data');
                      version = data['version'];
                      infos = data['infos'];
                    } catch (e) {}
                  }
                }

                final children = arena<Uint64>(detail.numChildren);
                steamUgc.getQueryUgcChildren(
                  query,
                  i,
                  children.cast<UnsignedLongLong>(),
                  detail.numChildren,
                );

                /// get tags
                late TagStyle style;
                late TagShape shape;
                late TagAgeRating ageRating;
                {
                  final tags = getSteamItemTags(arena, result.handle, i);
                  for (var tag in tags) {
                    if (TagStyles.containsKey(tag)) {
                      style = TagStyles[tag]!;
                    } else if (TagShapes.containsKey(tag)) {
                      shape = TagShapes[tag]!;
                    } else if (TagAgeRatings.containsKey(tag)) {
                      ageRating = TagAgeRatings[tag]!;
                    }
                  }
                }
                // debugPrint('data $data');
                details.add(SteamFile(
                  type: type,
                  childrenId: List.generate(
                    detail.numChildren,
                    (i) => children[i],
                  ),
                  comments: commentsNumber.value,
                  publishTime: DateTime.fromMillisecondsSinceEpoch(
                      detail.timeCreated * 1000,
                      isUtc: true),
                  updateTime: DateTime.fromMillisecondsSinceEpoch(
                      detail.timeUpdated * 1000,
                      isUtc: true),
                  fileSize: detail.fileSize,
                  style: style,
                  ageRating: ageRating,
                  shape: shape,
                  id: detail.publishedFileId,
                  name: detail.title.toDartString(),
                  voteUp: detail.votesUp,
                  voteDown: detail.votesDown,
                  steamIdOwner: detail.steamIdOwner,
                  cover: previewUrl.toDartString(),
                  version: version ?? 1,
                  description: detail.description.toDartString(),
                  infos: infos == null
                      ? []
                      : List.from(
                          infos.map((map) => ILPInfo.fromJson(map)),
                        ),
                  levelCount: levelCount,
                ));
              });
            }
          }
          steamUgc.releaseQueryUgcRequest(result.handle);

          completer.complete(SteamFiles(
            result: result.result,
            current: result.numResultsReturned,
            total: result.totalMatchingResults,
            files: details,
          ));
          // debugPrint('details length ${details.length}');
        });
    return completer.future;
  }

  Future<SubmitResult> createItem({
    int? itemId,
    required ApiLanguage language,
    required TagType type,
    visibility = ERemoteStoragePublishedFileVisibility.public,
    String? title,
    String? description,
    String? contentFolder,
    String? previewImagePath,
    Set<(String, String)>? keyValue,
    String? metaData,
    String? updateNote,
    void Function(int handle)? onUpdate,
    required Set<String> tags,
    Set<int>? childrenId,
    int? levelCount,
  }) async {
    final tempDir = await getTemporaryDirectory();
    itemId ??= await createItemReturnId();
    final completer = Completer<SubmitResult>();
    final handle = steamUgc.startItemUpdate(steamUtils.getAppId(), itemId);

    steamUgc.setItemVisibility(handle, visibility);
    steamUgc.setItemUpdateLanguage(handle, language.name.toNativeUtf8());

    tags.add(type.value);

    if (type == TagType.challenge) {
      final tempDir = await getTemporaryDirectory();
      final itemDir =
          await Directory(path.join(tempDir.path, itemId.toString())).create();
      await File(path.join(itemDir.path, 'challenge.txt')).create();
      contentFolder = itemDir.path;
    }

    final tag = calloc<SteamParamStringArray>();
    tag.ref.strings = calloc<Pointer<Utf8>>(tags.length);
    tags.forEachIndexed((index, element) {
      tag.ref.strings[index] = element.toNativeUtf8();
    });
    tag.ref.numStrings = tags.length;
    final setTags = steamUgc.setItemTags(handle, tag, false);
    debugPrint('set tags $setTags $tags');

    if (title != null) {
      steamUgc.setItemTitle(handle, title.toNativeUtf8());
    }
    if (description != null) {
      steamUgc.setItemDescription(handle, description.toNativeUtf8());
    }
    if (previewImagePath != null) {
      final file = File(path.join(tempDir.path, 'preview.png'));
      await file.writeAsBytes(await compressImage(File(previewImagePath)));
      // print('预览图片 ${file.path}');
      steamUgc.setItemPreview(handle, file.path.toNativeUtf8());
    }
    if (childrenId != null) {
      for (var id in childrenId) {
        steamUgc.addDependency(itemId, id);
      }
    }
    if (contentFolder != null) {
      steamUgc.setItemContent(handle, contentFolder.toNativeUtf8());
    }
    keyValue ??= {};
    if (levelCount != null) {
      keyValue.add(('levelCount', levelCount.toString()));
    }
    if (metaData != null) {
      metaData = base64Encode(gzip.encode(utf8.encode(metaData)));
      keyValue.add(('metaDataLength', metaData.length.toString()));
      // debugPrint('metadata $metaData');
      steamUgc.setItemMetadata(handle, metaData.toNativeUtf8());
    }

    /// 必须删除旧key，
    keyValue.map((e) => e.$1).toSet().forEach((key) {
      final res = steamUgc.removeItemKeyValueTags(handle, key.toNativeUtf8());
      debugPrint('remove kv $key $res');
    });
    for (var kv in keyValue) {
      final (key, value) = kv;
      steamUgc.addItemKeyValueTag(
        handle,
        key.toNativeUtf8(),
        value.toNativeUtf8(),
      );
    }

    onUpdate?.call(handle);
    registerCallResult<SubmitItemUpdateResult>(
      asyncCallId: steamUgc.submitItemUpdate(
        handle,
        (updateNote ?? '').toNativeUtf8(),
      ),
      cb: (result, hasFailed) {
        completer.complete(SubmitResult(
          result: result.result,
          publishedFileId: result.publishedFileId,
          userNeedsToAcceptWorkshopLegalAgreement:
              result.userNeedsToAcceptWorkshopLegalAgreement,
        ));
      },
    );
    return completer.future;
  }
}
