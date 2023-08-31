enum TagStyle {
  anime('Anime'),
  realistic('Realistic'),
  pixel('Pixel'),
  ancientChinese('Ancient Chinese'),
  other('Other');

  final String value;

  const TagStyle(this.value);
}

enum TagOrientation {
  landscape('Landscape'),
  portrait('Portrait'),
  square('Square');

  final String value;

  const TagOrientation(this.value);
}

enum TagAgeRating {
  everyone('Everyone'),
  questionable('Questionable'),
  mature('Mature');

  final String value;

  const TagAgeRating(this.value);
}
