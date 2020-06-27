import 'package:flutter/material.dart';

/// Contains useful consts to reduce boilerplate and duplicate code
class UIHelper {
  // Vertical spacing constants. Adjust to your liking.
  static const double _VerticalSpaceSmall = 10.0;
  static const double _VerticalSpaceMedium = 20.0;
  static const double _VerticalSpaceLarge = 60.0;

  // Vertical spacing constants. Adjust to your liking.
  static const double _HorizontalSpaceSmall = 10.0;
  static const double _HorizontalSpaceMedium = 20.0;
  static const double _HorizontalSpaceLarge = 60.0;

  static const Widget verticalSpaceSmall = SizedBox(height: _VerticalSpaceSmall);
  static const Widget verticalSpaceMedium = SizedBox(height: _VerticalSpaceMedium);
  static const Widget verticalSpaceLarge = SizedBox(height: _VerticalSpaceLarge);

  static const Widget horizontalSpaceSmall = SizedBox(width: _HorizontalSpaceSmall);
  static const Widget horizontalSpaceMedium = SizedBox(width: _HorizontalSpaceMedium);
  static const Widget horizontalSpaceLarge = SizedBox(width: _HorizontalSpaceLarge);

  static Widget hairLineWidget() {
    return Container(
      color: Colors.black12,
      height: 1,
    );
  }

  //
  static BoxDecoration roundedBorder(double radius) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      // border: Border.all(width: 0, color: Colors.black26)
    );
  }

  static BoxDecoration roundedBorderWithColor(double radius, Color backgroundColor) {
    return BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        // border: Border.all(width: 1, color: Colors.transparent),
        color: backgroundColor);
  }

  static BoxDecoration roundedLineBorderWithColor(double radius, Color backgroundColor, double wid) {
    return BoxDecoration(borderRadius: BorderRadius.circular(radius), border: Border.all(width: wid, color: Colors.black12), color: backgroundColor);
  }

  static BoxDecoration rowSeperator() {
    return BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12, width: 1)));
  }

  static BoxDecoration addShadow() {
    return BoxDecoration(color: Colors.white, boxShadow: [
      BoxShadow(
        color: Colors.black12,
        offset: Offset(0, 1),
        blurRadius: 2.0,
      )
    ]);
  }
}
