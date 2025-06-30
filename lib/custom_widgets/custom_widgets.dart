import 'dart:math';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

//Iconbutton custom widgets
class CustomWidgets extends StatelessWidget {
  final String imagePath;
  final double imageWidth;
  final double imageHeight;
  final Color containerColor;
  final Color progressColor;
  final Color backgroundColor;
  final String text;
  final BoxShape boxShape;
  final double height;
  final double width;
  final Alignment alignment;

  const CustomWidgets(
      {super.key,
      required this.imagePath,
      required this.containerColor,
      this.text = '',
      required this.boxShape,
      this.imageWidth = 0.0,
      this.imageHeight = 0.0,
      this.height = 0.0,
      this.width = 0.0,
      this.alignment = Alignment.center,
      this.progressColor = Colors.blue,
      this.backgroundColor = Colors.red});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            //fit: BoxFit.contain,
            height: imageHeight,
            width: imageWidth,
            imagePath,
            alignment: alignment,
          ),
          if (text.isNotEmpty) ...[
            SizedBox(
              height: 2,
            ),
            Text(
              text,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              height: 3,
            ),
            //linear progress indicator
            LinearPercentIndicator(
              percent: 0.5, // static value
              width: 55,
              backgroundColor: backgroundColor,
              progressColor: progressColor,
              lineHeight: 6,
              barRadius: Radius.circular(3),
            )
          ]
        ],
      ),
    );
  }
}

//Containers custom widget...........
class CustomContainer extends StatelessWidget {
  const CustomContainer(
      {super.key,
      required this.containerColor,
      this.width,
      required this.height,
      this.child});

  final Color containerColor;
  final double? width;
  final double height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: containerColor,
      ),
      child: child,
    );
  }
}

//Progress Indicator Class
class DailyIntakeIndicator extends StatelessWidget {
  final double percentage; // between 0.0 to 1.0

  const DailyIntakeIndicator({super.key, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 0, top: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Custom half-arc painter
                CustomPaint(
                  size: const Size(80, 50), // width x height for half-circle
                  painter: HalfArcPainter(percentage),
                ),
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(1.0),
                        blurRadius: 4,
                        spreadRadius: 2,
                        offset: const Offset(0, 0),
                      )
                    ],
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                Text("${(percentage * 100).toInt()}%",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    )),
              ],
            ),
            SizedBox(
              height: 0,
            ),
            Text('Daily Intake',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ))
          ],
        ),
      ),
    );
  }
}

class HalfArcPainter extends CustomPainter {
  final double percentage;

  HalfArcPainter(this.percentage);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundArc = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint blueOutlineArc = Paint()
      ..color = Colors.blue
      ..strokeWidth = 11.2 // slightly larger than progress arc
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint progressArc = Paint()
      ..color = const Color.fromARGB(255, 53, 238, 59)
      //const Color.fromARGB(255, 144, 255, 18),
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Rect arcRect = Rect.fromLTWH(0, -10, size.width, size.height * 2.2);

    final double startAngle = pi;
    final double sweepAngle = pi;
    // Full half-arc (180 degrees)
    canvas.drawArc(arcRect, startAngle, startAngle, false, backgroundArc);

    // Draw blue outline arc (behind progress arc)
    canvas.drawArc(
        arcRect, startAngle, sweepAngle * percentage, false, blueOutlineArc);
    // Green progress (based on percentage)
    canvas.drawArc(
        arcRect, startAngle, sweepAngle * percentage, false, progressArc);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
