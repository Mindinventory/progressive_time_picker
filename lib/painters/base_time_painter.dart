import 'dart:math';
import 'package:flutter/material.dart';
import '../decoration/time_picker_clock_number_decoration.dart';
import '../decoration/time_picker_sector_decoration.dart';
import '../decoration/time_picker_decoration.dart';
import '../src/utils.dart';

class BaseTimePainter extends CustomPainter {
  TimePickerDecoration decoration;
  int primarySectors;
  int secondarySectors;
  double pickerStrokeWidth;

  Offset center = Offset(0, 0);
  double radius = 0.0;

  BaseTimePainter({
    required this.decoration,
    required this.primarySectors,
    required this.secondarySectors,
    required this.pickerStrokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint baseBrush = _getPaint(color: decoration.baseColor);

    /// we need this in the parent to calculate if the user clicks on the circumference
    center = Offset(size.width / 2, size.height / 2);
    radius = min(size.width / 2, size.height / 2) - pickerStrokeWidth;

    assert(radius > 0);

    canvas.drawCircle(
        center, radius + decoration.pickerBaseCirclePadding, baseBrush);

    if (secondarySectors > 0) {
      _paintSectors(
          secondarySectors,
          decoration.secondarySectorsDecoration ?? TimePickerSectorDecoration(),
          canvas);
    }

    if (primarySectors > 0) {
      _paintSectors(
          primarySectors,
          decoration.primarySectorsDecoration ??
              TimePickerSectorDecoration(size: 6),
          canvas);
    }

    if (decoration.clockNumberDecoration != null &&
        decoration.clockNumberDecoration!.showNumberIndicators)
      _drawNumberIndicators(canvas, size, decoration.clockNumberDecoration!,
          decoration.clockNumberDecoration!.clockTimeFormat);
  }

  List<Offset> _paintSectors(
      int sectors, TimePickerSectorDecoration decoration, Canvas canvas) {
    Paint sectionBrush = _getPaint(
        color: decoration.color,
        width: decoration.width,
        roundedCap: decoration.useRoundedCap);

    var initSectors = getSectionsCoordinatesInCircle(
        center, radius - decoration.size - decoration.radiusPadding, sectors);
    var endSectors = getSectionsCoordinatesInCircle(
        center, radius + decoration.size - decoration.radiusPadding, sectors);

    _paintLines(canvas, initSectors, endSectors, sectionBrush);

    return initSectors;
  }

  void _paintLines(
      Canvas canvas, List<Offset> inits, List<Offset> ends, Paint section) {
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
      ClockTimeFormat clockTimeFormat) {
    double p = 32.0;

    Offset paddingX = Offset(p * decoration.scaleFactor, 0.0);
    Offset paddingY = Offset(0.0, p * decoration.scaleFactor);

    var tp12 = getIndicatorText('${clockTimeFormat.value}',
        decoration.style12 ?? decoration.getDefaultTextStyle());
    tp12.paint(canvas, size.topCenter(-tp12.size.topCenter(-paddingY)));

    var tp9 = getIndicatorText(
        clockTimeFormat == ClockTimeFormat.twentyFourHours ? '18' : '9',
        decoration.style9 ?? decoration.getDefaultTextStyle());
    tp9.paint(canvas, size.centerLeft(-tp9.size.centerLeft(-paddingX)));

    var tp6 = getIndicatorText("${clockTimeFormat.value ~/ 2}",
        decoration.style6 ?? decoration.getDefaultTextStyle());
    tp6.paint(canvas, size.bottomCenter(-tp6.size.bottomCenter(paddingY)));

    var tp3 = getIndicatorText("${clockTimeFormat.value ~/ 4}",
        decoration.style3 ?? decoration.getDefaultTextStyle());
    tp3.paint(canvas, size.centerRight(-tp3.size.centerRight(paddingX)));
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
        ..strokeWidth = width ?? pickerStrokeWidth;

  TextPainter getIndicatorText(String text, TextStyle style) {
    TextPainter tp6 = TextPainter(
        text: TextSpan(style: style, text: text),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp6.layout();

    return tp6;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
