enum TagStyle {
  anime('Anime'),
  realistic('Realistic'),
  pixel('Pixel'),
  ancientChinese('Ancient Chinese'),
  other('Other');

  final String value;

  const TagStyle(this.value);
}

enum TagShape {
  landscape('Landscape'),
  portrait('Portrait'),
  square('Square');

  final String value;

  const TagShape(this.value);
}

enum TagAgeRating {
  everyone('Everyone'),
  questionable('Questionable'),
  mature('Mature');

  final String value;

  const TagAgeRating(this.value);
}

enum TagType {
  file('File'),
  challenge('Challenge');

  final String value;

  const TagType(this.value);
}

final TagAgeRatings = {for (var e in TagAgeRating.values) e.value: e};
final TagShapes = {for (var e in TagShape.values) e.value: e};
final TagStyles = {for (var e in TagStyle.values) e.value: e};
final TagTypes = {for (var e in TagType.values) e.value: e};
