import 'dart:math';

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ElevationPoint {
  ElevationPoint({required this.altitude, required this.timestamp, this.color});
  DateTime timestamp;
  int altitude;
  Color? color;
}

class GraphElevation extends StatelessWidget {
  const GraphElevation(
      {super.key,
      required this.from,
      required this.to,
      this.currentTime,
      bool displayTime = false,
      this.backgroundColor = Colors.white,
      required this.listTraces});

  final DateTime from;
  final DateTime to;
  final DateTime? currentTime;
  final int minGraduationWidth = 10;
  final Color backgroundColor;
  final double graduationHeight = 25; // graduations horizontales
  final double graduationWidth = 40; // graduations verticales
  final List<List<ElevationPoint>> listTraces;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        print(details.localPosition);
      },
      child: CustomPaint(
        painter: DrawPainterGraduation(
            from: from,
            to: to,
            currentTime: currentTime,
            backgroundColor: backgroundColor,
            listTraces: listTraces)
          ..graduationHeight = graduationHeight
          ..graduationWidth = graduationWidth,
        child: const SizedBox.expand(),
      ),
    );
  }
}

enum TwoPass { drawLines, drawTexts }

class DrawPainterGraduation extends CustomPainter {
  DrawPainterGraduation(
      {required this.from,
      required this.to,
      this.currentTime,
      required this.backgroundColor,
      required this.listTraces});

  //double pixWidth;
  DateTime from, to;
  double minWidthText = 20;
  DateTime? currentTime;
  late TwoPass k;
  Color backgroundColor;
  double graduationHeight = 0;
  double graduationWidth = 0;
  late double _minAlt;
  late double _maxAlt;
  final double _topAltMargin = 100; // 100 m
  List<List<ElevationPoint>> listTraces;
  double? ratioAltitude;
  double? ratioTimestamp;
  double? xOffset;
  double? yOffset;

  void updateMinMaxAltitude() {
    _minAlt = 100000;
    _maxAlt = 0;
    for (List<ElevationPoint> t in listTraces) {
      // surement moyen de faire cela avec reduce mais je maitrise moyennement et une passe je fais le min et le max et cela fonctionne pour toute  la liste
      // peut-etre plus rapide en faison 2 passes mais je n'ai pas testé
      for (ElevationPoint p in t) {
        if (p.altitude < _minAlt) {
          _minAlt = p.altitude.toDouble();
        } else if (p.altitude > _maxAlt) {
          _maxAlt = p.altitude.toDouble();
        }
      }
    }
    _maxAlt += _topAltMargin;
  }

  @override
  void paint(Canvas canvas, Size size) {
    xOffset = graduationWidth;
    yOffset = graduationHeight;

    ratioTimestamp = (to.millisecondsSinceEpoch - from.millisecondsSinceEpoch) /
        (size.width - xOffset!);

    updateMinMaxAltitude();
    ratioAltitude = (_maxAlt - _minAlt) / (size.height - yOffset!);

//************************************************************** */
    // graduations
    horizontalGraduations(canvas, size);
    verticalGraduations(canvas, size);
    drawGraph(canvas);

    // on affiche le curseur
    if (currentTime != null) {
      final p1 = Offset(
          ((currentTime!.millisecondsSinceEpoch - from.millisecondsSinceEpoch) /
                  ratioTimestamp!) +
              xOffset!,
          size.height);
      final p2 = Offset(p1.dx, 0);
      final paint = Paint()
        ..color = Colors.red
        ..strokeWidth = 1;
      canvas.drawLine(p1, p2, paint);
    }
  }

