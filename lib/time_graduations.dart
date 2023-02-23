import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Graduations extends StatelessWidget {
  const Graduations(
      {super.key,
      required this.from,
      required this.to,
      this.currentTime,
      bool displayTime = false,
      this.backgroundColor = Colors.white});

  final DateTime from;
  final DateTime to;
  final DateTime? currentTime;
  final int minGraduationWidth = 10;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: CustomPaint(
        size: Size.infinite,
        painter: DrawPainterGraduation(
            from: from,
            to: to,
            currentTime: currentTime,
            backgroundColor: backgroundColor),
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
      required this.backgroundColor});

  //double pixWidth;
  DateTime from, to;
  double minWidthText = 20;
  DateTime? currentTime;
  late TwoPass k;
  Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    const ratioHour = 25000;
    const ratio30min = 25000;
    const ratio15min = 20000;
    const ratio5min = 80000;
    const ratio1min = 20000;
    const ratioTxt5min = 8000;

    double ratioTimestamp =
        (to.millisecondsSinceEpoch - from.millisecondsSinceEpoch) / size.width;

    //print("${ratioTimestamp}");
    for (k in TwoPass.values) {
      for (DateTime d = from;
          d.millisecondsSinceEpoch < to.millisecondsSinceEpoch;
          d = d.add(const Duration(minutes: 1))) {
        double width =
            (d.millisecondsSinceEpoch - from.millisecondsSinceEpoch) /
                ratioTimestamp;

        if (d.minute == 0) {
          // il est l'or
          final p1 = Offset(width, size.height);
          final p2 = Offset(p1.dx, size.height - 25);
          if (k == TwoPass.drawLines) {
            final paint = Paint()
              ..color = Colors.black
              ..strokeWidth = 2;
            canvas.drawLine(p1, p2, paint);
          }

          if (ratioTimestamp < ratioHour) {
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
          if (ratioTimestamp < ratio30min) {
            if (ratioTimestamp < ratioTxt5min) {
              final p1 = Offset(width, size.height);
              final p2 = Offset(p1.dx, size.height - 25);
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
              final p1 = Offset(width, size.height);
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
            final p1 = Offset(width, size.height);
            final p2 = Offset(p1.dx, size.height - 20);
            if (k == TwoPass.drawLines) {
              final paint = Paint()
                ..color = Colors.black
                ..strokeWidth = 1;
              canvas.drawLine(p1, p2, paint);
            }
          }
        } else if (d.minute == 15 || d.minute == 45) {
          if (ratioTimestamp < ratio15min) {
            final p1 = Offset(width, size.height);
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
            final p1 = Offset(width, size.height);
            final p2 = Offset(p1.dx, size.height - 15);
            if (k == TwoPass.drawLines) {
              final paint = Paint()
                ..color = Colors.grey
                ..strokeWidth = 1;
              canvas.drawLine(p1, p2, paint);
            }
          }
        } else if (d.minute % 5 == 0 && ratioTimestamp < ratio5min) {
          if (ratioTimestamp < ratioTxt5min) {
            final p1 = Offset(width, size.height);
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
            final p1 = Offset(width, size.height);
            final p2 = Offset(p1.dx, size.height - 10);
            if (k == TwoPass.drawLines) {
              final paint = Paint()
                ..color = Colors.grey
                ..strokeWidth = 1;
              canvas.drawLine(p1, p2, paint);
            }
          }
        } else if (ratioTimestamp < ratio1min) {
          final p1 = Offset(width, size.height);
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

    // on affiche le curseur
    if (currentTime != null) {
      final p1 = Offset(
          (currentTime!.millisecondsSinceEpoch - from.millisecondsSinceEpoch) /
              ratioTimestamp,
          size.height);
      final p2 = Offset(p1.dx, 0);
      final paint = Paint()
        ..color = Colors.red
        ..strokeWidth = 1;
      canvas.drawLine(p1, p2, paint);
    }
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
