import 'dart:math';

import 'package:flutter/material.dart';

///
/// used to decorate our sweep part or a part between our init and end point
///
class TimePickerSweepDecoration {
  /// defines the picker stroke width
  final double pickerStrokeWidth;

  /// define the stroke cap
  /// Default Value: [true]
  /// If true then [StrokeCap.round] used and if false then [StrokeCap.butt] used
  final bool useRoundedPickerCap;

  /// define the picker color
  /// optional color
  final Color? pickerColor;

  /// A 2D sweep gradient.
  ///
  /// {@tool snippet}
  ///
  /// This sample takes the above gradient and rotates it by radians,
  /// i.e. 45 degrees.
  ///
  /// ```dart
  /// new SweepGradient(
  ///       startAngle: 3 * pi / 2,
  ///       endAngle: 7 * pi / 2,
  ///       tileMode: TileMode.repeated,
  ///       colors: [Colors.blue, Colors.red],
  ///     )
  /// ```
  /// {@end-tool}
  final SweepGradient? pickerGradient;

  /// used to show connector line
  /// Default Value: [false]
  final bool showConnector;

  /// defines width for the connector line
  /// optional width
  final double? connectorStrokeWidth;

  /// define the connector line color
  /// optional color
  final Color? connectorColor;

  /// Creates a TimePickerSweepDecoration.
  TimePickerSweepDecoration({
    required this.pickerStrokeWidth,
    this.useRoundedPickerCap = true,
    this.pickerColor,
    this.pickerGradient,
    this.showConnector = false,
    this.connectorStrokeWidth,
    this.connectorColor,
  })  : assert(
          (pickerGradient == null && pickerColor == null) ? false : true,
          'either a color or gradient must be provided too allow sweep drawing',
        ),
        assert(
          (pickerGradient != null && pickerColor != null) ? false : true,
          'color is not needed when a gradient is defined',
        );

  paint(
    Canvas canvas,
    Size size,
    Offset center,
    double startAngle,
    double sweepAngle,
  ) {
    var tmpStartAngle = -pi / 2 + startAngle;
    var sweepRect = Rect.fromCircle(
      center: center,
      radius: getRadius(size.width, size.height),
    );

    Paint timeProgressBrush = _getPaint(rect: sweepRect);
    canvas.drawArc(
      sweepRect,
      tmpStartAngle,
      sweepAngle,
      false,
      timeProgressBrush,
    );

    if (showConnector) {
      var timeProgressConnectorBrush = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = connectorStrokeWidth ?? 1
        ..color = connectorColor ?? Colors.black;

      canvas.drawArc(
        sweepRect,
        tmpStartAngle,
        sweepAngle,
        false,
        timeProgressConnectorBrush,
      );
    }
  }

  Paint _getPaint({double? width, PaintingStyle? style, Rect? rect}) {
    var paint = Paint()
      ..strokeCap = useRoundedPickerCap ? StrokeCap.round : StrokeCap.butt
      ..style = style ?? PaintingStyle.stroke
      ..strokeWidth = width ?? pickerStrokeWidth;

    if (pickerColor != null) paint..color = pickerColor!;

    if (pickerGradient != null) {
      paint..shader = pickerGradient!.createShader(rect!);
    }

    return paint;
  }

  /// Creates a copy of the TimePickerSweepDecoration.
  TimePickerSweepDecoration copyWith({
    double? pickerStrokeWidth,
    Color? pickerColor,
    SweepGradient? pickerGradient,
    bool? showConnector,
    double? connectorStrokeWidth,
    Color? connectorColor,
  }) {
    return TimePickerSweepDecoration(
      pickerStrokeWidth: pickerStrokeWidth ?? this.pickerStrokeWidth,
      pickerColor: pickerColor ?? this.pickerColor,
      pickerGradient: pickerGradient ?? this.pickerGradient,
      showConnector: showConnector ?? this.showConnector,
      connectorStrokeWidth: connectorStrokeWidth ?? this.connectorStrokeWidth,
      connectorColor: connectorColor ?? this.connectorColor,
    );
  }

  double getRadius(double width, double height) =>
      min(width / 2, height / 2) - pickerStrokeWidth;
}