  void drawGraph(Canvas canvas) {
    ElevationPoint? lastPoint;
    for (ElevationPoint currentPoint in listTraces[0]) {
      if (lastPoint != null) {
        final paint = Paint()
          ..color = Colors.green
          ..strokeWidth = 1;
        /* print(
            "from ${(lastPoint.timestamp.millisecondsSinceEpoch - from.millisecondsSinceEpoch) / ratioTimestamp}"); */
        canvas.drawLine(
            Offset(
                (lastPoint.timestamp.millisecondsSinceEpoch -
                            from.millisecondsSinceEpoch) /
                        ratioTimestamp! +
                    xOffset!,
                (_maxAlt - lastPoint.altitude) / ratioAltitude!),
            Offset(
                (currentPoint.timestamp.millisecondsSinceEpoch -
                            from.millisecondsSinceEpoch) /
                        ratioTimestamp! +
                    xOffset!,
                (_maxAlt - currentPoint.altitude) / ratioAltitude!),
            paint);
      }
      lastPoint = currentPoint;
    }
  }

  void horizontalGraduations(Canvas canvas, Size size) {
    const ratioHour = 25000;
    const ratio30min = 25000;
    const ratio15min = 20000;
    const ratio5min = 80000;
    const ratio1min = 20000;
    const ratioTxt5min = 8000;

    // bgColor pour les graduations horizontales
    drawRect(
        canvas: canvas,
        offsetFrom: Offset(graduationWidth, size.height),
        offsetTo: Offset(size.width, size.height - graduationHeight),
        fillColor: backgroundColor);

// bgColor pour les graduations verticales

    // graduations horizontales
    for (k in TwoPass.values) {
      for (DateTime d = from;
          d.millisecondsSinceEpoch < to.millisecondsSinceEpoch;
          d = d.add(const Duration(minutes: 1))) {
        double width =
            (d.millisecondsSinceEpoch - from.millisecondsSinceEpoch) /
                ratioTimestamp!;

        if (d.minute == 0) {
          // il est l'or
          final p1 = Offset(width + xOffset!, size.height);
          final p2 = Offset(p1.dx, size.height - graduationHeight);
          if (k == TwoPass.drawLines) {
            final paint = Paint()
              ..color = Colors.black
              ..strokeWidth = 2;
            canvas.drawLine(p1, p2, paint);
          }

          if (ratioTimestamp! < ratioHour) {
            drawHourTxt(
                canvas: canvas,
                size: size,
                offset: Offset(p1.dx - 15, size.height - 18),
                date: d,
                longTxt: true);
          } else {
            drawHourTxt(
                canvas: canvas,
                size: size,
                offset: Offset(p1.dx - 7, size.height - 18),
                date: d);
          }
        } else if (d.minute == 30) {
          if (ratioTimestamp! < ratio30min) {
            if (ratioTimestamp! < ratioTxt5min) {
              final p1 = Offset(width + xOffset!, size.height);
              final p2 = Offset(p1.dx, size.height - graduationHeight);
              if (k == TwoPass.drawLines) {
                final paint = Paint()
                  ..color = Colors.black
                  ..strokeWidth = 1;
                canvas.drawLine(p1, p2, paint);
              }
              drawMin30Txt(
                  canvas: canvas,
                  size: size,
                  offset: Offset(p1.dx - 13, size.height - 16),
                  date: d);
            } else {
              final p1 = Offset(width + xOffset!, size.height);
              final p2 = Offset(p1.dx, size.height - 20);
              if (k == TwoPass.drawLines) {
                final paint = Paint()
                  ..color = Colors.black
                  ..strokeWidth = 1;
                canvas.drawLine(p1, p2, paint);
              }
              drawMin30Txt(
                  canvas: canvas,
                  size: size,
                  offset: Offset(p1.dx - 13, size.height - 16),
                  date: d);
            }
          } else {
            final p1 = Offset(width + xOffset!, size.height);
            final p2 = Offset(p1.dx, size.height - 20);
            if (k == TwoPass.drawLines) {
              final paint = Paint()
                ..color = Colors.black
                ..strokeWidth = 1;
              canvas.drawLine(p1, p2, paint);
            }
          }
        } else if (d.minute == 15 || d.minute == 45) {
          if (ratioTimestamp! < ratio15min) {
            final p1 = Offset(width + xOffset!, size.height);
            final p2 = Offset(p1.dx, size.height - 20);
            final paint = Paint()
              ..color = Colors.black
              ..strokeWidth = 1;
            canvas.drawLine(p1, p2, paint);
            drawMinTxt(
                canvas: canvas,
                size: size,
                offset: Offset(p1.dx - 13, size.height - 16),
                date: d);
          } else {
            final p1 = Offset(width + xOffset!, size.height);
            final p2 = Offset(p1.dx, size.height - 15);
            if (k == TwoPass.drawLines) {
              final paint = Paint()
                ..color = Colors.grey
                ..strokeWidth = 1;
              canvas.drawLine(p1, p2, paint);
            }
          }
        } else if (d.minute % 5 == 0 && ratioTimestamp! < ratio5min) {
          if (ratioTimestamp! < ratioTxt5min) {
            final p1 = Offset(width + xOffset!, size.height);
            final p2 = Offset(p1.dx, size.height - 20);
            final paint = Paint()
              ..color = Colors.black
              ..strokeWidth = 1;
            canvas.drawLine(p1, p2, paint);
            drawMinTxt(
                canvas: canvas,
                size: size,
                offset: Offset(p1.dx - 13, size.height - 16),
                date: d);
          } else {
            final p1 = Offset(width + xOffset!, size.height);
            final p2 = Offset(p1.dx, size.height - 10);
            if (k == TwoPass.drawLines) {
              final paint = Paint()
                ..color = Colors.grey
                ..strokeWidth = 1;
              canvas.drawLine(p1, p2, paint);
            }
          }
        } else if (ratioTimestamp! < ratio1min) {
          final p1 = Offset(width + xOffset!, size.height);
          final p2 = Offset(p1.dx, size.height - 5);
          if (k == TwoPass.drawLines) {
            final paint = Paint()
              ..color = Colors.grey
              ..strokeWidth = 1;
            canvas.drawLine(p1, p2, paint);
          }
        }
      }
    }
    drawHorizonLegend(
        canvas: canvas,
        offset:
            Offset(graduationWidth + 30, size.height - graduationHeight - 5));
  }

