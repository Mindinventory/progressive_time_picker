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

  /// Optional Style to be applied to the the clock number in the clock when clock is enable
  /// if not need then set color to transparent
  /// default value: NULL
  /// See also:
  /// * getDefaultTextStyle
  TextStyle? textStyle;

  /// Optional, defines the font size to use when the a Style is not define,
  /// default value: 18
  double defaultFontSize;

  /// Optional, defines the main color to get use when the a Style is not define,
  /// default value: [Colors.black]
  Color defaultTextColor;

  /// Defines the clock time format either twelveHours or twentyFourHours
  /// default value: [ClockTimeFormat.TWENTYFOURHOURS]
  ClockTimeFormat clockTimeFormat;

  /// Defines the clock time increment format
  /// default value: [ClockIncrementTimeFormat.FIVEMIN]
  ClockIncrementTimeFormat clockIncrementTimeFormat;

  /// Defines the clock hour increment count
  /// default value: [ClockIncrementHourFormat.SIX]
  ClockIncrementHourFormat clockIncrementHourFormat;

  TimePickerClockNumberDecoration({
    this.clockTimeFormat = ClockTimeFormat.TWENTYFOURHOURS,
    this.clockIncrementTimeFormat = ClockIncrementTimeFormat.FIVEMIN,
    this.showNumberIndicators = true,
    this.textScaleFactor = 0.7,
    this.scaleFactor = 0.9,
    this.textStyle,
    this.defaultFontSize = 18,
    this.defaultTextColor = Colors.black,
    this.clockIncrementHourFormat = ClockIncrementHourFormat.SIX,
  });

  /// this method will be call when [textStyle] is not defined
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
}
