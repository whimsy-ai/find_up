bool hasFlag(int value, int target) => value & target == target;

bool hasFlags(int value, List<int> target) {
  final all = target.reduce((a, b) => a | b);
  return value & all == all;
}
