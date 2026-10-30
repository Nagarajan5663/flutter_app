import 'package:flutter/material.dart';

abstract final class PurchaseDropdownStyle {
  static const Color menuColor = Color(0xFFFBFCFE);
  static const Color borderColor = Color(0xFFD9E2EC);
  static const BorderRadius borderRadius =
      BorderRadius.all(Radius.circular(10));
  static const RoundedRectangleBorder menuShape = RoundedRectangleBorder(
    borderRadius: borderRadius,
    side: BorderSide(color: borderColor),
  );
}
