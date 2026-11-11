// Custom Vector WhatsApp Brand Emblem Widget (Speech Bubble + Handset)
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Crisp custom-painted vector WhatsApp logo with speech-bubble tail,
/// specular gloss, and curved phone handset.
class WhatsAppBrandLogo extends StatelessWidget {
  final double size;

  /// Set true when rendered on top of a bright green surface (e.g. FAB or
  /// green primary button) so the bubble rings and handset stay crisp white.
  final bool inverted;

  const WhatsAppBrandLogo({
    super.key,
    this.size = 20,
    this.inverted = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _WhatsAppBrandLogoPainter(inverted: inverted),
      ),
    );
  }
}

class _WhatsAppBrandLogoPainter extends CustomPainter {
  final bool inverted;

  const _WhatsAppBrandLogoPainter({required this.inverted});

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height) / 24.0;
    final cx = 12.6 * s;
    final cy = 11.3 * s;
    final r = 9.5 * s;

    // 148 deg to 116 deg clockwise sweep (328 deg) leaves bottom-left gap for tail
    const startAngle = 148.0 * math.pi / 180.0;
    const sweepAngle = 328.0 * math.pi / 180.0;

    final startPt = Offset(
      cx + r * math.cos(startAngle),
      cy + r * math.sin(startAngle),
    );

    final bubblePath = Path()
      ..moveTo(startPt.dx, startPt.dy)
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        startAngle,
        sweepAngle,
        false,
      )
      ..lineTo(3.0 * s, 21.1 * s)
      ..quadraticBezierTo(1.85 * s, 21.45 * s, 2.25 * s, 20.3 * s)
      ..lineTo(startPt.dx, startPt.dy)
      ..close();

    if (inverted) {
      // Crisp white bubble fill/ring over vibrant green button background
      canvas.drawPath(
        bubblePath,
        Paint()..color = const Color(0xFF15803D).withValues(alpha: 0.25),
      );
      canvas.drawPath(
        bubblePath,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.1 * s
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );
    } else {
      // Soft ambient glow shadow
      canvas.drawPath(
        bubblePath.shift(Offset(0, 0.8 * s)),
        Paint()
          ..color = const Color(0xFF16A34A).withValues(alpha: 0.26)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.4 * s),
      );

      // Rich WhatsApp emerald gradient badge fill
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            Color(0xFF4ADE80),
            Color(0xFF25D366),
            Color(0xFF128C7E),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawPath(bubblePath, fillPaint);

      // Top-left gloss crescent highlight
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.84),
        -2.35,
        1.4,
        false,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.34)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3 * s
          ..strokeCap = StrokeCap.round,
      );

      // Crisp white rim
      canvas.drawPath(
        bubblePath,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.94)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.45 * s
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // Telephone handset rotated +45 deg (top-left earpiece -> bottom-right mouthpiece)
    canvas.save();
    canvas.translate(cx + 0.55 * s, cy + 0.05 * s);
    canvas.rotate(math.pi / 4.0);

    final phonePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Curved handle spine
    final handlePath = Path()
      ..moveTo(-4.1 * s, -0.5 * s)
      ..quadraticBezierTo(0, 2.55 * s, 4.1 * s, -0.5 * s);
    canvas.drawPath(handlePath, phonePaint..strokeWidth = 2.0 * s);

    // Earpiece & mouthpiece flared lugs
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(-3.55 * s, -1.25 * s), width: 2.3 * s, height: 2.7 * s),
        Radius.circular(1.0 * s),
      ),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(3.55 * s, -1.25 * s), width: 2.3 * s, height: 2.7 * s),
        Radius.circular(1.0 * s),
      ),
      Paint()..color = Colors.white,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WhatsAppBrandLogoPainter oldDelegate) =>
      oldDelegate.inverted != inverted;
}
