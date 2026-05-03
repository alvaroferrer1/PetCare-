import 'package:flutter/material.dart';

class PetCareLogo extends StatelessWidget {
  const PetCareLogo({this.size = 92, this.fromAsset = true, super.key});

  final double size;
  final bool fromAsset;

  @override
  Widget build(BuildContext context) {
    if (fromAsset) {
      return Image.asset(
        'assets/branding/petcare_logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => CustomPaint(
          size: Size.square(size),
          painter: _PetCareLogoPainter(),
        ),
      );
    }
    return CustomPaint(size: Size.square(size), painter: _PetCareLogoPainter());
  }
}

class _PetCareLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFB7E4C7);
    final primary = Paint()..color = const Color(0xFF2D6A4F);
    final accent = Paint()..color = const Color(0xFFE76F51);
    final white = Paint()..color = Colors.white;

    final r = size.width / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(size.width * 0.28),
      ),
      bg,
    );

    final heart = Path()
      ..moveTo(r, size.height * 0.72)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.52,
        size.width * 0.26,
        size.height * 0.28,
        r,
        size.height * 0.38,
      )
      ..cubicTo(
        size.width * 0.74,
        size.height * 0.28,
        size.width * 0.78,
        size.height * 0.52,
        r,
        size.height * 0.72,
      );
    canvas.drawPath(heart, accent);

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      r * 0.26,
      white,
    );
    canvas.drawCircle(
      Offset(size.width * 0.34, size.height * 0.34),
      r * 0.10,
      primary,
    );
    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.28),
      r * 0.11,
      primary,
    );
    canvas.drawCircle(
      Offset(size.width * 0.66, size.height * 0.34),
      r * 0.10,
      primary,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.53),
        width: size.width * 0.34,
        height: size.height * 0.24,
      ),
      primary,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