  void verticalGraduations(Canvas canvas, Size size) {
    drawRect(
        canvas: canvas,
        offsetFrom: const Offset(0, 0),
        offsetTo: Offset(graduationWidth, size.height - graduationHeight),
        //filColor: Colors.blue
        fillColor: backgroundColor);

    //print("ratio=$ratioAltitude");

    for (k in TwoPass.values) {
      //min
      /*  Offset p1 = Offset(0, (_maxAlt - _minAlt) / ratioAltitude! - yOffset);
      Offset p2 = Offset(graduationWidth, p1.dy);

      if (k == TwoPass.drawLines) {
        Paint paint = Paint()
          ..color = Colors.black
          ..strokeWidth = 2;
        canvas.drawLine(p1, p2, paint);
      } else {
        drawAltitude1000Txt(
            canvas: canvas, altitude: _minAlt, offset: Offset(7, p1.dy - 7));
      }

      //Max
      p1 = const Offset(0, 2);
      p2 = Offset(graduationWidth, p1.dy);
      if (k == TwoPass.drawLines) {
        Paint paint = Paint()
          ..color = Colors.black
          ..strokeWidth = 2;
        canvas.drawLine(p1, p2, paint);
      } else {
        drawAltitude1000Txt(
            canvas: canvas, altitude: _maxAlt, offset: Offset(7, p1.dy - 1));
      }*/

      for (double altitude = _minAlt; altitude <= _maxAlt; altitude++) {
        if (altitude % 1000 == 0) {
          final p1 = Offset(
              graduationWidth / 2, (_maxAlt - altitude) / ratioAltitude!);
          final p2 = Offset(graduationWidth, p1.dy);
          if (k == TwoPass.drawLines) {
            final paint = Paint()
              ..color = Colors.black
              ..strokeWidth = 2;
            canvas.drawLine(p1, p2, paint);
          } else {
            drawAltitude1000Txt(
                canvas: canvas,
                altitude: altitude,
                offset: Offset(7, p1.dy - 7));
          }
        } else if (altitude % 500 == 0) {
          final p1 = Offset(
              graduationWidth / 2, (_maxAlt - altitude) / ratioAltitude!);
          final p2 = Offset(graduationWidth, p1.dy);
          if (k == TwoPass.drawLines) {
            final paint = Paint()
              ..color = Colors.black
              ..strokeWidth = 1;
            canvas.drawLine(p1, p2, paint);
          } else {
            drawAltitude500Txt(
                canvas: canvas,
                altitude: altitude,
                offset: Offset(9, p1.dy - 6));
          }
        } else if (altitude % 100 == 0) {
          final p1 = Offset(
              graduationWidth / 2, (_maxAlt - altitude) / ratioAltitude!);
          final p2 = Offset(graduationWidth, p1.dy);
          if (k == TwoPass.drawLines) {
            final paint = Paint()
              ..color = Colors.black
              ..strokeWidth = 1;
            canvas.drawLine(p1, p2, paint);
          } else if (ratioAltitude! < 6.5) {
            drawAltitude100Txt(
                canvas: canvas,
                altitude: altitude,
                offset: Offset(9, p1.dy - 6));
          }
        } else if (altitude % 50 == 0 && ratioAltitude! < 6.5) {
          final p1 = Offset(
              graduationWidth / 1.5, (_maxAlt - altitude) / ratioAltitude!);
          final p2 = Offset(graduationWidth, p1.dy);
          if (k == TwoPass.drawLines) {
            final paint = Paint()
              ..color = Colors.grey
              ..strokeWidth = 1;
            canvas.drawLine(p1, p2, paint);
          } /*else {
            drawAltitude100Txt(
                canvas: canvas,grey
                altitude: altitude,
                offset: Offset(9, p1.dy - 6));
          } */
        } else if (altitude % 10 == 0 && ratioAltitude! < 3) {
          final p1 = Offset(
              graduationWidth / 1.2, (_maxAlt - altitude) / ratioAltitude!);
          final p2 = Offset(graduationWidth, p1.dy);
          if (k == TwoPass.drawLines) {
            final paint = Paint()
              ..color = Colors.grey
              ..strokeWidth = 1;
            canvas.drawLine(p1, p2, paint);
          } /*else {
            drawAltitude100Txt(
                canvas: canvas,grey
                altitude: altitude,
                offset: Offset(9, p1.dy - 6));
          } */
        }
      }
    }
    drawVerticalLegend(canvas: canvas, offset: Offset(-3, size.height - 80));
  }

