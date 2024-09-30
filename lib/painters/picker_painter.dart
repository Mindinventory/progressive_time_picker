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

  /// Defines the disabled time start angles of the picker.
  List<double?> disableTimeStartAngle;

  /// Defines the disabled time end angles of the picker.
  List<double?> disableTimeEndAngle;

  /// Defines the disabled time sweep angles of the picker.
  List<double?> disabledSweepAngle;

  /// Defines the disabled range color.
  Color? disabledRangeColor;

  /// Defines the error color on disabled range.
  Color? errorColor;

  /// Used to draw the start or end handler on th top
  /// Default value: [false]
  bool drawInitHandlerOnTop;

  /// Defines the offset for the init handler.
  Offset _initHandler = Offset(0, 0);

  /// Defines the offset for the end handler.
  Offset _endHandler = Offset(0, 0);

  /// Defines the center for the painter.
  Offset _center = Offset(0, 0);

  /// Defines the radius of the painter.
  double _radius = 0.0;

  /// Getter for the offset for the init handler.
  Offset get initHandlerCenterLocation => _initHandler;

  /// Getter for the offset for the end handler.
  Offset get endHandlerCenterLocation => _endHandler;

  /// Getter for the center for the painter.
  Offset get center => _center;

  /// Getter for the radius of the painter.
  double get radius => _radius;

  /// Creates a PickerPainter.
  PickerPainter({
    required this.startAngle,
    required this.endAngle,
    required this.sweepAngle,
    required this.pickerDecorator,
    required this.disableTimeStartAngle,
    required this.disableTimeEndAngle,
    required this.disabledSweepAngle,
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

    if (disableTimeStartAngle.isNotEmpty &&
        disableTimeEndAngle.isNotEmpty &&
        disabledSweepAngle.isNotEmpty) {
      for (int i = 0; i < disableTimeStartAngle.length; i++) {
        _paintDisabledRange(
          canvas,
          size,
          disableTimeStartAngle[i]!,
          disableTimeEndAngle[i]!,
          disabledSweepAngle[i]!,
        );
      }
    }

    if (drawInitHandlerOnTop) {
      _drawEndHandler(canvas);
      _drawStartHandler(canvas);
    } else {
      _drawStartHandler(canvas);
      _drawEndHandler(canvas);
    }
  }

  void _paintDisabledRange(Canvas canvas, Size size, double startAngle,
      double endAngle, double sweepAngle) {
    TimePickerSweepDecoration disableSweepDecorator = TimePickerSweepDecoration(
      pickerStrokeWidth: pickerDecorator.sweepDecoration.pickerStrokeWidth,
      pickerColor: disabledRangeColor ?? Colors.grey.shade600,
      connectorColor: pickerDecorator.sweepDecoration.connectorColor,
      connectorStrokeWidth: pickerDecorator.sweepDecoration.connectorStrokeWidth,
      pickerGradient: pickerDecorator.sweepDecoration.pickerGradient,
      showConnector: false,
      useRoundedPickerCap: false,
    );
    disableSweepDecorator.paint(
      canvas,
      size,
      center,
      startAngle,
      sweepAngle,
    );
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
