import 'dart:math' as math;

double findPeakHeightWithSize(double width, double height,
    [double minSize = 20]) {
  final min = math.min(width, height);
  final lockingSize = math.max(min / 3, minSize);
  final deep = (lockingSize - lockingSize / 2) * 2;
  return findPeakHeight(0, deep, deep, 0);
}

double findPeakHeight(
    double start, double control1, double control2, double end) {
// 实现一个函数来计算给定 t 时的纵坐标
  double bezierYAtT(double t) {
    return math.pow(1 - t, 3) * start +
        3 * math.pow(1 - t, 2) * t * control1 +
        3 * (1 - t) * math.pow(t, 2) * control2 +
        math.pow(t, 3) * end;
  }

// 使用数值方法找到极大值点
// 这里只是一个非常简化的例子，实际可能需要更精密的算法
  double tPeak = 0.5; // 初始猜测值，实际情况中需要迭代求解
// double epsilon = 1e-6; // 容差值
// double lastYValue;
// do {
//   double currentYValue = bezierYAtT(tPeak);
//   if (currentYValue > lastYValue) {
//     // 向左右两边收缩范围寻找更精确的极大值点
//     // （此处仅为示意，真实情况需要实现一个有效的极值搜索算法）
//   }
//   lastYValue = currentYValue;
// } while (/* 迭代条件 */);

// 返回弧顶高度
  return _abs(bezierYAtT(tPeak));
}

double _abs(double value) => value < 0 ? -value : value;