  void drawHorizonLegend(
      {required Canvas canvas, required Offset offset, bool longTxt = false}) {
    TextSpan span = TextSpan(
        style: GoogleFonts.robotoFlex(
          color: Colors.blue.withOpacity(0.8),
          fontWeight: FontWeight.normal,
          //backgroundColor: backgroundColor,
          fontSize: 14,
        ),
        text: "Heure UTC");
    TextPainter tp =
        TextPainter(text: span, textDirection: ui.TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, offset);
  }

  void drawVerticalLegend(
      {required Canvas canvas, required Offset offset, bool longTxt = false}) {
    canvas.save();
    //canvas.translate(0, 300);
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(-pi / 2);

    TextSpan span = TextSpan(
        style: GoogleFonts.robotoFlex(
          color: Colors.blue.withOpacity(0.8),
          fontWeight: FontWeight.normal,
          //backgroundColor: backgroundColor,
          fontSize: 14,
        ),
        text: "altitude en mètres");
    TextPainter tp =
        TextPainter(text: span, textDirection: ui.TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, const Offset(0, 0));

    canvas.restore();

    /* canvas.save();
    final pivot = fill.size.center(offset);
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(angle);
    canvas.translate(-pivot.dx, -pivot.dy);
    fill.paint(canvas, offset);
    canvas.restore(); */
  }

