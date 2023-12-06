import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:ffi/ffi.dart';
import 'package:ilp_file_codec/protobuf/ilp.pbserver.dart';
import 'package:steamworks/steamworks.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../pages/explorer/steam/steam_file.dart';
import 'steam_tags.dart';

enum ApiLanguage {
  english,
  schinese,
}

enum SteamFileSort {
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

extension SteamClientEx on SteamClient {
  int get userId => steamUser.getSteamId();

  Future<int> createItem() async {
    final completer = Completer<int>();
    final callId = steamUgc.createItem(
      steamUtils.getAppId(),
      EWorkshopFileType.community,
    );
    print('createItem callId $callId');
    registerCallResult<CreateItemResult>(
      asyncCallId: callId,
      cb: (result, hasFailed) {
        print('steamUgc.createItem');
        print('publishedFileId: ${result.publishedFileId}');
        if (result.result == EResult.eResultOK) {
          completer.complete(result.publishedFileId);
        } else {
          completer.completeError(Exception('create item failed'));
        }
      },
    );
    return completer.future;
  }

  Future<EResult> updateItem(
    int itemId, {
    required ApiLanguage language,
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
  }) async {
    final completer = Completer<EResult>();
    final handle = steamUgc.startItemUpdate(steamUtils.getAppId(), itemId);

    steamUgc.setItemVisibility(handle, visibility);
    steamUgc.setItemUpdateLanguage(handle, language.name.toNativeUtf8());

    final tag = calloc<SteamParamStringArray>();
    tag.ref.strings = calloc<Pointer<Utf8>>(tags.length);
    tags.forEachIndexed((index, element) {
      tag.ref.strings[index] = element.toNativeUtf8();
    });
    tag.ref.numStrings = tags.length;
    final setTags = steamUgc.setItemTags(handle, tag);
    print('set tags $setTags $tags');

    if (title != null) {
      steamUgc.setItemTitle(handle, title.toNativeUtf8());
    }
    if (description != null) {
      steamUgc.setItemDescription(handle, description.toNativeUtf8());
    }
    if (previewImagePath != null) {
      final res =
          steamUgc.setItemPreview(handle, previewImagePath.toNativeUtf8());
      print('预览图片 $previewImagePath $res');
    }
    if (contentFolder != null) {
      steamUgc.setItemContent(handle, contentFolder.toNativeUtf8());
    }
    if (metaData != null) {
      keyValue ??= {};
      metaData = base64Encode(gzip.encode(metaData.codeUnits));
      keyValue.add(('metaDataLength', metaData.length.toString()));
      // print('metadata $metaData');
      steamUgc.setItemMetadata(handle, metaData.toNativeUtf8());
    }
    if (keyValue != null) {
      keyValue.map((e) => e.$1).toSet().forEach((key) {
        final res = steamUgc.removeItemKeyValueTags(handle, key.toNativeUtf8());
        print('remove kv $key $res');
      });
      for (var kv in keyValue) {
        final (key, value) = kv;
        steamUgc.addItemKeyValueTag(
          handle,
          key.toNativeUtf8(),
          value.toNativeUtf8(),
        );
      }
    }

    onUpdate?.call(handle);
    registerCallResult<SubmitItemUpdateResult>(
      asyncCallId: steamUgc.submitItemUpdate(
        handle,
        (updateNote ?? '').toNativeUtf8(),
      ),
      cb: (result, hasFailed) {
        completer.complete(result.result);
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

  Future<SteamFiles> getAllItems({
    required int page,
    bool subscribed = false,
    int? userId,
    String? search,
    required SteamFileSort sort,
    Set<String>? tags,
  }) async {
    // print('get page $page, sort $voteType');
    final completer = Completer<SteamFiles>();
    final appId = steamUtils.getAppId();
    int query;

    if (subscribed || userId != null) {
      EUserUgcListSortOrder _sort;
      switch (sort) {
        case SteamFileSort.publishTime:
          _sort = EUserUgcListSortOrder.creationOrderDesc;
          break;
        case SteamFileSort.vote:
          _sort = EUserUgcListSortOrder.voteScoreDesc;
          break;
        case SteamFileSort.updateTime:
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
        case SteamFileSort.publishTime:
          _sort = EUgcQuery.rankedByPublicationDate;
          break;
        case SteamFileSort.vote:
          _sort = EUgcQuery.rankedByVote;
          break;
        case SteamFileSort.updateTime:
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

    if (tags != null && tags.isNotEmpty) {
      for (var tag in tags) {
        final addTag = steamUgc.addRequiredTag(query, tag.toNativeUtf8());
      }
    }
    print('steam query tags $tags');

    final styles = TagStyle.values.map((e) => e.value);
    final shapes = TagShape.values.map((e) => e.value);
    final ages = TagAgeRating.values.map((e) => e.value);

    registerCallResult<SteamUgcQueryCompleted>(
        asyncCallId: steamUgc.sendQueryUgcRequest(query),
        cb: (result, failed) {
          // print('Query ugc items result ${{
          //   'query_handle': query,
          //   'result_handle': result.handle,
          //   'result': result.result,
          //   'total': result.totalMatchingResults,
          //   'current': result.numResultsReturned,
          // }}');
          final List<SteamFile> details = [];
          if (result.result == EResult.eResultOK) {
            for (var i = 0; i < result.numResultsReturned; i++) {
              using((arena) {
                final detail = arena<SteamUgcDetails>();
                steamUgc.getQueryUgcResult(result.handle, i, detail);
                final previewUrl = arena<Uint8>(255).cast<Utf8>();
                steamUgc.getQueryUgcPreviewUrl(
                  result.handle,
                  i,
                  previewUrl,
                  256,
                );
                int? version;
                dynamic infos;

                /// get key value
                {
                  final tagNumber =
                      steamUgc.getQueryUgcNumKeyValueTags(result.handle, i);
                  int? metaDataLength;

                  for (var tagIndex = 0; tagIndex < tagNumber; tagIndex++) {
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
                    // print('key:${key.toDartString()},'
                    //     'value:${value.toDartString()}');
                    if (key.toDartString() == 'metaDataLength') {
                      metaDataLength = int.parse(value.toDartString()) + 10;
                    }
                  }
                  if (metaDataLength != null) {
                    final metaData = arena<Uint8>(metaDataLength).cast<Utf8>();
                    steamUgc.getQueryUgcMetadata(
                      result.handle,
                      i,
                      metaData,
                      metaDataLength,
                    );
                    final data = jsonDecode(utf8.decode(
                        gzip.decode(base64Decode(metaData.toDartString()))));
                    version = data['version'];
                    infos = data['infos'];
                  }
                }

                /// get tags
                late TagStyle style;
                late TagShape shape;
                late TagAgeRating ageRating;
                {
                  final tags = steamUgc.getQueryUgcNumTags(result.handle, i);
                  // print('tags $tags');
                  for (var index = 0; index < tags; index++) {
                    final tag = arena<Uint8>(255).cast<Utf8>();
                    steamUgc.getQueryUgcTag(
                      result.handle,
                      i,
                      index,
                      tag,
                      255,
                    );
                    final tagString = tag.toDartString();
                    if (styles.contains(tagString)) {
                      style = TagStyle.values
                          .firstWhere((element) => element.value == tagString);
                    } else if (shapes.contains(tagString)) {
                      shape = TagShape.values
                          .firstWhere((element) => element.value == tagString);
                    } else if (ages.contains(tagString)) {
                      ageRating = TagAgeRating.values
                          .firstWhere((element) => element.value == tagString);
                    }
                  }
                }
                // print('data $data');
                details.add(SteamFile(
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
          // print('details length ${details.length}');
        });
    return completer.future;
  }

  Future<List<int>> getAllSubscribeItems() async {
    final list = <int>[];
    final total = steamUgc.getNumSubscribedItems();

    using((arena) {
      final list = arena<UnsignedLongLong>();
      final res = steamUgc.getSubscribedItems(list, total);

      // print('getSubscribedItems $res ${list[0]}');
    });
    return list;
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
    launchUrlString(url);
    return;
    // todo, bug
    // steamFriends.activateGameOverlayToWebPage(
    //   url.toNativeUtf8(),
    //   mode,
    // );
  }
}
