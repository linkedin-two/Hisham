import 'package:flutter/material.dart';

class Measurements {
  Size screenSize;

  Measurements(this.screenSize);

  double wp(percentage) {
    return percentage / 100 * screenSize.width;
  }

  double hp(percentage) {
    return percentage / 100 * screenSize.height;
  }

  double getWidthPx(int pixels) {
    return (pixels / 360.0) * screenSize.width;
  }
}

double getWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double getHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

vGap(double height, {BuildContext? context, bool isPercent = false}) {
  final resolvedHeight = (context != null && isPercent)
      ? MediaQuery.sizeOf(context).height * (height / 100)
      : height;

  return SizedBox(
    height: resolvedHeight,
  );
}

hGap(double width, {BuildContext? context, bool isPercent = false}) {
  final resolvedWidth = (context != null && isPercent)
      ? MediaQuery.sizeOf(context).width * (width / 100)
      : width;

  return SizedBox(width: resolvedWidth);
}
