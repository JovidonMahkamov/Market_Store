import 'dart:ui';
import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        SizedBox(
          width: size.width,
          height: size.height,
          child: CustomPaint(painter: _BlobPainter()),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(
              color: const Color(0xFFF1F2F6).withOpacity(0.2),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _BlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFF1F2F6),
    );
    canvas.drawCircle(
      Offset(size.width * 0.90, size.height * 0.10),
      size.width * 0.65,
      Paint()
        ..shader = RadialGradient(
          colors: const [
            Color(0xFF5352ED),
            Color(0xFFB084F5),
            Color(0xFFFFB6C1),
            Colors.transparent,
          ],
          stops: const [0.02, 0.5, 0.8, 0.7],
        ).createShader(Rect.fromCircle(
          center: Offset(size.width * 0.90, size.height * 0.10),
          radius: size.width * 0.65,
        )),
    );
    canvas.drawCircle(
      Offset(size.width * 0.12, size.height * 0.90),
      size.width * 0.50,
      Paint()
        ..shader = RadialGradient(
          colors: const [
            Color(0xFF5352ED),
            Color(0xFFB084F5),
            Color(0xFFFFB6C1),
            Colors.transparent,
          ],
          stops: const [0.02, 0.5, 0.8, 1],
        ).createShader(Rect.fromCircle(
          center: Offset(size.width * 0.12, size.height * 0.90),
          radius: size.width * 0.40,
        )),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}