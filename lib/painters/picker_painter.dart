import 'dart:math';
import 'package:flutter/material.dart';
import 'package:progressive_time_picker/decoration/time_picker_sweep_decoration.dart';
import '../src/utils.dart';
import '../decoration/time_picker_decoration.dart';

class PickerPainter extends CustomPainter {
  double startAngle;
  double endAngle;
  double sweepAngle;
  TimePickerDecoration pickerDecorator;
  double? disableTimeStartAngle;
  double? disableTimeEndAngle;
  double? disabledSweepAngle;
  Color? disabledRangeColor;
  Color? errorColor;

  Offset _initHandler = Offset(0, 0);
  Offset _endHandler = Offset(0, 0);
  Offset _center = Offset(0, 0);
  double _radius = 0.0;

  Offset get initHandlerCenterLocation => _initHandler;

  Offset get endHandlerCenterLocation => _endHandler;

  Offset get center => _center;

  double get radius => _radius;

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
          canvas, size, center, disableTimeStartAngle!, disabledSweepAngle!);
    }

    /// draw start handler
    _initHandler = radiansToCoordinates(center, -pi / 2 + startAngle, radius);
    pickerDecorator.initHandlerDecoration.paint(
      canvas,
      initHandlerCenterLocation,
    );

    /// draw end handler
    _endHandler = radiansToCoordinates(center, -pi / 2 + endAngle, radius);
    pickerDecorator.endHandlerDecoration.paint(
      canvas,
      endHandlerCenterLocation,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