  void drawHourTxt(
      {required Canvas canvas,
      required Size size,
      required Offset offset,
      required DateTime date,
      bool longTxt = false}) {
    if (k == TwoPass.drawLines) return;

    late String timeTxt;
    longTxt
        ? timeTxt = DateFormat('HH:mm').format(date)
        : timeTxt = DateFormat('HH').format(date);
    TextSpan span = TextSpan(
        style: GoogleFonts.robotoFlex(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          backgroundColor: backgroundColor,
          fontSize: 12,
        ),
        text: timeTxt);
    TextPainter tp =
        TextPainter(text: span, textDirection: ui.TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, offset);
  }

  void drawAltitude1000Txt({
    required Canvas canvas,
    required Offset offset,
    required double altitude,
  }) {
    String sText = "${altitude.round()} ";
    if (sText.length == 3) {
      offset = Offset(offset.dx + 3, offset.dy);
    }

    TextSpan span = TextSpan(
        style: GoogleFonts.robotoFlex(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          backgroundColor: backgroundColor,
          fontSize: 12,
        ),
        text: sText);
    TextPainter tp =
        TextPainter(text: span, textDirection: ui.TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, offset);
  }

  void drawAltitude500Txt({
    required Canvas canvas,
    required Offset offset,
    required double altitude,
  }) {
    String sText = "${altitude.round()}";
    if (sText.length == 3) {
      offset = Offset(offset.dx + 3, offset.dy);
    }

    TextSpan span = TextSpan(
        style: GoogleFonts.robotoFlex(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          backgroundColor: backgroundColor,
          fontSize: 10,
        ),
        text: sText);
    TextPainter tp =
        TextPainter(text: span, textDirection: ui.TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, offset);
  }

  void drawAltitude100Txt({
    required Canvas canvas,
    required Offset offset,
    required double altitude,
  }) {
    String sText = "${altitude.round()}";
    if (sText.length == 3) {
      offset = Offset(offset.dx + 3, offset.dy);
    }

    TextSpan span = TextSpan(
        style: GoogleFonts.robotoFlex(
          color: Colors.black,
          fontWeight: FontWeight.normal,
          backgroundColor: backgroundColor,
          fontSize: 10,
        ),
        text: sText);
    TextPainter tp =
        TextPainter(text: span, textDirection: ui.TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, offset);
  }

  void drawMinTxt(
      {required Canvas canvas,
      required Size size,
      required Offset offset,
      required DateTime date}) {
    if (k == TwoPass.drawLines) return;
    TextSpan span = TextSpan(
        style: GoogleFonts.robotoFlex(
            color: Colors.black,
            backgroundColor: backgroundColor,
            fontSize: 10,
            letterSpacing: 0.2),
        text: DateFormat('HH:mm').format(date));
    TextPainter tp =
        TextPainter(text: span, textDirection: ui.TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, offset);
  }

  void drawMin30Txt(
      {required Canvas canvas,
      required Size size,
      required Offset offset,
      required DateTime date}) {
    if (k == TwoPass.drawLines) return;
    TextSpan span = TextSpan(
        style: GoogleFonts.robotoFlex(
            color: Colors.black,
            backgroundColor: backgroundColor,
            fontWeight: FontWeight.bold,
            fontSize: 10,
            letterSpacing: 0.2),
        text: DateFormat('HH:mm').format(date));
    TextPainter tp =
        TextPainter(text: span, textDirection: ui.TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, offset);
  }

  void drawRect(
      {required Canvas canvas,
      required Offset offsetFrom,
      required Offset offsetTo,
      required Color fillColor}) {
    var rectangle = Rect.fromPoints(offsetFrom, offsetTo);
    var paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(rectangle, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
// **********************************************

typedef OnWidgetSizeChange = void Function(Size size);

class MeasureSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  OnWidgetSizeChange onChange;

  MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    Size newSize = child!.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    Key? key,
    required this.onChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onChange);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant MeasureSizeRenderObject renderObject) {
    renderObject.onChange = onChange;
  }
}
