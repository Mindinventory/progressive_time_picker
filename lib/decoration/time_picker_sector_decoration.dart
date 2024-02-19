import 'package:flutter/material.dart';

///
/// used to decorate our sector of the time picker
///
class TimePickerSectorDecoration {
  /// defines the divider's color
  /// Default value: [Colors.blue]
  final Color color;

  /// indicates the size of the divider
  /// Default value: 10
  final double size;

  /// indicates the width of the divider
  /// Default value: 2
  final double width;

  /// change this to modify the sides of the dividers
  /// [true] == StrokeCap.round
  /// [false] == StrokeCap.butt
  final bool useRoundedCap;

  /// to add extra padding from circle's center point
  final double radiusPadding;

  /// Creates a TimePickerSectorDecoration.
  TimePickerSectorDecoration({
    this.color = Colors.grey,
    this.size = 6.0,
    this.width = 2.0,
    this.useRoundedCap = true,
    this.radiusPadding = 0.0,
  }) : assert(size > 0,
            "attribute [primaryDividerSize] needs to be bigger than 0");

  /// Creates a copy of the TimePickerSectorDecoration.
  TimePickerSectorDecoration copyWith({
    Color? color,
    double? size,
    double? width,
    double? padding,
  }) {
    return TimePickerSectorDecoration(
      color: color ?? this.color,
      size: size ?? this.size,
      width: width ?? this.width,
      radiusPadding: padding ?? this.radiusPadding,
    );
  }
}
