import 'package:flutter/material.dart';

import '../src/utils.dart';

class TimePickerClockNumberDecoration {
  /// Set to true to enable clock numbers
  /// default value: false
  final bool showNumberIndicators;

  /// play with this number to define reduce the font size of the clock number
  /// default value: 0.7
  final double textScaleFactor;

  /// play with this number to define the scale of the clock number
  /// default value: 0.9
  /// Depends on font size and textScaleFactor
  final double scaleFactor;

  /// play with this number to define the position of the clock number
  /// default value: 0.42
  /// In this positionFactor, 0 denotes the closest point to the center,
  /// while 1 represents the farthest point from the center
  final double positionFactor;

  /// Optional Style to be applied to the the clock number in the clock when
  /// clock is enable
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
  /// default value: [ClockTimeFormat.twentyFourHours]
  ClockTimeFormat clockTimeFormat;

  /// Defines the clock time increment format
  /// default value: [ClockIncrementTimeFormat.fiveMin]
  ClockIncrementTimeFormat clockIncrementTimeFormat;

  /// Defines the clock hour increment count
  /// default value: [ClockIncrementHourFormat.six]
  ClockIncrementHourFormat clockIncrementHourFormat;

  /// this number is for customize the last number displayed in clock.
  /// eg: if endNumber == null, with ClockIncrementHourFormat.twentyFour
  /// we will show 24 for the last item
  /// eg: if endNumber == 0, we will show 0 instead of 24
  /// default value: null
  int? endNumber;

  TimePickerClockNumberDecoration({
    this.clockTimeFormat = ClockTimeFormat.twentyFourHours,
    this.clockIncrementTimeFormat = ClockIncrementTimeFormat.fiveMin,
    this.showNumberIndicators = true,
    this.textScaleFactor = 0.7,
    this.scaleFactor = 0.9,
    this.positionFactor = 0.42,
    this.textStyle,
    this.defaultFontSize = 18,
    this.defaultTextColor = Colors.black,
    this.clockIncrementHourFormat = ClockIncrementHourFormat.six,
    this.endNumber,
  });

  /// this method will be call when [textStyle] is not defined
  /// [defaultFontSize] Optional, defines the font size to use when the a Style
  /// is not define,
  /// default value: 18
  /// [defaultTextColor] Optional, defines the main color to get use when the a
  /// Style is not define,
  /// default value: [Colors.black]
  TextStyle getDefaultTextStyle() {
    return TextStyle(
      color: defaultTextColor,
      fontWeight: FontWeight.bold,
      fontSize: defaultFontSize * scaleFactor * textScaleFactor,
    );
  }
}
