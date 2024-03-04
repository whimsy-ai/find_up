extension DurationEx on Duration {
  String toSemanticString() {
    final mill = inMilliseconds < 0 ? 0 : inMilliseconds;
    final time = (mill / Duration.millisecondsPerSecond).toString().split('.');
    return time[0];
    // final minutes = inMinutes.toString().padLeft(2, '0');
    // final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    // final int milliseconds = inMilliseconds.remainder(1000) ~/ 10;
    //
    // return '$minutes:$seconds:${milliseconds.toString().padLeft(2, '0')}'; // 修改这一行

    // return '$minutes:$seconds';
  }
}
