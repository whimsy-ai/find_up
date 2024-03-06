import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:steamworks/steamworks.dart';

import '../../utils/steam_collection_ex.dart';
import '../../utils/steam_ex.dart';
import '../../utils/steam_tags.dart';
import '../explorer/steam/steam_file.dart';

class ChallengeEditorController extends GetxController {
  String? _image;
  String title = '';
  String description = '';
  int imageLength = 0;
  TagAgeRating? ageRating;
  final shapes = <TagShape>{};
  final styles = <TagStyle>{};
  late final list = <int, SteamFile>{}.obs
    ..listen((v) {
      final ageRatings = v.values.map((e) => e.ageRating).nonNulls;
      if (ageRatings.contains(TagAgeRating.mature)) {
        ageRating = TagAgeRating.mature;
      } else if (ageRatings.contains(TagAgeRating.questionable)) {
        ageRating = TagAgeRating.questionable;
      } else {
        ageRating = ageRatings.isEmpty ? null : TagAgeRating.everyone;
      }

      shapes
        ..clear()
        ..addAll(v.values.map((e) => e.shape).nonNulls);
      styles
        ..clear()
        ..addAll(v.values.map((e) => e.style).nonNulls);
      imageLength = v.values.map((e) => e.infos.length).sum;
      update(['form', 'list']);
    });

  String? get image => _image;

  set image(String? value) {
    _image = value;
    update(['form']);
  }

  ChallengeEditorController({
    this.title = '',
    this.description = '',
  });

  /// 从steam下载选择的ugc文件
  downloadAll() async {
    await Future.wait(
      list.values.map(
        (file) => SteamClient.instance.downloadUGCItem(file.id),
      ),
    );
  }

  Future<SubmitResult> submit() async {
    return SteamClient.instance.createCollection(
      language: ApiLanguage.english,
      title: title,
      description: description,
      previewImagePath: _image,
      childrenIds: list.keys.toSet(),
      ageRating: ageRating!,
      styles: styles,
      shapes: shapes,
    );
  }
}
