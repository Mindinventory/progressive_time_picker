import 'package:flutter/material.dart';

///
/// used to decorate our init or end handler of time picker
///
class TimePickerHandlerDecoration {
  /// shape defines the handler default shape could be a square or circle
  /// default shape is circle
  final BoxShape shape;

  /// The icon to display on top of the handler
  /// if The [Icon.size] is not provided the default is 30
  /// ```dart
  /// Icon(Icons.filter_tilt_shift, size: iconSize, color: Colors.teal[700]);
  /// ```
  final Icon? icon;

  /// handler default color
  final Color color;

  /// optional shadow which will get apply to the handler, if not provided there
  /// handler will get draw without shadow
  final BoxShadow? shadow;

  /// default handler radius = 8
  /// when using shape = rectangle, the rect will get generated from Rect.fromCircle
  final double radius;

  /// Helps to define which border you want to apply to the handler shape
  ///
  /// {@tool snippet}
  ///
  /// This sample takes the above gradient and rotates it by radians,
  /// i.e. 45 degrees.
  ///
  /// ```dart
  /// new Border.all(width: 3, color: Colors.green);
  /// new Border(top: BorderSide(width: 3.0, color: Colors.green));
  /// ```
  /// {@end-tool}
  final Border? border;

  /// if a value is provided it must be bigger than [this.radius] otherwise it
  /// will not draw the expected effect the outter handler will only get draw
  /// when [this.showHandlerOutter] = true.
  ///
  /// See also:
  ///
  ///  * [this.showHandlerOutter] for additional information
  final double handlerOutterRadius;

  /// draw a outter container for the handler, the outter shape could be either
  /// a rectangle or circle the shape will always match the default handler
  /// shape which is control by using the [this.shape]
  /// default value is always false unless defined
  /// if set to true then the handlerOutterRadius also needs to get set unless
  /// you want to use the default value
  /// showHandlerOutter enable then both [this.shadow] and [this.icon] are
  /// expected to be null.
  /// we are keeping this as backwards compatibility since similar effect could
  /// be generate by using
  ///
  /// ```dart
  /// Icon(Icons.filter_tilt_shift, size: iconSize, color: Colors.teal[700]);
  /// ```
  final bool showHandlerOutter;

  /// used to show the handler on time picker
  /// Default Value: [true]
  final bool showHandler;

  /// define the stroke cap for the handler on time picker
  /// Default Value: [false]
  /// If true then [StrokeCap.round] used and if false then [StrokeCap.butt] used
  final bool useRoundedPickerCap;

  /// Creates a TimePickerHandlerDecoration.
  TimePickerHandlerDecoration({
    this.color = Colors.black,
    this.shape = BoxShape.circle,
    this.shadow,
    this.icon,
    this.radius = 8,
    this.border,
    this.handlerOutterRadius = 12,
    this.useRoundedPickerCap = false,
    this.showHandler = true,
    this.showHandlerOutter = false,
  })  : assert(
          (showHandlerOutter && shadow != null) ? false : true,
          'shadows does not draw well when using the default HandlerOutter, try using border instead',
        ),
        assert(
          (showHandlerOutter && icon != null) ? false : true,
          'handlerOutterRadius can not be use with icon',
        ),
        assert(
          (!showHandlerOutter ||
                  (showHandlerOutter && handlerOutterRadius > radius))
              ? true
              : false,
          'when using handlerOutterRadius needs to be bigger than radius value',
        );

  /// paint
  void paint(
    Canvas canvas,
    Offset center,
  ) {
    var handlerBrush = _getPaint(
      color: this.color,
      width: this.radius,
      style: PaintingStyle.fill,
    );

    var rect = Rect.fromCircle(center: center, radius: this.radius);
    _drawShadow(canvas, center);

    if (showHandler) {
      if (shape == BoxShape.circle) {
        canvas.drawCircle(center, this.radius, handlerBrush);
      } else {
        var path = Path()..addRect(rect);
        canvas.drawPath(path, handlerBrush);
      }
    }

    _drawHandlerOutter(canvas, center);

    /// draw the border when enabled
    if (border != null) border!.paint(canvas, rect, shape: shape);

    _drawIcon(canvas: canvas, center: center);
  }

  /// This method owns drawing the default outter handler which could be another
  /// circle or a rectangle depending on the shape parameter
  void _drawHandlerOutter(Canvas canvas, Offset center) {
    if (!this.showHandlerOutter) return;

    Paint handlerOutterBrush = _getPaint(color: this.color, width: 2.0);

    if (shape == BoxShape.circle) {
      canvas.drawCircle(center, this.handlerOutterRadius, handlerOutterBrush);
    } else {
      var parent = Path()
        ..addRect(Rect.fromCircle(
          center: center,
          radius: this.handlerOutterRadius,
        ));

      canvas.drawPath(parent, handlerOutterBrush);
    }
  }

  void _drawShadow(Canvas canvas, Offset center) {
    if (shadow == null) return;

    var parent = Path();

    if (shape == BoxShape.circle) {
      parent
        ..addOval(Rect.fromCircle(
          center: center,
          radius: this.radius + shadow!.spreadRadius,
        ));
    } else {
      parent
        ..addRect(Rect.fromCircle(
          center: center,
          radius: this.radius + shadow!.spreadRadius,
        ));
    }

    Paint shadowPaintBrush = Paint()
      ..color = shadow!.color.withOpacity(.5)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        Shadow.convertRadiusToSigma(
          shadow!.blurRadius + shadow!.spreadRadius,
        ),
      );

    canvas.drawPath(parent, shadowPaintBrush);
  }

  /// use this method to create a TextPainter which owns drawing a Icon in the
  /// canvas,
  /// the icon will get added in the center of the handler
  /// the icon will be on top of any other shape drew.
  void _drawIcon({
    required Canvas canvas,
    required Offset center,
  }) {
    if (this.icon == null) return;

    var iconSize = this.icon!.size ?? 30.0;

    TextPainter textPainter = TextPainter(textDirection: TextDirection.rtl);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon!.icon!.codePoint),
      style: TextStyle(
        color: icon!.color,
        fontSize: iconSize,
        fontFamily: icon!.icon!.fontFamily,
      ),
    );
    textPainter.layout();

    /// Radius of inner circle or the icon is x/2
    var val = iconSize / 2;

    textPainter.paint(canvas, Offset(center.dx - val, center.dy - val));
  }

  Paint _getPaint({
    required Color color,
    required double width,
    PaintingStyle? style,
  }) =>
      Paint()
        ..color = color
        ..strokeCap = useRoundedPickerCap ? StrokeCap.round : StrokeCap.butt
        ..style = style ?? PaintingStyle.stroke
        ..strokeWidth = width;

  /// Creates a copy of the TimePickerHandlerDecoration.
  TimePickerHandlerDecoration copyWith({
    BoxShape? shape,
    Icon? icon,
    Color? color,
    BoxShadow? shadow,
    double? radius,
    Border? border,
    double? handlerOutterRadius,
    bool? showRoundedCapInSelection,
  }) {
    return TimePickerHandlerDecoration(
      shape: shape ?? this.shape,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      shadow: shadow ?? this.shadow,
      radius: radius ?? this.radius,
      border: border ?? this.border,
      handlerOutterRadius: handlerOutterRadius ?? this.handlerOutterRadius,
      useRoundedPickerCap:
          showRoundedCapInSelection ?? this.useRoundedPickerCap,
    );
  }
}
