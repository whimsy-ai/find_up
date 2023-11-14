import 'package:flutter/services.dart';

final NumberFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'[1-9][0-9]*'),
);
