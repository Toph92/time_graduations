import 'package:flutter/material.dart';

class ElevationPoint {
  ElevationPoint({required this.altitude, required this.timestamp, this.color});
  DateTime timestamp;
  int altitude;
  Color? color;
}

class GraphElevation extends StatelessWidget {
  const GraphElevation({
    super.key,
    required this.listTraces,
    this.backgroundColor = Colors.white,
    required this.from,
    required this.to,
    this.currentTime,
  });

  final List<List<ElevationPoint>> listTraces;
  final Color backgroundColor;
  final DateTime from;
  final DateTime to;
  final DateTime? currentTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: CustomPaint(
        size: Size.infinite,
        painter: DrawPainterElevation(
            from: from,
            to: to,
            currentTime: currentTime,
            backgroundColor: backgroundColor,
            listTraces: listTraces),
      ),
    );
  }
}

class DrawPainterElevation extends CustomPainter {
  DrawPainterElevation(
      {required this.from,
      required this.to,
      this.currentTime,
      required this.backgroundColor,
      required this.listTraces}) {
    // calcul de min et max pour l'altitude
    for (List<ElevationPoint> t in listTraces) {
      // surement moyen de faire cela avec reduce mais je maitrise moyennement et une passe je fais le min et le max et cela fonctionne pour toute  la liste
      // peut-etre plus rapide en faison 2 passes mais je n'ai pas testé
      for (ElevationPoint p in t) {
        if (p.altitude < _minAlt) {
          _minAlt = p.altitude;
        } else if (p.altitude > _maxAlt) {
          _maxAlt = p.altitude;
        }
      }
    }
  }
  int _minAlt = 100000;
  int _maxAlt = 0;

  //double pixWidth;
  DateTime from, to;
  double minWidthText = 20;
  DateTime? currentTime;
  Color backgroundColor;
  List<List<ElevationPoint>> listTraces;

  @override
  void paint(Canvas canvas, Size size) {
    double ratioTimestamp =
        (to.millisecondsSinceEpoch - from.millisecondsSinceEpoch) / size.width;

    double ratioAltitude = (_maxAlt - _minAlt) / size.height;

    /*for (DateTime d = from;
        d.millisecondsSinceEpoch < to.millisecondsSinceEpoch;
        d = d.add(const Duration(minutes: 1))) {
      double width = (d.millisecondsSinceEpoch - from.millisecondsSinceEpoch) /
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
    }*/

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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
