import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:steamworks/steamworks.dart';

import '../pages/challenge/steam_challenge.dart';
import 'steam_ex.dart';
import 'steam_tags.dart';

extension SteamCollectionEX on SteamClient {
  Future<SteamCollections> getCollections({
    required int page,
    SteamUGCSort sort = SteamUGCSort.publishTime,
    Set<String>? tags,
  }) async {
    final appId = steamUtils.getAppId();
    final completer = Completer<SteamCollections>();
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
    final query = steamUgc.createQueryAllUgcRequestPage(
      _sort,
      EUgcMatchingUgcType.all,
      appId,
      appId,
      page,
    );
    steamUgc.setReturnMetadata(query, true);
    steamUgc.setReturnChildren(query, true);
    steamUgc.setReturnKeyValueTags(query, true);
    steamUgc.setAllowCachedResponse(query, 0);

    tags ??= {};
    tags.add(TagType.challenge.value);
    for (var tag in tags) {
      steamUgc.addRequiredTag(query, tag.toNativeUtf8());
    }
    print('steam query tags $tags');

    registerCallResult<SteamUgcQueryCompleted>(
        asyncCallId: steamUgc.sendQueryUgcRequest(query),
        cb: (result, failed) {
          final list = <SteamCollection>[];
          if (result.result == EResult.eResultOK) {
            for (var i = 0; i < result.numResultsReturned; i++) {
              using((arena) {
                final detail = arena<SteamUgcDetails>();
                steamUgc.getQueryUgcResult(result.handle, i, detail);
                print(
                    '合集 ${detail.title.toDartString()} 子项数量 ${detail.numChildren}');
                final children = arena<Uint64>(detail.numChildren);
                steamUgc.getQueryUgcChildren(
                  query,
                  i,
                  children.cast<UnsignedLongLong>(),
                  detail.numChildren,
                );

                final previewUrl = arena<Uint8>(255).cast<Utf8>();
                steamUgc.getQueryUgcPreviewUrl(
                  result.handle,
                  i,
                  previewUrl,
                  256,
                );
                late TagAgeRating ageRating;
                final shapes = <TagShape>{};
                final styles = <TagStyle>{};
                final tags = getSteamItemTags(arena, result.handle, i);
                for (var tag in tags) {
                  if (TagAgeRatings.keys.contains(tag)) {
                    ageRating = TagAgeRatings[tag]!;
                  } else if (TagShapes.keys.contains(tag)) {
                    shapes.add(TagShapes[tag]!);
                  } else if (TagStyles.keys.contains(tag)) {
                    styles.add(TagStyles[tag]!);
                  }
                }
                list.add(SteamCollection(
                  id: detail.publishedFileId,
                  ownerId: detail.steamIdOwner,
                  name: detail.title.toDartString(),
                  image: previewUrl.toDartString(),
                  version: 0,
                  votesUp: detail.votesUp,
                  votesDown: detail.votesDown,
                  description: detail.description.toDartString(),
                  ageRating: ageRating,
                  shapes: shapes.toList(),
                  styles: styles.toList(),
                  publishTime: DateTime.fromMillisecondsSinceEpoch(
                      detail.timeCreated * 1000,
                      isUtc: true),
                  updateTime: DateTime.fromMillisecondsSinceEpoch(
                      detail.timeUpdated * 1000,
                      isUtc: true),
                  childrenItemId: List.generate(
                    detail.numChildren,
                    (i) => children[i],
                  ),
                ));
              });
            }
          }
          steamUgc.releaseQueryUgcRequest(result.handle);
          completer.complete(SteamCollections(
            total: result.totalMatchingResults,
            list: list,
          ));
        });
    return completer.future;
  }

  Future<SubmitResult> createCollection(
    SteamCollection collection, {
    visibility = ERemoteStoragePublishedFileVisibility.public,
  }) async {
    final completer = Completer<SubmitResult>();
    final itemId = await createItemReturnId();
    final tempDir = await getTemporaryDirectory();
    final itemDir =
        await Directory(path.join(tempDir.path, itemId.toString())).create();
    await File(path.join(itemDir.path, 'challenge.txt')).create();

    final handle = steamUgc.startItemUpdate(steamUtils.getAppId(), itemId);
    steamUgc.setItemTitle(
      handle,
      collection.name.toNativeUtf8(),
    );
    steamUgc.setItemDescription(
      handle,
      collection.description.toNativeUtf8(),
    );
    steamUgc.setItemVisibility(
      handle,
      visibility,
    );
    steamUgc.setItemContent(handle, itemDir.path.toNativeUtf8());

    /// tag
    {
      final tags = {
        TagType.challenge.value,
        collection.ageRating.value,
        ...collection.styles.map((e) => e.value),
        ...collection.shapes.map((e) => e.value),
      };
      final tag = calloc<SteamParamStringArray>();
      tag.ref.strings = calloc<Pointer<Utf8>>(tags.length);
      tags.forEachIndexed((index, element) {
        tag.ref.strings[index] = element.toNativeUtf8();
      });
      tag.ref.numStrings = tags.length;
      final setTags = steamUgc.setItemTags(handle, tag);
      print('set tags $setTags $tags');
    }

    print('set image ${collection.image}');
    if (collection.image.isNotEmpty) {
      steamUgc.setItemPreview(handle, collection.image.toNativeUtf8());
    }
    for (var fileId in collection.childrenItemId) {
      steamUgc.addDependency(itemId, fileId);
    }

    /// meta data
    {
      final metaData = [
        for (var e in collection.items!) [e.id.toString(), e.name, e.image]
      ];
      final keyValue = <String, String>{};
      print('metadata $metaData');
      final json = jsonEncode(metaData);
      // steamUgc.setItemDescription(handle, json.toNativeUtf8());
      final meta = base64Encode(gzip.encode(utf8.encode(json)));
      keyValue['metaDataLength'] = meta.length.toString();
      steamUgc.setItemMetadata(handle, meta.toNativeUtf8());
      for (var key in keyValue.keys) {
        steamUgc.removeItemKeyValueTags(handle, key.toNativeUtf8());
        steamUgc.addItemKeyValueTag(
          handle,
          key.toNativeUtf8(),
          keyValue[key]!.toNativeUtf8(),
        );
      }
    }

    registerCallResult<SubmitItemUpdateResult>(
        asyncCallId: steamUgc.submitItemUpdate(handle, ''.toNativeUtf8()),
        cb: (res, failed) {
          if (failed) return completer.completeError(Exception());
          completer.complete(SubmitResult(
            publishedFileId: res.publishedFileId,
            result: res.result,
            userNeedsToAcceptWorkshopLegalAgreement:
                res.userNeedsToAcceptWorkshopLegalAgreement,
          ));
        });
    return completer.future;
  }
}
