class Grid {
  /// 返回(row, column)
  static (int, int) calc(
    double width,
    double height,
    double targetSize,
  ) {
    int row = height ~/ targetSize, col = width ~/ targetSize;
    if (height % targetSize > 0) {
      row++;
    }

    if (width % targetSize > 0) {
      col++;
    }

    return (row, col);
  }
}
