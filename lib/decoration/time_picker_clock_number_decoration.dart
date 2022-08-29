import 'package:flutter/material.dart';
import '../src/utils.dart';

class TimePickerClockNumberDecoration {
  /// Set to true to enable clock numbers
  /// default value: false
  final bool showNumberIndicators;

  /// play with this number to define reduce the font size of the clock number
  /// default value: 0.7
  final double textScaleFactor;

  /// play with this number to define the location of the clock number
  /// default value: 0.9
  final double scaleFactor;

  /// Optional Style to be applied to the the "12" or "24" number in the clock when clock is enable
  /// if not need then set color to transparent
  /// default value: NULL
  /// See also:
  /// * getDefaultTextStyle
  TextStyle? style12;

  /// Optional Style to be applied to the the "9" or "18" number in the clock when clock is enable
  /// if not need then set color to transparent
  /// default value: NULL
  /// See also:
  /// * getDefaultTextStyle
  TextStyle? style9;

  /// Optional Style to be applied to the the "6" or "12" number in the clock when clock is enable
  /// if not need then set color to transparent
  /// default value: NULL
  /// See also:
  /// * getDefaultTextStyle
  TextStyle? style6;

  /// Optional Style to be applied to the the "3" or "6" number in the clock when clock is enable
  /// if not need then set color to transparent
  /// default value: NULL
  /// See also:
  /// * getDefaultTextStyle
  TextStyle? style3;

  /// Optional, defines the font size to use when the a Style is not define,
  /// default value: 18
  double defaultFontSize;

  /// Optional, defines the main color to get use when the a Style is not define,
  /// default value: [Colors.black]
  Color defaultTextColor;

  /// Defines the clock time format either twelveHours or twentyFourHours
  /// default value: [ClockTimeFormat.twentyFourHours]
  ClockTimeFormat clockTimeFormat;

  /// Defines the clock time increment format
  /// default value: [ClockIncrementTimeFormat.fiveMin]
  ClockIncrementTimeFormat clockIncrementTimeFormat;

  TimePickerClockNumberDecoration({
    this.clockTimeFormat = ClockTimeFormat.twentyFourHours,
    this.clockIncrementTimeFormat = ClockIncrementTimeFormat.fiveMin,
    this.showNumberIndicators = true,
    this.textScaleFactor = 0.7,
    this.scaleFactor = 0.9,
    this.style12,
    this.style9,
    this.style6,
    this.style3,
    this.defaultFontSize = 18,
    this.defaultTextColor = Colors.black,
  });

  /// this method will be call any time any style [style12, style9, style6, style3] is not defined
  /// [defaultFontSize] Optional, defines the font size to use when the a Style is not define,
  /// default value: 18
  /// [defaultTextColor] Optional, defines the main color to get use when the a Style is not define,
  /// default value: [Colors.black]
  TextStyle getDefaultTextStyle() {
    return TextStyle(
      color: defaultTextColor,
      fontWeight: FontWeight.bold,
      fontSize: defaultFontSize * scaleFactor * textScaleFactor,
    );
  }

  TimePickerClockNumberDecoration getDefaultDecoration() {
    return TimePickerClockNumberDecoration(
      style12: getDefaultTextStyle(),
      style6: getDefaultTextStyle(),
      style9: getDefaultTextStyle(),
      style3: getDefaultTextStyle(),
    );
  }
}
