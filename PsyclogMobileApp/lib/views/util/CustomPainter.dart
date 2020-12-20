import 'package:flutter/material.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';

class NoteButtonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint_0 = new Paint()
      ..color = ViewConstants.myWhite
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;

    Path path_0 = Path();
    path_0.moveTo(size.width * -0.01, size.height * 0.99);
    path_0.lineTo(size.width * -0.01, size.height * -0.01);
    path_0.quadraticBezierTo(size.width * 0.48, size.height * -0.01, size.width * 0.49, size.height * 0.24);
    path_0.cubicTo(
        size.width * 0.49, size.height * 0.37, size.width * 0.49, size.height * 0.62, size.width * 0.49, size.height * 0.74);
    path_0.quadraticBezierTo(size.width * 0.48, size.height * 0.99, size.width * -0.01, size.height * 0.99);
    path_0.close();

    canvas.drawPath(path_0, paint_0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
