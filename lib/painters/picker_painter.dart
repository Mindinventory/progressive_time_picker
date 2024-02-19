import 'dart:math';
import 'package:flutter/material.dart';
import 'package:progressive_time_picker/decoration/time_picker_sweep_decoration.dart';
import '../src/utils.dart';
import '../decoration/time_picker_decoration.dart';

///
/// Painter class of the TimePicker.
///
class PickerPainter extends CustomPainter {
  /// Defines the start angle of the picker.
  double startAngle;

  /// Defines the end angle of the picker.
  double endAngle;

  /// Defines the sweep angle of the picker.
  double sweepAngle;

  /// Defines the decoration used for the picker.
  TimePickerDecoration pickerDecorator;

  /// Defines the disabled time start angle of the picker.
  double? disableTimeStartAngle;

  /// Defines the disabled time end angle of the picker.
  double? disableTimeEndAngle;

  /// Defines the disabled time sweep angle of the picker.
  double? disabledSweepAngle;

  /// Defines the disabled range color.
  Color? disabledRangeColor;

  /// Defines the error color on disabled range.
  Color? errorColor;

  /// Used to draw the start or end handler on th top
  /// Default value: [false]
  bool drawInitHandlerOnTop;

  Offset _initHandler = Offset(0, 0);
  Offset _endHandler = Offset(0, 0);
  Offset _center = Offset(0, 0);
  double _radius = 0.0;

  Offset get initHandlerCenterLocation => _initHandler;

  Offset get endHandlerCenterLocation => _endHandler;

  Offset get center => _center;

  double get radius => _radius;

  /// Creates a PickerPainter.
  PickerPainter({
    required this.startAngle,
    required this.endAngle,
    required this.sweepAngle,
    required this.pickerDecorator,
    this.disableTimeStartAngle,
    this.disableTimeEndAngle,
    this.disabledSweepAngle,
    this.disabledRangeColor,
    this.errorColor,
    this.drawInitHandlerOnTop = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _center = Offset(size.width / 2, size.height / 2);
    _radius = min(size.width / 2, size.height / 2) -
        pickerDecorator.sweepDecoration.pickerStrokeWidth;

    pickerDecorator.sweepDecoration.paint(
      canvas,
      size,
      center,
      startAngle,
      sweepAngle,
    );

    if (disableTimeStartAngle != null &&
        disableTimeEndAngle != null &&
        disabledSweepAngle != null) {
      TimePickerSweepDecoration disableSweepDecorator =
          TimePickerSweepDecoration(
        pickerStrokeWidth: pickerDecorator.sweepDecoration.pickerStrokeWidth,
        pickerColor: disabledRangeColor ?? Colors.grey.shade600,
        connectorColor: pickerDecorator.sweepDecoration.connectorColor,
        connectorStrokeWidth:
            pickerDecorator.sweepDecoration.connectorStrokeWidth,
        pickerGradient: pickerDecorator.sweepDecoration.pickerGradient,
        showConnector: false,
        useRoundedPickerCap: false,
      );
      disableSweepDecorator.paint(
        canvas,
        size,
        center,
        disableTimeStartAngle!,
        disabledSweepAngle!,
      );
    }

    if (drawInitHandlerOnTop) {
      _drawEndHandler(canvas);
      _drawStartHandler(canvas);
    } else {
      _drawStartHandler(canvas);
      _drawEndHandler(canvas);
    }
  }

  /// draw end handler
  void _drawEndHandler(Canvas canvas) {
    _endHandler = radiansToCoordinates(center, -pi / 2 + endAngle, radius);
    pickerDecorator.endHandlerDecoration.paint(
      canvas,
      endHandlerCenterLocation,
    );
  }

  /// draw start handler
  void _drawStartHandler(Canvas canvas) {
    _initHandler = radiansToCoordinates(center, -pi / 2 + startAngle, radius);
    pickerDecorator.initHandlerDecoration.paint(
      canvas,
      initHandlerCenterLocation,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
