enum BuildFlavor {
  production,
  development,
  staging,
  steamDevelopment,
  steamProduction
}

BuildEnvironment get env => _env!;
BuildEnvironment? _env;

class BuildEnvironment {
  final BuildFlavor flavor;

  BuildEnvironment._({required this.flavor});

  static void init({required flavor}) =>
      _env ??= BuildEnvironment._(flavor: flavor);

  bool get isDev =>
      flavor == BuildFlavor.development ||
      flavor == BuildFlavor.steamDevelopment;

  bool get isProd =>
      flavor == BuildFlavor.production || flavor == BuildFlavor.steamProduction;

  bool get isSteam =>
      flavor == BuildFlavor.steamDevelopment ||
      flavor == BuildFlavor.steamProduction;
}
