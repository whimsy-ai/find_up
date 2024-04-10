enum BuildFlavor {
  mobile,
  microsoftStore,
  steam,
}

BuildEnvironment get env => _env!;
BuildEnvironment? _env;

class BuildEnvironment {
  final BuildFlavor flavor;

  BuildEnvironment._({required this.flavor});

  static void init({required flavor}) =>
      _env ??= BuildEnvironment._(flavor: flavor);

  bool get isSteam => flavor == BuildFlavor.steam;

  bool get isMobile => flavor == BuildFlavor.mobile;

  bool get isMicrosoftStore => flavor == BuildFlavor.microsoftStore;
}
