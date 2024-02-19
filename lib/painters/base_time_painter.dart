import 'dart:math';

import 'package:flutter/material.dart';

import '../decoration/time_picker_clock_number_decoration.dart';
import '../decoration/time_picker_sector_decoration.dart';
import '../decoration/time_picker_decoration.dart';
import '../src/utils.dart';

///
/// Base class to paint the time picker.
///
class BaseTimePainter extends CustomPainter {
  /// Defines the TimePickerDecoration.
  TimePickerDecoration decoration;

  /// Defines the primary sectors in the time picker.
  int primarySectors;

  /// Defines the secondary sectors in the time picker.
  int secondarySectors;

  /// Defines the picker stroke width.
  double pickerStrokeWidth;

  Offset center = Offset(0, 0);
  double radius = 0.0;

  /// Creates a BaseTimePainter.
  BaseTimePainter({
    required this.decoration,
    required this.primarySectors,
    required this.secondarySectors,
    required this.pickerStrokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint baseBrush = _getPaint(color: decoration.baseColor);

    /// we need this in the parent to calculate if the user clicks on the
    /// circumference
    center = Offset(size.width / 2, size.height / 2);
    radius = min(size.width / 2, size.height / 2) - pickerStrokeWidth;

    assert(radius > 0);

    canvas.drawCircle(
      center,
      radius + decoration.pickerBaseCirclePadding,
      baseBrush,
    );

    if (secondarySectors > 0) {
      _paintSectors(
        secondarySectors,
        decoration.secondarySectorsDecoration ?? TimePickerSectorDecoration(),
        canvas,
      );
    }

    if (primarySectors > 0) {
      _paintSectors(
        primarySectors,
        decoration.primarySectorsDecoration ??
            TimePickerSectorDecoration(size: 6),
        canvas,
      );
    }

    if (decoration.clockNumberDecoration != null &&
        decoration.clockNumberDecoration!.showNumberIndicators) {
      _drawNumberIndicators(
        canvas,
        size,
        decoration.clockNumberDecoration!,
        decoration.clockNumberDecoration!.clockTimeFormat,
      );
    }
  }

  List<Offset> _paintSectors(
    int sectors,
    TimePickerSectorDecoration decoration,
    Canvas canvas,
  ) {
    Paint sectionBrush = _getPaint(
      color: decoration.color,
      width: decoration.width,
      roundedCap: decoration.useRoundedCap,
    );

    var initSectors = getSectionsCoordinatesInCircle(
      center,
      radius - decoration.size - decoration.radiusPadding,
      sectors,
    );
    var endSectors = getSectionsCoordinatesInCircle(
      center,
      radius + decoration.size - decoration.radiusPadding,
      sectors,
    );

    _paintLines(
      canvas,
      initSectors,
      endSectors,
      sectionBrush,
    );

    return initSectors;
  }

  void _paintLines(
    Canvas canvas,
    List<Offset> inits,
    List<Offset> ends,
    Paint section,
  ) {
    assert(inits.length == ends.length && inits.length > 0);

    for (var i = 0; i < inits.length; i++) {
      canvas.drawLine(inits[i], ends[i], section);
    }
  }

  /// allows to show clock inside the picker
  void _drawNumberIndicators(
    Canvas canvas,
    Size size,
    TimePickerClockNumberDecoration decoration,
    ClockTimeFormat clockTimeFormat,
  ) {
    int getIncrementCount = 15 *
        (24 ~/ decoration.clockTimeFormat.value) *
        decoration.clockIncrementHourFormat.value;

    var centerX = size.width / 2;
    var centerY = size.height / 2;

    for (int i = 0; i < 360; i = i + getIncrementCount) {
      var x1 =
          centerX + (centerX * decoration.positionFactor) * sin(i * pi / 180);
      var y1 =
          -centerY + (centerX * decoration.positionFactor) * cos(i * pi / 180);
      var tp = getIndicatorText(
        i == 0
            ? (decoration.endNumber ?? decoration.clockTimeFormat.value)
            : ((i / 15) * (decoration.clockTimeFormat.value / 24)).toInt(),
        decoration.textStyle ??
            decoration.getDefaultTextStyle().copyWith(
                  fontSize: decoration.clockIncrementHourFormat.value == 1
                      ? 10
                      : (decoration.defaultFontSize *
                          decoration.scaleFactor *
                          decoration.textScaleFactor),
                ),
      );
      tp.layout();
      tp.paint(canvas, Offset(x1 - (tp.width / 2), -y1 - (tp.height / 2)));
    }
  }

  Paint _getPaint({
    required Color color,
    double? width,
    PaintingStyle? style,
    bool roundedCap = false,
  }) =>
      Paint()
        ..color = color
        ..strokeCap = roundedCap ? StrokeCap.round : StrokeCap.butt
        ..style = style ?? PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.bevel
        ..strokeWidth = width ?? pickerStrokeWidth;

  TextPainter getIndicatorText(var text, TextStyle style) {
    TextPainter tp6 = TextPainter(
      text: TextSpan(style: style, text: text.toString()),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp6.layout();

    return tp6;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
