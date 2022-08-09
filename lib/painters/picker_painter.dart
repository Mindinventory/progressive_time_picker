import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../src/utils.dart';
import '../decoration/time_picker_decoration.dart';

class PickerPainter extends CustomPainter {
  double startAngle;
  double endAngle;
  double sweepAngle;
  TimePickerDecoration pickerDecorator;

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
  });

  @override
  void paint(Canvas canvas, Size size) {
    _center = Offset(size.width / 2, size.height / 2);
    _radius = min(size.width / 2, size.height / 2) -
        pickerDecorator.sweepDecoration.pickerStrokeWidth;

    pickerDecorator.sweepDecoration
        .paint(canvas, size, center, startAngle, sweepAngle);

    /// draw start handler
    _initHandler = radiansToCoordinates(center, -pi / 2 + startAngle, radius);
    pickerDecorator.initHandlerDecoration
        .paint(canvas, initHandlerCenterLocation);

    /// draw end handler
    _endHandler = radiansToCoordinates(center, -pi / 2 + endAngle, radius);
    pickerDecorator.endHandlerDecoration
        .paint(canvas, endHandlerCenterLocation);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
