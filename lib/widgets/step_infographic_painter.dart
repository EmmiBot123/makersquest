// High-Fidelity STEM Technical Step Infographic Painter
import 'dart:math' as math;
import 'package:flutter/material.dart';

enum InfographicMode {
  blueprint, // Technical CAD drafting with dimensions & grid (Dark Navy)
  assembly,  // Full-color tactile realistic materials (Light Studio)
  physics,   // Vector force, motion & stress overlays (Deep Violet)
}

class StepInfographicPainter extends CustomPainter {
  final String visualType;
  final InfographicMode mode;
  final int stageIndex; // 0: Stage 1, 1: Stage 2, 2: Stage 3
  final String? highlightedPart;
  final double animationProgress; // 0.0 to 1.0

  StepInfographicPainter({
    required this.visualType,
    required this.mode,
    required this.stageIndex,
    this.highlightedPart,
    this.animationProgress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    // 1. Draw Environment Canvas Background based on Mode
    _drawModeEnvironment(canvas, size);

    // 2. Dispatch to specific visual drawing
    switch (visualType) {
      // 🏎️ Wheeled Test Cart & Bearing Mechanics
      case 'straw_bearings':
        _drawStrawBearingsDiagram(canvas, size);
        break;
      case 'wheel_cutting':
        _drawWheelCuttingDiagram(canvas, size);
        break;
      case 'wheel_assembly':
        _drawWheelAssemblyDiagram(canvas, size);
        break;
      case 'cart_rollout':
        _drawCartRolloutDiagram(canvas, size);
        break;

      // 🚀 Rubber-Band Wind-Up Drive Racer (Ch. 4)
      case 'axle_notch':
        _drawAxleNotchDiagram(canvas, size);
        break;
      case 'chassis_window':
        _drawChassisWindowDiagram(canvas, size);
        break;
      case 'traction_tires':
        _drawTractionTiresDiagram(canvas, size);
        break;
      case 'rubber_launch':
        _drawRubberLaunchDiagram(canvas, size);
        break;

      // ✂️ Scissor Lift & Pantograph Linkages
      case 'struts_cutting':
        _drawStrutsCuttingDiagram(canvas, size);
        break;
      case 'hole_marking':
        _drawHoleMarkingDiagram(canvas, size);
        break;
      case 'x_assembly':
        _drawXAssemblyDiagram(canvas, size);
        break;
      case 'lift_complete':
        _drawLiftCompleteDiagram(canvas, size);
        break;

      // 🎢 Marble Coaster & Gravity Tracks
      case 'tube_cutting':
        _drawTubeCuttingDiagram(canvas, size);
        break;
      case 'angle_testing':
        _drawAngleTestingDiagram(canvas, size);
        break;
      case 'banked_turns':
        _drawBankedTurnsDiagram(canvas, size);
        break;
      case 'marble_finish':
        _drawMarbleFinishDiagram(canvas, size);
        break;

      // 🏗️ Pulley Crane & Heavy Lifter
      case 'pulley_wheel':
      case 'compound_rigging':
        _drawPulleyWheelDiagram(canvas, size);
        break;
      case 'a_frame':
      case 'truss_tower':
        _drawAFrameDiagram(canvas, size);
        break;
      case 'cable_rigging':
      case 'crane_complete':
      case 'lifter_test':
        _drawCraneCompleteDiagram(canvas, size);
        break;

      // 💡 Paper Circuits & Electronics
      case 'schematic_trace':
      case 'tape_laying':
        _drawCircuitTraceDiagram(canvas, size);
        break;
      case 'led_mounting':
      case 'circuit_card_finish':
        _drawLedMountingDiagram(canvas, size);
        break;

      // Default STEM Blueprint
      default:
        _drawGenericStemBlueprint(canvas, size);
        break;
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // STRIKING MODE ENVIRONMENTS (Deep CAD vs Light Studio vs Neon Physics)
  // ══════════════════════════════════════════════════════════════════
  void _drawModeEnvironment(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    Color bgColor;
    Color gridColor;
    Color borderColor;

    switch (mode) {
      case InfographicMode.blueprint:
        // Deep Dark Navy Professional CAD Drafting Screen
        bgColor = const Color(0xFF0B192C);
        gridColor = const Color(0xFF1E3E62).withValues(alpha: 0.45);
        borderColor = const Color(0xFF00ADB5).withValues(alpha: 0.5);
        break;
      case InfographicMode.assembly:
        // Warm Woodshop / Crafting Studio Table
        bgColor = const Color(0xFFFAFAF9);
        gridColor = const Color(0xFFE7E5E4).withValues(alpha: 0.7);
        borderColor = const Color(0xFFD6D3D1);
        break;
      case InfographicMode.physics:
        // High-Tech Laboratory Force Field Screen
        bgColor = const Color(0xFF18122B);
        gridColor = const Color(0xFF393053).withValues(alpha: 0.5);
        borderColor = const Color(0xFF6366F1).withValues(alpha: 0.6);
        break;
    }

    // Fill background
    final bgPaint = Paint()..color = bgColor;
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)), bgPaint);

    // Draw grid
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = mode == InfographicMode.blueprint ? 1.0 : 0.8;

    const spacing = 22.0;
    for (double x = 0; x <= w; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y <= h; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)), borderPaint);

    // Mode watermark badge in bottom right corner
    final watermarkText = mode == InfographicMode.blueprint
        ? '📐 CAD DRAFTING VIEW • ISO 9001 METRIC'
        : mode == InfographicMode.assembly
            ? '🎨 3D TACTILE ASSEMBLY VIEW'
            : '⚡ FREE-BODY FORCE & VECTOR OVERLAY';
    final watermarkColor = mode == InfographicMode.blueprint
        ? const Color(0xFF00ADB5).withValues(alpha: 0.4)
        : mode == InfographicMode.assembly
            ? const Color(0xFF78716C).withValues(alpha: 0.5)
            : const Color(0xFF818CF8).withValues(alpha: 0.5);

    final tp = TextPainter(
      text: TextSpan(
        text: watermarkText,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: watermarkColor, letterSpacing: 0.8),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(w - tp.width - 12, h - tp.height - 8));
  }

  // ══════════════════════════════════════════════════════════════════
  // CALLOUT BUBBLES & TECHNICAL ANNOTATIONS
  // ══════════════════════════════════════════════════════════════════
  void _drawCalloutBubble(Canvas canvas, Offset target, Offset bubbleCenter, String text, String icon, Color color) {
    final isDark = mode == InfographicMode.blueprint || mode == InfographicMode.physics;

    // Leader line with target dot
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    canvas.drawLine(target, bubbleCenter, linePaint);
    canvas.drawCircle(target, 3.5, Paint()..color = color);

    final textSpan = TextSpan(
      children: [
        TextSpan(text: '$icon ', style: const TextStyle(fontSize: 11)),
        TextSpan(
          text: text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();

    final bubbleRect = Rect.fromCenter(
      center: bubbleCenter,
      width: tp.width + 16,
      height: tp.height + 10,
    );

    // Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(bubbleRect.translate(0, 2), const Radius.circular(8)),
      Paint()..color = Colors.black.withValues(alpha: 0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Background fill
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(bubbleRect, const Radius.circular(8)), bgPaint);

    // Border
    final borderPaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(RRect.fromRectAndRadius(bubbleRect, const Radius.circular(8)), borderPaint);

    tp.paint(canvas, Offset(bubbleCenter.dx - tp.width / 2, bubbleCenter.dy - tp.height / 2));
  }

  void _drawDimensionLine(Canvas canvas, Offset p1, Offset p2, String label, {bool isVertical = false}) {
    final isDark = mode == InfographicMode.blueprint || mode == InfographicMode.physics;
    final dimColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);

    final dimPaint = Paint()
      ..color = dimColor
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    canvas.drawLine(p1, p2, dimPaint);

    const tickLen = 5.0;
    if (isVertical) {
      canvas.drawLine(Offset(p1.dx - tickLen, p1.dy), Offset(p1.dx + tickLen, p1.dy), dimPaint);
      canvas.drawLine(Offset(p2.dx - tickLen, p2.dy), Offset(p2.dx + tickLen, p2.dy), dimPaint);
    } else {
      canvas.drawLine(Offset(p1.dx, p1.dy - tickLen), Offset(p1.dx, p1.dy + tickLen), dimPaint);
      canvas.drawLine(Offset(p2.dx, p2.dy - tickLen), Offset(p2.dx, p2.dy + tickLen), dimPaint);
    }

    final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
    final textSpan = TextSpan(
      text: label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: dimColor,
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      ),
    );
    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(mid.dx - tp.width / 2, mid.dy - (isVertical ? tp.height / 2 : 12)));
  }

  void _drawForceVector(Canvas canvas, Offset start, Offset end, Color color, String label) {
    final arrowPaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, arrowPaint);

    final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
    final arrowPath = Path();
    arrowPath.moveTo(end.dx, end.dy);
    arrowPath.lineTo(end.dx - 9 * math.cos(angle - math.pi / 6), end.dy - 9 * math.sin(angle - math.pi / 6));
    arrowPath.lineTo(end.dx - 9 * math.cos(angle + math.pi / 6), end.dy - 9 * math.sin(angle + math.pi / 6));
    arrowPath.close();

    canvas.drawPath(arrowPath, Paint()..color = color..style = PaintingStyle.fill);

    final textSpan = TextSpan(
      text: label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: color,
        backgroundColor: Colors.black.withValues(alpha: 0.7),
      ),
    );
    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: end + const Offset(0, -12), width: tp.width + 8, height: tp.height + 4),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.6),
    );
    tp.paint(canvas, end + Offset(-tp.width / 2, -18));
  }

  // ══════════════════════════════════════════════════════════════════
  // AUTHENTIC MAKER TOOLS & HARDWARE DRAWING HELPERS
  // ══════════════════════════════════════════════════════════════════
  void _drawRealisticRuler(Canvas canvas, Rect rect, double cmLength, {bool horizontal = true}) {
    final isDark = mode == InfographicMode.blueprint || mode == InfographicMode.physics;
    final rulerColor = isDark ? const Color(0xFF1E3A5F) : const Color(0xFFFDE047);
    final borderColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFFCA8A04);

    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), Paint()..color = rulerColor);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), Paint()..color = borderColor..strokeWidth = 1.2..style = PaintingStyle.stroke);

    final tickPaint = Paint()..color = isDark ? Colors.white70 : const Color(0xFF713F12)..strokeWidth = 1.0;
    final textStyle = TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF713F12));

    final steps = (cmLength * 2).toInt(); // half-cm ticks
    for (int i = 0; i <= steps; i++) {
      final frac = i / steps;
      final isMajor = i % 2 == 0;
      final cmVal = (i / 2).toInt();

      if (horizontal) {
        final x = rect.left + (rect.width * frac);
        final tickH = isMajor ? 8.0 : 4.0;
        canvas.drawLine(Offset(x, rect.top), Offset(x, rect.top + tickH), tickPaint);
        if (isMajor && (cmVal % 3 == 0 || cmVal == cmLength.toInt())) {
          final tp = TextPainter(text: TextSpan(text: '$cmVal', style: textStyle), textDirection: TextDirection.ltr)..layout();
          tp.paint(canvas, Offset(x - tp.width / 2, rect.top + 9));
        }
      } else {
        final y = rect.top + (rect.height * frac);
        final tickW = isMajor ? 8.0 : 4.0;
        canvas.drawLine(Offset(rect.left, y), Offset(rect.left + tickW, y), tickPaint);
      }
    }
  }

  void _drawRealisticScissors(Canvas canvas, Offset pivot, double openAngle, {double scale = 1.0}) {
    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    canvas.scale(scale);

    final bladePaint = Paint()..color = const Color(0xFFCBD5E1)..strokeWidth = 3.5..strokeCap = StrokeCap.round;
    final edgePaint = Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 1.5;

    // Upper blade
    canvas.save();
    canvas.rotate(-openAngle);
    canvas.drawLine(Offset.zero, const Offset(28, -6), bladePaint);
    canvas.drawLine(Offset.zero, const Offset(28, -6), edgePaint);
    canvas.drawCircle(const Offset(-16, 8), 9, Paint()..color = const Color(0xFFEF4444)..style = PaintingStyle.stroke..strokeWidth = 3.5);
    canvas.restore();

    // Lower blade
    canvas.save();
    canvas.rotate(openAngle);
    canvas.drawLine(Offset.zero, const Offset(28, 6), bladePaint);
    canvas.drawLine(Offset.zero, const Offset(28, 6), edgePaint);
    canvas.drawCircle(const Offset(-16, -8), 9, Paint()..color = const Color(0xFFEF4444)..style = PaintingStyle.stroke..strokeWidth = 3.5);
    canvas.restore();

    // Pivot rivet
    canvas.drawCircle(Offset.zero, 3.5, Paint()..color = const Color(0xFFF59E0B));
    canvas.drawCircle(Offset.zero, 3.5, Paint()..color = const Color(0xFFB45309)..style = PaintingStyle.stroke..strokeWidth = 1.0);

    canvas.restore();
  }

  void _drawRealisticPencil(Canvas canvas, Offset tip, double angle) {
    canvas.save();
    canvas.translate(tip.dx, tip.dy);
    canvas.rotate(angle);

    // Graphite tip
    final leadPath = Path()..moveTo(0, 0)..lineTo(6, -3)..lineTo(6, 3)..close();
    canvas.drawPath(leadPath, Paint()..color = const Color(0xFF1E293B));

    // Sharpened wood cone
    final woodPath = Path()..moveTo(6, -3)..lineTo(14, -6)..lineTo(14, 6)..lineTo(6, 3)..close();
    canvas.drawPath(woodPath, Paint()..color = const Color(0xFFFED7AA));

    // Yellow pencil body
    final body = Rect.fromLTWH(14, -6, 38, 12);
    canvas.drawRect(body, Paint()..color = const Color(0xFFFACC15));
    canvas.drawRect(body, Paint()..color = const Color(0xFFCA8A04)..style = PaintingStyle.stroke..strokeWidth = 1.0);

    // Brass ferrule & eraser
    canvas.drawRect(const Rect.fromLTWH(52, -6, 7, 12), Paint()..color = const Color(0xFFCBD5E1));
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(59, -6, 9, 12), const Radius.circular(3)), Paint()..color = const Color(0xFFF472B6));

    canvas.restore();
  }

  void _drawCardboardTexture(Canvas canvas, Rect rect, {bool horizontal = true}) {
    final isDark = mode == InfographicMode.blueprint || mode == InfographicMode.physics;
    final baseColor = isDark ? const Color(0xFF1E3A5F) : const Color(0xFFFDE68A);
    final borderColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFFB45309);
    final fluteColor = isDark ? const Color(0xFF0284C7).withValues(alpha: 0.3) : const Color(0xFFD97706).withValues(alpha: 0.25);

    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(5)), Paint()..color = baseColor);

    final flutePaint = Paint()..color = fluteColor..strokeWidth = 1.2;
    if (horizontal) {
      for (double y = rect.top + 6; y < rect.bottom - 4; y += 8) {
        canvas.drawLine(Offset(rect.left + 4, y), Offset(rect.right - 4, y), flutePaint);
      }
    } else {
      for (double x = rect.left + 6; x < rect.right - 4; x += 8) {
        canvas.drawLine(Offset(x, rect.top + 4), Offset(x, rect.bottom - 4), flutePaint);
      }
    }

    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(5)), Paint()..color = borderColor..strokeWidth = 1.5..style = PaintingStyle.stroke);
  }

  void _drawBrassFastener(Canvas canvas, Offset center, {bool rearWings = false}) {
    if (!rearWings) {
      canvas.drawCircle(center, 7, Paint()..color = const Color(0xFFF59E0B));
      canvas.drawCircle(center, 7, Paint()..color = const Color(0xFFB45309)..style = PaintingStyle.stroke..strokeWidth = 1.5);
      canvas.drawCircle(center + const Offset(-2, -2), 2.5, Paint()..color = Colors.white.withValues(alpha: 0.7));
    } else {
      final legPaint = Paint()..color = const Color(0xFFF59E0B)..strokeWidth = 4.0..strokeCap = StrokeCap.round;
      canvas.drawLine(center, center + const Offset(-18, 0), legPaint);
      canvas.drawLine(center, center + const Offset(18, 0), legPaint);
      canvas.drawCircle(center, 4, Paint()..color = const Color(0xFFD97706));
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // DIAGRAM 1: SCISSOR LIFT STRUTS CUTTING (Step 1)
  // EXACT SPEC: 6 Identical Struts, 15 cm Long × 2 cm Wide
  // Flutes parallel to length (0°). NO HOLES IN STEP 1!
  // ══════════════════════════════════════════════════════════════════
  void _drawStrutsCuttingDiagram(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    if (stageIndex == 0) {
      // ══════════════════════════════════════════════════════════════
      // STAGE 1: Measure 15 cm Long × 2 cm Wide on Cardboard Sheet
      // ══════════════════════════════════════════════════════════════
      final sheetRect = Rect.fromCenter(center: Offset(cx, cy), width: 280, height: 130);
      _drawCardboardTexture(canvas, sheetRect, horizontal: true);

      // Active 15 cm x 2 cm single strip outline
      final stripRect = Rect.fromCenter(center: Offset(cx, cy - 18), width: 200, height: 26);
      canvas.drawRect(stripRect, Paint()..color = const Color(0xFF0284C7).withValues(alpha: 0.15));
      canvas.drawRect(stripRect, Paint()..color = const Color(0xFF0284C7)..strokeWidth = 1.8..style = PaintingStyle.stroke);

      // Ruler placed along the top edge of the 15cm strip
      final rulerRect = Rect.fromLTWH(stripRect.left, stripRect.top - 24, stripRect.width, 18);
      _drawRealisticRuler(canvas, rulerRect, 15.0);

      // Pencil marking the 15cm end
      final pencilTip = Offset(stripRect.right, stripRect.bottom);
      _drawRealisticPencil(canvas, pencilTip, -0.6);

      // Precision Dimensions
      _drawDimensionLine(canvas, Offset(stripRect.left, stripRect.bottom + 14), Offset(stripRect.right, stripRect.bottom + 14), 'Length: 15.0 cm');
      _drawDimensionLine(canvas, Offset(stripRect.left - 12, stripRect.top), Offset(stripRect.left - 12, stripRect.bottom), '2.0 cm', isVertical: true);

      _drawCalloutBubble(canvas, Offset(cx - 30, cy + 25), Offset(cx - 30, cy + 55), 'Flutes Run Lengthwise (0°)', '📐', const Color(0xFF0284C7));
      _drawCalloutBubble(canvas, pencilTip, Offset(pencilTip.dx + 25, pencilTip.dy - 35), 'Mark 15.0 cm Line', '✏️', const Color(0xFFF59E0B));

    } else if (stageIndex == 1) {
      // ══════════════════════════════════════════════════════════════
      // STAGE 2: Slice Strip Along Marked Dotted Line with Scissors
      // ══════════════════════════════════════════════════════════════
      final sheetRect = Rect.fromCenter(center: Offset(cx, cy), width: 280, height: 130);
      _drawCardboardTexture(canvas, sheetRect, horizontal: true);

      final stripRect = Rect.fromCenter(center: Offset(cx, cy - 18), width: 200, height: 26);

      // Dotted cut line
      final cutProgress = animationProgress;
      final currentCutX = stripRect.left + (stripRect.width * cutProgress);

      final cutLinePaint = Paint()..color = const Color(0xFFEF4444)..strokeWidth = 2.0..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(stripRect.left, stripRect.bottom), Offset(currentCutX, stripRect.bottom), cutLinePaint);
      final dotPaint = Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 1.5;
      for (double x = currentCutX; x < stripRect.right; x += 8) {
        canvas.drawCircle(Offset(x, stripRect.bottom), 1.5, dotPaint);
      }

      // Animated Craft Scissors cutting along the line
      final scissorAngle = math.sin(animationProgress * math.pi * 6).abs() * 0.35 + 0.1;
      _drawRealisticScissors(canvas, Offset(currentCutX, stripRect.bottom), scissorAngle, scale: 0.9);

      _drawDimensionLine(canvas, Offset(stripRect.left, stripRect.top - 12), Offset(stripRect.right, stripRect.top - 12), '15.0 cm Strip');
      _drawCalloutBubble(canvas, Offset(currentCutX, stripRect.bottom), Offset(currentCutX - 35, stripRect.bottom - 45), 'Cut Cleanly Along Line', '✂️', const Color(0xFFEF4444));

    } else {
      // ══════════════════════════════════════════════════════════════
      // STAGE 3: Stack of 6 Identical Cut Struts (15 cm × 2 cm)
      // ══════════════════════════════════════════════════════════════
      for (int i = 5; i >= 0; i--) {
        final offset = i * 6.0;
        final sRect = Rect.fromCenter(center: Offset(cx + (offset * 1.5) - 20, cy + (offset * 1.8) - 25), width: 200, height: 24);
        _drawCardboardTexture(canvas, sRect, horizontal: true);
      }

      _drawDimensionLine(canvas, Offset(cx - 120, cy + 35), Offset(cx + 80, cy + 35), '15.0 cm Length');
      _drawCalloutBubble(canvas, Offset(cx - 20, cy - 25), Offset(cx - 20, cy - 65), '6 Identical Struts Ready', '✅', const Color(0xFF059669));
      _drawCalloutBubble(canvas, Offset(cx + 40, cy + 10), Offset(cx + 70, cy + 60), '100% Matching 15×2 cm', '📏', const Color(0xFF0284C7));
    }

    if (mode == InfographicMode.physics) {
      _drawForceVector(canvas, Offset(cx - 70, cy + 60), Offset(cx - 20, cy + 60), const Color(0xFF22C55E), 'Flutes 0° = High Bending Rigidity');
      _drawForceVector(canvas, Offset(cx, cy - 30), Offset(cx, cy - 65), const Color(0xFF6366F1), 'Zero Grain Buckling');
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // DIAGRAM 6: MARK & PUNCH PRECISION PIVOT HOLES (Scissor Lift Step 2)
  // EXACT SPEC: Holes at 1.5 cm from left, 7.5 cm (center), 13.5 cm (1.5 cm from right)
  // Pitch = 6.0 cm hole-to-hole! Hole Ø = 3.0 mm.
  // ══════════════════════════════════════════════════════════════════
  void _drawHoleMarkingDiagram(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final isDark = mode == InfographicMode.blueprint || mode == InfographicMode.physics;

    final strutRect = Rect.fromCenter(center: Offset(cx, cy), width: 220, height: 28);
    _drawCardboardTexture(canvas, strutRect, horizontal: true);

    // Exact Coordinates (15cm scaled to 220px):
    // 1.5 cm from left = 22.0px from strut left
    // 7.5 cm center = cx
    // 1.5 cm from right = 22.0px from strut right
    final leftHole = Offset(strutRect.left + 22.0, cy);
    final midHole = Offset(cx, cy);
    final rightHole = Offset(strutRect.right - 22.0, cy);

    if (stageIndex == 0) {
      // Stage 1: Measure 3 hole positions with ruler
      final rulerRect = Rect.fromLTWH(strutRect.left, strutRect.top - 24, strutRect.width, 18);
      _drawRealisticRuler(canvas, rulerRect, 15.0);

      // Centerline
      canvas.drawLine(Offset(strutRect.left + 4, cy), Offset(strutRect.right - 4, cy), Paint()..color = const Color(0xFF0284C7)..strokeWidth = 1.0);

      // Tick marks at 1.5cm, 7.5cm, 13.5cm
      final pTick = Paint()..color = const Color(0xFFDC2626)..strokeWidth = 2.0;
      for (final h in [leftHole, midHole, rightHole]) {
        canvas.drawLine(Offset(h.dx, cy - 8), Offset(h.dx, cy + 8), pTick);
      }

      _drawDimensionLine(canvas, Offset(strutRect.left, cy + 24), Offset(leftHole.dx, cy + 24), '1.5cm');
      _drawDimensionLine(canvas, Offset(leftHole.dx, cy + 24), Offset(midHole.dx, cy + 24), '6.0 cm Pitch');
      _drawDimensionLine(canvas, Offset(midHole.dx, cy + 24), Offset(rightHole.dx, cy + 24), '6.0 cm Pitch');
      _drawDimensionLine(canvas, Offset(rightHole.dx, cy + 24), Offset(strutRect.right, cy + 24), '1.5cm');

      _drawCalloutBubble(canvas, midHole, Offset(cx, cy - 55), 'Center Hole at 7.5 cm', '🎯', const Color(0xFFDC2626));

    } else if (stageIndex == 1) {
      // Stage 2: Concentric Crosshairs with Targeting Pushpin / Pencil
      final crossP = Paint()..color = const Color(0xFFDC2626)..strokeWidth = 1.5;
      for (final h in [leftHole, midHole, rightHole]) {
        canvas.drawLine(Offset(h.dx - 10, h.dy), Offset(h.dx + 10, h.dy), crossP);
        canvas.drawLine(Offset(h.dx, h.dy - 10), Offset(h.dx, h.dy + 10), crossP);
        canvas.drawCircle(h, 4.5, Paint()..color = const Color(0xFFDC2626)..style = PaintingStyle.stroke..strokeWidth = 1.2);
      }

      final targets = [leftHole, midHole, rightHole];
      final activeHole = targets[(animationProgress * 3).clamp(0, 2).toInt()];
      _drawRealisticPencil(canvas, activeHole, -0.7);

      _drawDimensionLine(canvas, Offset(strutRect.left, cy - 24), Offset(strutRect.right, cy - 24), 'Total 15.0 cm');
      _drawCalloutBubble(canvas, activeHole, Offset(activeHole.dx, cy - 60), 'Concentric Pivot Crosshair', '✏️', const Color(0xFFDC2626));

    } else {
      // Stage 3: Punch clean 3mm holes
      for (final h in [leftHole, midHole, rightHole]) {
        canvas.drawCircle(h, 5, Paint()..color = isDark ? const Color(0xFF0B192C) : Colors.white);
        canvas.drawCircle(h, 5, Paint()..color = const Color(0xFF0284C7)..strokeWidth = 1.5..style = PaintingStyle.stroke);
      }

      // Small round cutout paper discs falling below
      final dropY = cy + 25 + (animationProgress * 20);
      canvas.drawCircle(Offset(leftHole.dx, dropY), 4, Paint()..color = const Color(0xFFD97706));
      canvas.drawCircle(Offset(midHole.dx, dropY), 4, Paint()..color = const Color(0xFFD97706));
      canvas.drawCircle(Offset(rightHole.dx, dropY), 4, Paint()..color = const Color(0xFFD97706));

      _drawCalloutBubble(canvas, midHole, Offset(cx, cy - 50), 'Ø 3mm Clean Through-Hole', '🕳️', const Color(0xFF059669));
      _drawCalloutBubble(canvas, Offset(midHole.dx, dropY), Offset(cx, cy + 65), 'Paper Discs Punched Out', '⚪', const Color(0xFFD97706));
    }

    if (mode == InfographicMode.physics) {
      _drawForceVector(canvas, midHole, Offset(midHole.dx, midHole.dy - 35), const Color(0xFF818CF8), 'Neutral Bending Axis');
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // DIAGRAM 7: ASSEMBLE X-LINKS WITH SPACER WASHERS (Scissor Lift Step 3)
  // EXACT SPEC: Cross two 15cm struts into X at 7.5cm hole.
  // Brass paper fastener with cardboard donut washer between strips!
  // Wings spread flat on back loosely.
  // ══════════════════════════════════════════════════════════════════
  void _drawXAssemblyDiagram(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final isDark = mode == InfographicMode.blueprint || mode == InfographicMode.physics;

    const strutLen = 180.0;
    const strutH = 22.0;
    final angle = 0.50 + (math.sin(animationProgress * math.pi * 2) * 0.22); // ~28° to 42°

    if (stageIndex == 0) {
      // Stage 1: Cross Two Struts at 7.5cm Center Hole
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(-angle);
      _drawCardboardTexture(canvas, Rect.fromCenter(center: Offset.zero, width: strutLen, height: strutH), horizontal: true);
      canvas.drawCircle(const Offset(-strutLen / 2 + 18, 0), 4, Paint()..color = isDark ? const Color(0xFF0B192C) : Colors.white);
      canvas.drawCircle(const Offset(strutLen / 2 - 18, 0), 4, Paint()..color = isDark ? const Color(0xFF0B192C) : Colors.white);
      canvas.restore();

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      _drawCardboardTexture(canvas, Rect.fromCenter(center: Offset.zero, width: strutLen, height: strutH), horizontal: true);
      canvas.drawCircle(const Offset(-strutLen / 2 + 18, 0), 4, Paint()..color = isDark ? const Color(0xFF0B192C) : Colors.white);
      canvas.drawCircle(const Offset(strutLen / 2 - 18, 0), 4, Paint()..color = isDark ? const Color(0xFF0B192C) : Colors.white);
      canvas.restore();

      // Aligned center hole
      canvas.drawCircle(Offset(cx, cy), 5, Paint()..color = isDark ? const Color(0xFF0B192C) : Colors.white);
      canvas.drawCircle(Offset(cx, cy), 5, Paint()..color = const Color(0xFF0284C7)..strokeWidth = 1.5..style = PaintingStyle.stroke);

      _drawCalloutBubble(canvas, Offset(cx, cy), Offset(cx, cy - 50), 'Center 7.5cm Holes Aligned', '🎯', const Color(0xFF0284C7));

    } else if (stageIndex == 1) {
      // Stage 2: Exploded 3D view: Front Strut + Cardboard Donut Washer + Back Strut + Brass Pin
      final slideOffset = 28 * (1.0 - animationProgress);

      // Back strut
      canvas.save();
      canvas.translate(cx + 8, cy);
      canvas.rotate(angle);
      _drawCardboardTexture(canvas, Rect.fromCenter(center: Offset.zero, width: strutLen, height: strutH), horizontal: true);
      canvas.restore();

      // Cardboard Donut Washer Spacer (Ø 12mm with 3mm hole)
      final washerCenter = Offset(cx, cy);
      canvas.drawCircle(washerCenter, 10, Paint()..color = const Color(0xFFFDE68A));
      canvas.drawCircle(washerCenter, 10, Paint()..color = const Color(0xFFB45309)..strokeWidth = 1.5..style = PaintingStyle.stroke);
      canvas.drawCircle(washerCenter, 4, Paint()..color = isDark ? const Color(0xFF0B192C) : Colors.white);

      // Front strut
      canvas.save();
      canvas.translate(cx - 8, cy);
      canvas.rotate(-angle);
      _drawCardboardTexture(canvas, Rect.fromCenter(center: Offset.zero, width: strutLen, height: strutH), horizontal: true);
      canvas.restore();

      // Golden Brass Pin inserting from front
      final pinCenter = Offset(cx - 8 - slideOffset, cy);
      _drawBrassFastener(canvas, pinCenter);

      _drawCalloutBubble(canvas, pinCenter, Offset(pinCenter.dx - 45, pinCenter.dy - 40), 'Brass Fastener Pin', '🔩', const Color(0xFFF59E0B));
      _drawCalloutBubble(canvas, washerCenter, Offset(washerCenter.dx + 45, washerCenter.dy + 45), 'Donut Washer Spacer', '🍩', const Color(0xFFB45309));

    } else {
      // Stage 3: Rear View - Wings Spread Flat 180° & Animated Swivel Test
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(-angle);
      _drawCardboardTexture(canvas, Rect.fromCenter(center: Offset.zero, width: strutLen, height: strutH), horizontal: true);
      canvas.restore();

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      _drawCardboardTexture(canvas, Rect.fromCenter(center: Offset.zero, width: strutLen, height: strutH), horizontal: true);
      canvas.restore();

      // Wings spread flat on back
      _drawBrassFastener(canvas, Offset(cx, cy), rearWings: true);

      _drawCalloutBubble(canvas, Offset(cx, cy), Offset(cx, cy - 45), 'Wings Spread Flat 180°', '🔄', const Color(0xFF059669));
      _drawCalloutBubble(canvas, Offset(cx + 60, cy), Offset(cx + 60, cy + 45), 'Zero-Friction Scissor Action', '✅', const Color(0xFF0284C7));
    }

    if (mode == InfographicMode.physics) {
      _drawForceVector(canvas, Offset(cx, cy), Offset(cx + 40, cy - 30), const Color(0xFF22C55E), 'Kinematic Pantograph MA=2.0');
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // DIAGRAM 8: CONNECT STAGES & PLATFORM (Scissor Lift Step 4)
  // EXACT SPEC: 3 X-tiers linked vertically, flat base with 1 fixed pin
  // and 1 sliding track. Push bottom feet together to elevate!
  // ══════════════════════════════════════════════════════════════════
  void _drawLiftCompleteDiagram(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final isDark = mode == InfographicMode.blueprint || mode == InfographicMode.physics;

    final liftProgress = animationProgress;
    const baseWidth = 220.0;
    final baseY = size.height - 35.0;

    final sliderDeltaX = liftProgress * 40.0;
    final fixedAnchorX = cx - 65.0;
    final slideShoeX = (cx + 65.0) - sliderDeltaX;

    final tierH = 22.0 + (liftProgress * 30.0);
    final midY1 = baseY - tierH;
    final midY2 = midY1 - tierH;
    final platformY = midY2 - tierH;

    // 1. Bottom Base Foundation Plate
    final basePlate = Rect.fromCenter(center: Offset(cx, baseY + 6), width: baseWidth, height: 14);
    _drawCardboardTexture(canvas, basePlate, horizontal: true);

    // Fixed Anchor Bracket on Left
    canvas.drawRect(Rect.fromLTWH(fixedAnchorX - 8, baseY - 8, 16, 14), Paint()..color = const Color(0xFF0284C7));
    _drawBrassFastener(canvas, Offset(fixedAnchorX, baseY));

    // Horizontal Sliding Guide Slot & Shoe on Right
    final slotTrack = Rect.fromLTWH(cx + 10, baseY - 3, 75, 6);
    canvas.drawRRect(RRect.fromRectAndRadius(slotTrack, const Radius.circular(3)), Paint()..color = const Color(0xFF64748B));
    final shoeRect = Rect.fromCenter(center: Offset(slideShoeX, baseY), width: 18, height: 10);
    canvas.drawRRect(RRect.fromRectAndRadius(shoeRect, const Radius.circular(2)), Paint()..color = const Color(0xFFF59E0B));
    _drawBrassFastener(canvas, Offset(slideShoeX, baseY));

    // 2. 3 Tiers of Crossing Linkages
    final pStrut = Paint()..color = isDark ? const Color(0xFF1E3E62) : const Color(0xFFFDE68A)..strokeWidth = 10..strokeCap = StrokeCap.round;

    // Tier 1
    canvas.drawLine(Offset(fixedAnchorX, baseY), Offset(slideShoeX, midY1), pStrut);
    canvas.drawLine(Offset(slideShoeX, baseY), Offset(fixedAnchorX, midY1), pStrut);
    _drawBrassFastener(canvas, Offset((fixedAnchorX + slideShoeX) / 2, (baseY + midY1) / 2));

    // Tier 2
    canvas.drawLine(Offset(fixedAnchorX, midY1), Offset(slideShoeX, midY2), pStrut);
    canvas.drawLine(Offset(slideShoeX, midY1), Offset(fixedAnchorX, midY2), pStrut);
    _drawBrassFastener(canvas, Offset((fixedAnchorX + slideShoeX) / 2, (midY1 + midY2) / 2));

    // Tier 3
    canvas.drawLine(Offset(fixedAnchorX, midY2), Offset(slideShoeX, platformY), pStrut);
    canvas.drawLine(Offset(slideShoeX, midY2), Offset(fixedAnchorX, platformY), pStrut);
    _drawBrassFastener(canvas, Offset((fixedAnchorX + slideShoeX) / 2, (midY2 + platformY) / 2));

    // 3. Top Platform Plate
    final topPlatform = Rect.fromCenter(center: Offset(cx - (sliderDeltaX / 2), platformY - 6), width: 180, height: 12);
    _drawCardboardTexture(canvas, topPlatform, horizontal: true);
    _drawBrassFastener(canvas, Offset(fixedAnchorX, platformY));
    _drawBrassFastener(canvas, Offset(slideShoeX, platformY));

    if (stageIndex == 0) {
      _drawDimensionLine(canvas, Offset(cx - 90, baseY), Offset(cx - 90, platformY), '3 X-Tiers Stacked', isVertical: true);
      _drawCalloutBubble(canvas, Offset(fixedAnchorX, midY1), Offset(fixedAnchorX - 35, midY1 - 20), 'Tier Pivot Joints', '🔗', const Color(0xFF0284C7));

    } else if (stageIndex == 1) {
      _drawCalloutBubble(canvas, Offset(fixedAnchorX, baseY), Offset(fixedAnchorX - 35, baseY - 30), 'Fixed Base Anchor', '⚓', const Color(0xFF0284C7));
      _drawCalloutBubble(canvas, Offset(slideShoeX, baseY), Offset(slideShoeX + 35, baseY - 30), 'Sliding Track Shoe', '↔️', const Color(0xFFF59E0B));

    } else {
      final payload = Rect.fromCenter(center: Offset(topPlatform.center.dx, topPlatform.top - 14), width: 40, height: 24);
      canvas.drawRRect(RRect.fromRectAndRadius(payload, const Radius.circular(4)), Paint()..color = const Color(0xFF10B981));
      canvas.drawRRect(RRect.fromRectAndRadius(payload, const Radius.circular(4)), Paint()..color = const Color(0xFF047857)..strokeWidth = 1.5..style = PaintingStyle.stroke);

      _drawDimensionLine(canvas, Offset(cx - 105, baseY), Offset(cx - 105, platformY), 'Lift Stroke 4×', isVertical: true);
      _drawCalloutBubble(canvas, payload.center, Offset(payload.center.dx, payload.top - 20), 'Elevates 4× Input Travel!', '🚀', const Color(0xFF10B981));
    }

    if (mode == InfographicMode.physics) {
      _drawForceVector(canvas, Offset(topPlatform.center.dx, platformY - 24), Offset(topPlatform.center.dx, platformY + 16), const Color(0xFFEF4444), 'W = mg Downward');
      _drawForceVector(canvas, Offset(slideShoeX, baseY), Offset(slideShoeX - 30, baseY), const Color(0xFF22C55E), 'F_push Actuator');
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // DIAGRAM 2: STRAW SLEEVE BEARINGS (Test Cart Step 1)
  // ══════════════════════════════════════════════════════════════════
  void _drawStrawBearingsDiagram(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final isDark = mode == InfographicMode.blueprint || mode == InfographicMode.physics;

    if (stageIndex == 0) {
      // Stage 1: Measure 9 cm on straw with ruler and cut
      final strawFull = Rect.fromCenter(center: Offset(cx, cy - 20), width: 240, height: 16);
      canvas.drawRRect(RRect.fromRectAndRadius(strawFull, const Radius.circular(8)), Paint()..color = const Color(0xFF06B6D4));

      // Cut mark at 9 cm (120px from left)
      final cutX = strawFull.left + 120;
      final scissorOffset = math.sin(animationProgress * math.pi * 4) * 6;

      canvas.drawLine(Offset(cutX, cy - 35), Offset(cutX, cy - 5), Paint()..color = const Color(0xFFEF4444)..strokeWidth = 2);

      // Animated Scissor Tool
      final scissorY = cy - 20 + scissorOffset;
      final bladePaint = Paint()..color = const Color(0xFFEF4444)..strokeWidth = 2.5..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(cutX - 12, scissorY - 14), Offset(cutX, scissorY), bladePaint);
      canvas.drawLine(Offset(cutX + 12, scissorY - 14), Offset(cutX, scissorY), bladePaint);
      canvas.drawCircle(Offset(cutX, scissorY), 3.5, Paint()..color = const Color(0xFF991B1B));

      _drawCalloutBubble(canvas, Offset(cutX, cy - 20), Offset(cutX, cy - 65), 'Cut at 9.0 cm', '✂️', const Color(0xFFEF4444));

      // Ruler below straw
      final rulerRect = Rect.fromCenter(center: Offset(cx, cy + 30), width: 250, height: 18);
      canvas.drawRRect(RRect.fromRectAndRadius(rulerRect, const Radius.circular(4)), Paint()..color = const Color(0xFFFBBF24));
      _drawDimensionLine(canvas, Offset(strawFull.left, cy - 4), Offset(cutX, cy - 4), '9.0 cm Segment');

    } else if (stageIndex == 1) {
      // Stage 2: Mark guidelines on chassis base
      final chassis = Rect.fromCenter(center: Offset(cx, cy), width: 220, height: 130);
      canvas.drawRRect(RRect.fromRectAndRadius(chassis, const Radius.circular(8)), Paint()..color = isDark ? const Color(0xFF1E3E62) : const Color(0xFFFDE68A));
      canvas.drawRRect(RRect.fromRectAndRadius(chassis, const Radius.circular(8)), Paint()..color = const Color(0xFFB45309)..strokeWidth = 1.5..style = PaintingStyle.stroke);

      // Two pencil guide lines
      final line1Y = cy - 40.0;
      final line2Y = cy + 40.0;
      final pencilPaint = Paint()..color = const Color(0xFF0284C7)..strokeWidth = 1.5..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(chassis.left + 10, line1Y), Offset(chassis.right - 10, line1Y), pencilPaint);
      canvas.drawLine(Offset(chassis.left + 10, line2Y), Offset(chassis.right - 10, line2Y), pencilPaint);

      // Animated pencil drawing line 1 or 2
      final activeLineY = animationProgress < 0.5 ? line1Y : line2Y;
      final pencilTipX = chassis.left + 20 + (animationProgress % 0.5) * 2 * (chassis.width - 40);
      canvas.drawLine(Offset(pencilTipX + 12, activeLineY - 18), Offset(pencilTipX, activeLineY), Paint()..color = const Color(0xFFF59E0B)..strokeWidth = 3.5..strokeCap = StrokeCap.round);
      canvas.drawCircle(Offset(pencilTipX, activeLineY), 2.5, Paint()..color = const Color(0xFF0F172A));

      _drawDimensionLine(canvas, Offset(chassis.right + 10, chassis.top), Offset(chassis.right + 10, line1Y), '2 cm', isVertical: true);
      _drawCalloutBubble(canvas, Offset(cx, line1Y), Offset(cx, line1Y - 26), 'Front Axle Guideline', '✏️', const Color(0xFF0284C7));
      _drawCalloutBubble(canvas, Offset(cx, line2Y), Offset(cx, line2Y + 26), 'Rear Axle Guideline', '✏️', const Color(0xFF0284C7));

    } else {
      // Stage 3: Glue straws firmly on the lines
      final chassis = Rect.fromCenter(center: Offset(cx, cy), width: 220, height: 130);
      canvas.drawRRect(RRect.fromRectAndRadius(chassis, const Radius.circular(8)), Paint()..color = isDark ? const Color(0xFF1E3E62) : const Color(0xFFFDE68A));
      canvas.drawRRect(RRect.fromRectAndRadius(chassis, const Radius.circular(8)), Paint()..color = const Color(0xFFB45309)..strokeWidth = 1.5..style = PaintingStyle.stroke);

      // Two glued straws
      final frontStraw = Rect.fromCenter(center: Offset(cx, cy - 40), width: 190, height: 14);
      final rearStraw = Rect.fromCenter(center: Offset(cx, cy + 40), width: 190, height: 14);

      canvas.drawRRect(RRect.fromRectAndRadius(frontStraw, const Radius.circular(7)), Paint()..color = const Color(0xFF06B6D4));
      canvas.drawRRect(RRect.fromRectAndRadius(rearStraw, const Radius.circular(7)), Paint()..color = const Color(0xFF06B6D4));

      // Hot glue beads
      final gluePaint = Paint()..color = const Color(0xFFF59E0B)..strokeWidth = 3.0..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(frontStraw.left + 20, cy - 47), Offset(frontStraw.right - 20, cy - 47), gluePaint);
      canvas.drawLine(Offset(rearStraw.left + 20, cy + 47), Offset(rearStraw.right - 20, cy + 47), gluePaint);

      _drawCalloutBubble(canvas, Offset(frontStraw.center.dx, cy - 40), Offset(frontStraw.center.dx, cy - 68), '9 cm Straw Sleeve', '🥤', const Color(0xFF0284C7));
      _drawCalloutBubble(canvas, Offset(cx + 60, cy - 47), Offset(cx + 70, cy - 20), 'Hot Glue Bead', '💧', const Color(0xFFD97706));
      _drawCalloutBubble(canvas, Offset(rearStraw.center.dx, cy + 40), Offset(rearStraw.center.dx, cy + 68), 'Strictly Parallel ↔️', '✅', const Color(0xFF059669));
    }

    if (mode == InfographicMode.physics) {
      _drawForceVector(canvas, Offset(cx - 80, cy - 40), Offset(cx - 80, cy - 20), const Color(0xFF22C55E), 'Zero Camber Angle');
      _drawForceVector(canvas, Offset(cx, cy), Offset(cx + 50, cy), const Color(0xFF818CF8), 'Smooth Rolling Bore μ=0.02');
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // DIAGRAM 3: WHEEL CUTTING & HOLE CENTERING (Test Cart Step 2)
  // ══════════════════════════════════════════════════════════════════
  void _drawWheelCuttingDiagram(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final isDark = mode == InfographicMode.blueprint || mode == InfographicMode.physics;
    const r = 58.0;

    if (stageIndex == 0) {
      // Stage 1: Trace 5 cm circle on square cardboard blank
      final blankRect = Rect.fromCenter(center: Offset(cx, cy), width: 140, height: 140);
      canvas.drawRRect(RRect.fromRectAndRadius(blankRect, const Radius.circular(8)), Paint()..color = isDark ? const Color(0xFF1E3E62) : const Color(0xFFFEF3C7));
      canvas.drawRRect(RRect.fromRectAndRadius(blankRect, const Radius.circular(8)), Paint()..color = const Color(0xFFD97706)..strokeWidth = 1.5..style = PaintingStyle.stroke);

      // Animated Compass drawing circle
      final sweepAngle = animationProgress * math.pi * 2;
      canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), -math.pi / 2, sweepAngle, false, Paint()..color = const Color(0xFF0284C7)..strokeWidth = 2.5..style = PaintingStyle.stroke);

      // Compass tip
      final tipX = cx + r * math.cos(-math.pi / 2 + sweepAngle);
      final tipY = cy + r * math.sin(-math.pi / 2 + sweepAngle);
      canvas.drawLine(Offset(cx, cy), Offset(tipX, tipY), Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 1.8);
      canvas.drawCircle(Offset(tipX, tipY), 4, Paint()..color = const Color(0xFF2563EB));

      _drawDimensionLine(canvas, Offset(cx - r, cy - r - 12), Offset(cx + r, cy - r - 12), 'Diameter: 5.0 cm');
      _drawCalloutBubble(canvas, Offset(cx + r, cy), Offset(cx + r + 30, cy - 30), 'Trace 4 Wheel Discs', '⭕', const Color(0xFF0284C7));

    } else if (stageIndex == 1) {
      // Stage 2: Diagonal X lines to find center
      final blankRect = Rect.fromCenter(center: Offset(cx, cy), width: 140, height: 140);
      canvas.drawRRect(RRect.fromRectAndRadius(blankRect, const Radius.circular(8)), Paint()..color = isDark ? const Color(0xFF1E3E62) : const Color(0xFFFEF3C7));

      final crossPaint = Paint()..color = const Color(0xFFDC2626)..strokeWidth = 1.5;
      canvas.drawLine(blankRect.topLeft, blankRect.bottomRight, crossPaint);
      canvas.drawLine(blankRect.topRight, blankRect.bottomLeft, crossPaint);
      canvas.drawCircle(Offset(cx, cy), 5, Paint()..color = const Color(0xFFDC2626));

      // Circular alignment check ring
      canvas.drawCircle(Offset(cx, cy), r, Paint()..color = const Color(0xFF0284C7).withValues(alpha: 0.5)..strokeWidth = 1.5..style = PaintingStyle.stroke);

      _drawCalloutBubble(canvas, Offset(cx, cy), Offset(cx, cy - 50), 'Exact Geometric Center', '🎯', const Color(0xFFDC2626));

    } else {
      // Stage 3: Pierce hole with skewer and spin test
      final wheelCenter = Offset(cx, cy);
      canvas.drawCircle(wheelCenter, r, Paint()..color = isDark ? const Color(0xFF1E3E62) : const Color(0xFFFDE68A));
      canvas.drawCircle(wheelCenter, r, Paint()..color = isDark ? const Color(0xFF00ADB5) : const Color(0xFFB45309)..strokeWidth = 2.5..style = PaintingStyle.stroke);

      // Bamboo skewer through hole
      final spinAngle = animationProgress * math.pi * 4;
      canvas.drawLine(Offset(cx - 60 * math.cos(spinAngle), cy - 60 * math.sin(spinAngle)), Offset(cx + 60 * math.cos(spinAngle), cy + 60 * math.sin(spinAngle)), Paint()..color = const Color(0xFFF59E0B)..strokeWidth = 3);
      canvas.drawCircle(wheelCenter, 5, Paint()..color = const Color(0xFF0F172A));

      // Spin rotation arc indicators
      canvas.drawArc(Rect.fromCircle(center: wheelCenter, radius: r + 10), spinAngle, math.pi / 2, false, Paint()..color = const Color(0xFF059669)..strokeWidth = 2.0..style = PaintingStyle.stroke);

      _drawCalloutBubble(canvas, wheelCenter, Offset(cx + 60, cy + 50), 'Clean 3mm Axle Hole', '🪵', const Color(0xFF0284C7));
      _drawCalloutBubble(canvas, Offset(cx, cy - r), Offset(cx, cy - r - 25), 'Zero Wobble Spin Test', '✅', const Color(0xFF059669));
    }

    if (mode == InfographicMode.physics) {
      _drawForceVector(canvas, Offset(cx, cy), Offset(cx + r, cy), const Color(0xFF22C55E), 'Uniform Radius R=2.5cm');
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // DIAGRAM 4: EXPLODED WHEEL & AXLE ASSEMBLY (Test Cart Step 3)
  // ══════════════════════════════════════════════════════════════════
  void _drawWheelAssemblyDiagram(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final isDark = mode == InfographicMode.blueprint || mode == InfographicMode.physics;

    if (stageIndex == 0) {
      // Stage 1: Thread Bamboo Axle through Straw Sleeve
      final axleSlideX = -40 + (animationProgress * 40.0);
      final axleRect = Rect.fromCenter(center: Offset(cx + axleSlideX, cy), width: 220, height: 7);
      canvas.drawRRect(RRect.fromRectAndRadius(axleRect, const Radius.circular(3)), Paint()..color = const Color(0xFFFBBF24));

      // Straw sleeve
      final strawRect = Rect.fromCenter(center: Offset(cx, cy), width: 120, height: 16);
      canvas.drawRRect(RRect.fromRectAndRadius(strawRect, const Radius.circular(8)), Paint()..color = const Color(0xFF06B6D4));

      _drawCalloutBubble(canvas, Offset(strawRect.center.dx, strawRect.top), Offset(strawRect.center.dx, strawRect.top - 25), 'Straw Sleeve Bearing', '🥤', const Color(0xFF0284C7));
      _drawCalloutBubble(canvas, Offset(axleRect.left + 20, cy), Offset(axleRect.left - 20, cy - 30), 'Bamboo Axle', '🪵', const Color(0xFFD97706));

    } else if (stageIndex == 1) {
      // Stage 2: Slide Donut Washer Spacer onto Axle
      final axleRect = Rect.fromCenter(center: Offset(cx, cy), width: 220, height: 7);
      canvas.drawRRect(RRect.fromRectAndRadius(axleRect, const Radius.circular(3)), Paint()..color = const Color(0xFFFBBF24));

      final strawRect = Rect.fromCenter(center: Offset(cx, cy), width: 120, height: 16);
      canvas.drawRRect(RRect.fromRectAndRadius(strawRect, const Radius.circular(8)), Paint()..color = const Color(0xFF06B6D4));

      // Animated Donut spacer sliding towards straw end
      final spacerTargetX = cx - 68;
      final spacerCurrentX = (cx - 100) + (animationProgress * (spacerTargetX - (cx - 100)));
      final spacer = Rect.fromCenter(center: Offset(spacerCurrentX, cy), width: 10, height: 26);
      canvas.drawRRect(RRect.fromRectAndRadius(spacer, const Radius.circular(3)), Paint()..color = const Color(0xFFFDE68A));
      canvas.drawRRect(RRect.fromRectAndRadius(spacer, const Radius.circular(3)), Paint()..color = const Color(0xFFB45309)..strokeWidth = 1.2..style = PaintingStyle.stroke);

      _drawDimensionLine(canvas, Offset(spacerTargetX, cy - 25), Offset(strawRect.left, cy - 25), '1.0 mm Gap');
      _drawCalloutBubble(canvas, Offset(spacerCurrentX, cy), Offset(spacerCurrentX, cy + 35), 'Donut Washer Spacer', '🍩', const Color(0xFFB45309));

    } else {
      // Stage 3: Mount Wheel Disc & Apply Outer Glue Collar
      final axleRect = Rect.fromCenter(center: Offset(cx, cy), width: size.width - 80, height: 7);
      canvas.drawRRect(RRect.fromRectAndRadius(axleRect, const Radius.circular(3)), Paint()..color = const Color(0xFFFBBF24));

      // Straw sleeve
      final strawRect = Rect.fromCenter(center: Offset(cx, cy), width: 120, height: 16);
      canvas.drawRRect(RRect.fromRectAndRadius(strawRect, const Radius.circular(8)), Paint()..color = const Color(0xFF06B6D4));

      // Donut spacers on both sides
      final spacerLeft = Rect.fromCenter(center: Offset(cx - 68, cy), width: 10, height: 26);
      final spacerRight = Rect.fromCenter(center: Offset(cx + 68, cy), width: 10, height: 26);
      canvas.drawRRect(RRect.fromRectAndRadius(spacerLeft, const Radius.circular(3)), Paint()..color = const Color(0xFFFDE68A));
      canvas.drawRRect(RRect.fromRectAndRadius(spacerRight, const Radius.circular(3)), Paint()..color = const Color(0xFFFDE68A));

      // Wheel discs on both ends
      final wheelLeft = Rect.fromCenter(center: Offset(cx - 95, cy), width: 14, height: 80);
      final wheelRight = Rect.fromCenter(center: Offset(cx + 95, cy), width: 14, height: 80);
      final wheelPaint = Paint()..color = isDark ? const Color(0xFF1E3E62) : const Color(0xFFFDE68A);
      final wheelBorder = Paint()..color = isDark ? const Color(0xFF00ADB5) : const Color(0xFFB45309)..strokeWidth = 1.5..style = PaintingStyle.stroke;

      canvas.drawRRect(RRect.fromRectAndRadius(wheelLeft, const Radius.circular(5)), wheelPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(wheelLeft, const Radius.circular(5)), wheelBorder);
      canvas.drawRRect(RRect.fromRectAndRadius(wheelRight, const Radius.circular(5)), wheelPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(wheelRight, const Radius.circular(5)), wheelBorder);

      // Outer glue collars
      canvas.drawCircle(Offset(cx - 108, cy), 5, Paint()..color = const Color(0xFFDC2626));
      canvas.drawCircle(Offset(cx + 108, cy), 5, Paint()..color = const Color(0xFFDC2626));

      _drawCalloutBubble(canvas, Offset(cx - 95, cy - 40), Offset(cx - 95, cy - 65), 'Wheel Disc (Ø 5cm)', '⭕', const Color(0xFF78350F));
      _drawCalloutBubble(canvas, Offset(cx - 108, cy), Offset(cx - 110, cy + 30), 'Outer Glue Collar', '🔒', const Color(0xFFDC2626));
      _drawCalloutBubble(canvas, Offset(strawRect.center.dx, strawRect.bottom), Offset(strawRect.center.dx, strawRect.bottom + 25), 'Zero Friction Spin', '✅', const Color(0xFF059669));
    }

    if (mode == InfographicMode.physics) {
      _drawForceVector(canvas, Offset(cx, cy), Offset(cx + 40, cy), const Color(0xFF22C55E), 'Rotational Freedom');
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // DIAGRAM 5: 3-METER ROLLOUT TEST (Test Cart Step 4)
  // ══════════════════════════════════════════════════════════════════
  void _drawCartRolloutDiagram(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ramp on left (30° angle)
    final ramp = Path()..moveTo(20, h - 30)..lineTo(110, h - 90)..lineTo(110, h - 30)..close();
    canvas.drawPath(ramp, Paint()..color = const Color(0xFFCBD5E1));

    // Runway floor line
    canvas.drawLine(Offset(20, h - 30), Offset(w - 20, h - 30), Paint()..color = const Color(0xFF334155)..strokeWidth = 2);

    // Metric Distance Tick Marks on Floor: 1.0m, 2.0m, 3.0m
    final m1X = 110 + (w - 140) * 0.33;
    final m2X = 110 + (w - 140) * 0.66;
    final m3X = w - 40.0;
    final tickP = Paint()..color = const Color(0xFF64748B)..strokeWidth = 1.5;
    for (final mx in [m1X, m2X, m3X]) {
      canvas.drawLine(Offset(mx, h - 30), Offset(mx, h - 22), tickP);
    }

    if (stageIndex == 0) {
      // Stage 1: Incline ramp setup (30° incline)
      _drawDimensionLine(canvas, Offset(110, h - 90), Offset(110, h - 30), 'H: 30 cm', isVertical: true);
      _drawCalloutBubble(canvas, const Offset(65, 120), const Offset(65, 80), '30° Launch Ramp', '📐', const Color(0xFF0284C7));

    } else if (stageIndex == 1) {
      // Stage 2: Cart poised at ramp crest ready for hands-off release
      const crestX = 85.0;
      const crestY = 120.0;
      canvas.save();
      canvas.translate(crestX, crestY);
      canvas.rotate(-math.pi / 6);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 50, height: 16), const Radius.circular(4)), Paint()..color = const Color(0xFFFDE68A));
      canvas.drawCircle(const Offset(-16, 10), 8, Paint()..color = const Color(0xFFD97706));
      canvas.drawCircle(const Offset(16, 10), 8, Paint()..color = const Color(0xFFD97706));
      canvas.restore();

      _drawCalloutBubble(canvas, const Offset(crestX, crestY), const Offset(crestX + 40, crestY - 35), 'Hands-Off Release', '🚀', const Color(0xFFD97706));

    } else {
      // Stage 3: Animated Rollout to 3 meters
      final cartX = 140.0 + (animationProgress * (w - 240.0));
      final cartY = h - 54.0;
      final cart = Rect.fromCenter(center: Offset(cartX, cartY), width: 64, height: 18);

      // Speed trail behind cart
      final trailPaint = Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.4)..strokeWidth = 2.0;
      canvas.drawLine(Offset(120, cartY), Offset(cartX - 35, cartY), trailPaint);

      canvas.drawRRect(RRect.fromRectAndRadius(cart, const Radius.circular(4)), Paint()..color = const Color(0xFFFDE68A));
      canvas.drawCircle(Offset(cartX - 22, h - 38), 10, Paint()..color = const Color(0xFFD97706));
      canvas.drawCircle(Offset(cartX + 22, h - 38), 10, Paint()..color = const Color(0xFFD97706));

      _drawDimensionLine(canvas, Offset(110, h - 14), Offset(w - 30, h - 14), '3.0 Meter Target Run');
      _drawCalloutBubble(canvas, Offset(cartX, cartY), Offset(cartX, cartY - 35), 'Gliding True & Straight', '🏎️', const Color(0xFF059669));
    }

    if (mode == InfographicMode.physics) {
      final cartX = 140.0 + (animationProgress * (w - 240.0));
      final cartY = h - 54.0;
      _drawForceVector(canvas, Offset(cartX, cartY), Offset(cartX + 50, cartY), const Color(0xFF22C55E), 'v Velocity');
      _drawForceVector(canvas, Offset(cartX - 22, h - 28), Offset(cartX - 45, h - 28), const Color(0xFFEF4444), 'Ff Rolling μ=0.02');
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // DIAGRAM 9: TUBE CUTTING & U-CHANNELS (Marble Coaster Step 1)
  // ══════════════════════════════════════════════════════════════════
  void _drawTubeCuttingDiagram(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final isDark = mode == InfographicMode.blueprint || mode == InfographicMode.physics;

    if (stageIndex == 0) {
      // Stage 1: Cardboard tube with center split guideline
      final tubeRect = Rect.fromCenter(center: Offset(cx, cy), width: 250, height: 45);
      canvas.drawRRect(RRect.fromRectAndRadius(tubeRect, const Radius.circular(10)), Paint()..color = isDark ? const Color(0xFF1E3E62) : const Color(0xFFFDE68A));
      canvas.drawRRect(RRect.fromRectAndRadius(tubeRect, const Radius.circular(10)), Paint()..color = const Color(0xFFB45309)..strokeWidth = 2.0..style = PaintingStyle.stroke);

      // Centerline guide
      final centerP = Paint()..color = const Color(0xFFEF4444)..strokeWidth = 2.0..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(tubeRect.left + 8, cy), Offset(tubeRect.right - 8, cy), centerP);

      _drawDimensionLine(canvas, Offset(tubeRect.left, cy - 32), Offset(tubeRect.right, cy - 32), 'Length: 30 cm Tube');
      _drawCalloutBubble(canvas, Offset(cx, cy), Offset(cx, cy - 60), 'Draw Splitting Guideline', '📏', const Color(0xFFEF4444));

    } else if (stageIndex == 1) {
      // Stage 2: Slicing tube into halves
      final cutProgress = animationProgress;
      final cutX = cx - 110 + (220 * cutProgress);

      final tubeRect = Rect.fromCenter(center: Offset(cx, cy), width: 250, height: 45);
      canvas.drawRRect(RRect.fromRectAndRadius(tubeRect, const Radius.circular(10)), Paint()..color = isDark ? const Color(0xFF1E3E62) : const Color(0xFFFDE68A));

      // Animated scissors along cut line
      canvas.drawLine(Offset(tubeRect.left + 8, cy), Offset(cutX, cy), Paint()..color = const Color(0xFFEF4444)..strokeWidth = 2.5);
      canvas.drawCircle(Offset(cutX, cy), 5, Paint()..color = const Color(0xFFDC2626));

      _drawCalloutBubble(canvas, Offset(cutX, cy), Offset(cutX, cy - 45), 'Carefully Slice Along Line', '✂️', const Color(0xFFEF4444));

    } else {
      // Stage 3: Two finished U-channel half-pipes
      final topTrough = Rect.fromCenter(center: Offset(cx, cy - 25), width: 230, height: 22);
      final botTrough = Rect.fromCenter(center: Offset(cx, cy + 25), width: 230, height: 22);

      final tPaint = Paint()..color = isDark ? const Color(0xFF1E3E62) : const Color(0xFFFDE68A);
      final tBorder = Paint()..color = isDark ? const Color(0xFF00ADB5) : const Color(0xFFB45309)..strokeWidth = 2.0..style = PaintingStyle.stroke;

      canvas.drawRRect(RRect.fromRectAndRadius(topTrough, const Radius.circular(11)), tPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(topTrough, const Radius.circular(11)), tBorder);
      canvas.drawRRect(RRect.fromRectAndRadius(botTrough, const Radius.circular(11)), tPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(botTrough, const Radius.circular(11)), tBorder);

      // Glass marble inside top channel
      canvas.drawCircle(Offset(cx - 40, cy - 25), 8, Paint()..color = const Color(0xFF06B6D4));

      _drawCalloutBubble(canvas, Offset(cx - 40, cy - 25), Offset(cx - 40, cy - 65), 'Smooth U-Channel Track', '🎢', const Color(0xFF0284C7));
      _drawCalloutBubble(canvas, Offset(cx + 40, cy + 25), Offset(cx + 40, cy + 65), '2 Half-Pipe Rails Ready', '✅', const Color(0xFF059669));
    }

    if (mode == InfographicMode.physics) {
      _drawForceVector(canvas, Offset(cx, cy), Offset(cx + 45, cy), const Color(0xFF22C55E), 'Low Rolling Friction');
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // DIAGRAM 10: INCLINE ANGLE & GRAVITY DROP (Marble Coaster Step 2)
  // ══════════════════════════════════════════════════════════════════
  void _drawAngleTestingDiagram(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 45° Curved Drop Ramp Path
    final path = Path()
      ..moveTo(40, 35)
      ..quadraticBezierTo(70, h - 50, w - 40, h - 50);

    canvas.drawPath(path, Paint()..color = const Color(0xFF0284C7)..strokeWidth = 8.0..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);

    if (stageIndex == 0) {
      _drawDimensionLine(canvas, const Offset(40, 35), Offset(40, h - 50), 'H: 35 cm', isVertical: true);
      _drawCalloutBubble(canvas, const Offset(40, 35), const Offset(90, 35), '45° Launch Drop', '📐', const Color(0xFF0284C7));

    } else if (stageIndex == 1) {
      _drawCalloutBubble(canvas, Offset(80, h - 70), Offset(130, h - 100), 'Smooth Parabolic Transition', '🔄', const Color(0xFFF59E0B));

    } else {
      // Animated Marble rolling along path
      final t = animationProgress;
      // Evaluate bezier point at t
      final p0 = const Offset(40, 35);
      final p1 = Offset(70, h - 50);
      final p2 = Offset(w - 40, h - 50);
      final mx = (1 - t) * (1 - t) * p0.dx + 2 * (1 - t) * t * p1.dx + t * t * p2.dx;
      final my = (1 - t) * (1 - t) * p0.dy + 2 * (1 - t) * t * p1.dy + t * t * p2.dy;

      // Marble
      canvas.drawCircle(Offset(mx, my), 9, Paint()..color = const Color(0xFF06B6D4));
      canvas.drawCircle(Offset(mx - 2, my - 2), 3, Paint()..color = Colors.white);

      _drawCalloutBubble(canvas, Offset(mx, my), Offset(mx, my - 35), 'Gravitational Acceleration', '⚪', const Color(0xFF06B6D4));
    }

    if (mode == InfographicMode.physics) {
      _drawForceVector(canvas, const Offset(60, 60), const Offset(60, 110), const Color(0xFFEF4444), 'g = 9.8 m/s²');
      _drawForceVector(canvas, Offset(w - 100, h - 50), Offset(w - 50, h - 50), const Color(0xFF22C55E), 'Kinetic Energy Ek');
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // DIAGRAM 11: BANKED TURNS & CENTRIPETAL FORCE (Marble Coaster Step 3)
  // ══════════════════════════════════════════════════════════════════
  void _drawBankedTurnsDiagram(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Banked track curved loop
    final arcRect = Rect.fromCircle(center: Offset(cx, cy + 20), radius: 80);
    canvas.drawArc(arcRect, math.pi, math.pi, false, Paint()..color = const Color(0xFF0284C7)..strokeWidth = 14..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);

    // Animated marble along curve
    final marbleAngle = math.pi + (animationProgress * math.pi);
    final mx = cx + 80 * math.cos(marbleAngle);
    final my = cy + 20 + 80 * math.sin(marbleAngle);

    canvas.drawCircle(Offset(mx, my), 9, Paint()..color = const Color(0xFF06B6D4));

    if (stageIndex == 0) {
      _drawCalloutBubble(canvas, Offset(cx - 80, cy + 20), Offset(cx - 80, cy - 30), 'Outer Track Wall', '📦', const Color(0xFF0284C7));
    } else if (stageIndex == 1) {
      _drawCalloutBubble(canvas, Offset(cx, cy - 60), Offset(cx, cy - 80), 'Banked Inward 20°', '📐', const Color(0xFFF59E0B));
    } else {
      _drawCalloutBubble(canvas, Offset(mx, my), Offset(mx, my - 35), 'Zero Derailment at Speed', '🎢', const Color(0xFF059669));
    }

    if (mode == InfographicMode.physics) {
      _drawForceVector(canvas, Offset(mx, my), Offset(cx, cy + 20), const Color(0xFF22C55E), 'Centripetal Force Fc');
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // DIAGRAM 12: MARBLE FINISH & CATCH FUNNEL (Marble Coaster Step 4)
  // ══════════════════════════════════════════════════════════════════
  void _drawMarbleFinishDiagram(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Terminal track
    canvas.drawLine(Offset(30, cy - 10), Offset(cx, cy - 10), Paint()..color = const Color(0xFF0284C7)..strokeWidth = 8..strokeCap = StrokeCap.round);

    // Funnel catcher
    final funnel = Path()
      ..moveTo(cx + 10, cy - 30)
      ..lineTo(cx + 80, cy - 30)
      ..lineTo(cx + 60, cy + 30)
      ..lineTo(cx + 30, cy + 30)
      ..close();
    canvas.drawPath(funnel, Paint()..color = const Color(0xFFFBBF24));
    canvas.drawPath(funnel, Paint()..color = const Color(0xFFB45309)..strokeWidth = 2.0..style = PaintingStyle.stroke);

    // Animated marble dropping into cup
    final dropProgress = animationProgress;
    final mx = cx + 10 + (dropProgress * 40.0);
    final my = (cy - 10) + (dropProgress * 30.0);
    canvas.drawCircle(Offset(mx, my), 8, Paint()..color = const Color(0xFF06B6D4));

    _drawCalloutBubble(canvas, Offset(cx + 45, cy + 30), Offset(cx + 45, cy + 65), 'Deceleration Catch Cup', '🏆', const Color(0xFF10B981));
  }

  // ══════════════════════════════════════════════════════════════════
  // DIAGRAM 13: PULLEY WHEEL & CRANE RIGGING
  // ══════════════════════════════════════════════════════════════════
  void _drawPulleyWheelDiagram(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final isDark = mode == InfographicMode.blueprint || mode == InfographicMode.physics;

    // Outer flange disc
    canvas.drawCircle(Offset(cx, cy), 55, Paint()..color = isDark ? const Color(0xFF1E3E62) : const Color(0xFFFDE68A));
    canvas.drawCircle(Offset(cx, cy), 55, Paint()..color = const Color(0xFFB45309)..strokeWidth = 2.0..style = PaintingStyle.stroke);

    // Inner groove hub
    canvas.drawCircle(Offset(cx, cy), 42, Paint()..color = isDark ? const Color(0xFF0B192C) : const Color(0xFFE2E8F0));
    canvas.drawCircle(Offset(cx, cy), 42, Paint()..color = const Color(0xFF0284C7)..strokeWidth = 1.5..style = PaintingStyle.stroke);

    // Center axle hole
    canvas.drawCircle(Offset(cx, cy), 6, Paint()..color = const Color(0xFF0F172A));

    // Spinning rope indicator
    final spinA = animationProgress * math.pi * 4;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: 46), spinA, math.pi / 2, false, Paint()..color = const Color(0xFFF59E0B)..strokeWidth = 3.5..style = PaintingStyle.stroke);

    _drawCalloutBubble(canvas, Offset(cx, cy), Offset(cx, cy - 70), 'Grooved Pulley Sheave', '⭕', const Color(0xFF0284C7));
    _drawCalloutBubble(canvas, Offset(cx + 46, cy), Offset(cx + 65, cy + 40), 'Cable Groove Ø 4.2cm', '🧵', const Color(0xFFF59E0B));
  }

  void _drawAFrameDiagram(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // A-frame triangular truss
    final apex = Offset(cx, cy - 65);
    final leftB = Offset(cx - 70, cy + 60);
    final rightB = Offset(cx + 70, cy + 60);

    final trussP = Paint()..color = const Color(0xFFFDE68A)..strokeWidth = 14..strokeCap = StrokeCap.round;
    canvas.drawLine(apex, leftB, trussP);
    canvas.drawLine(apex, rightB, trussP);
    canvas.drawLine(Offset(cx - 45, cy + 15), Offset(cx + 45, cy + 15), trussP); // Cross strut

    // Corner gusset plates
    canvas.drawCircle(apex, 10, Paint()..color = const Color(0xFF0284C7));

    _drawCalloutBubble(canvas, apex, Offset(cx, apex.dy - 30), 'Apex Pulley Bearing', '🏗️', const Color(0xFF0284C7));
    _drawCalloutBubble(canvas, Offset(cx, cy + 15), Offset(cx, cy + 40), 'Reinforced Cross Brace', '🛡️', const Color(0xFF10B981));
  }

  void _drawCraneCompleteDiagram(Canvas canvas, Size size) {
    _drawAFrameDiagram(canvas, size);
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Load payload animated lifting
    final loadY = (cy + 45) - (animationProgress * 50.0);
    final payload = Rect.fromCenter(center: Offset(cx, loadY), width: 34, height: 24);
    canvas.drawRRect(RRect.fromRectAndRadius(payload, const Radius.circular(4)), Paint()..color = const Color(0xFFEF4444));

    // Hoist cable from apex to payload
    canvas.drawLine(Offset(cx, cy - 65), Offset(cx, loadY - 12), Paint()..color = const Color(0xFFF59E0B)..strokeWidth = 2.5);

    _drawCalloutBubble(canvas, Offset(cx, loadY), Offset(cx + 45, loadY), '200g Payload Lifted', '⚖️', const Color(0xFFEF4444));

    if (mode == InfographicMode.physics) {
      _drawForceVector(canvas, Offset(cx, loadY), Offset(cx, loadY - 35), const Color(0xFF22C55E), '2:1 Mechanical Advantage');
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // DIAGRAM 14: PAPER CIRCUITS & ELECTRONICS
  // ══════════════════════════════════════════════════════════════════
  void _drawCircuitTraceDiagram(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Greeting card base
    final card = Rect.fromCenter(center: Offset(cx, cy), width: 240, height: 140);
    canvas.drawRRect(RRect.fromRectAndRadius(card, const Radius.circular(8)), Paint()..color = Colors.white);
    canvas.drawRRect(RRect.fromRectAndRadius(card, const Radius.circular(8)), Paint()..color = const Color(0xFFCBD5E1)..strokeWidth = 1.5..style = PaintingStyle.stroke);

    // Copper tape tracks
    final copperP = Paint()..color = const Color(0xFFF59E0B)..strokeWidth = 6.0..strokeCap = StrokeCap.square;
    // Positive rail (Red)
    canvas.drawLine(Offset(card.left + 30, cy - 40), Offset(cx, cy - 40), copperP);
    // Negative rail (Blue)
    canvas.drawLine(Offset(card.left + 30, cy + 40), Offset(cx, cy + 40), copperP);

    _drawCalloutBubble(canvas, Offset(cx - 30, cy - 40), Offset(cx - 30, cy - 65), 'Positive (+) Copper Track', '⚡', const Color(0xFFEF4444));
    _drawCalloutBubble(canvas, Offset(cx - 30, cy + 40), Offset(cx - 30, cy + 65), 'Negative (-) Copper Track', '⚡', const Color(0xFF0284C7));
  }

  void _drawLedMountingDiagram(Canvas canvas, Size size) {
    _drawCircuitTraceDiagram(canvas, size);
    final cx = size.width / 2;
    final cy = size.height / 2;

    // LED at center
    final ledCenter = Offset(cx, cy);
    canvas.drawCircle(ledCenter, 10, Paint()..color = const Color(0xFFEF4444));
    canvas.drawCircle(ledCenter, 4, Paint()..color = Colors.white);

    // Radiating light rays when animated
    if (animationProgress > 0.3) {
      final glowPaint = Paint()..color = const Color(0xFFFDE047).withValues(alpha: 0.6)..strokeWidth = 2.0;
      for (double a = 0; a < math.pi * 2; a += math.pi / 4) {
        canvas.drawLine(ledCenter + Offset(14 * math.cos(a), 14 * math.sin(a)), ledCenter + Offset(24 * math.cos(a), 24 * math.sin(a)), glowPaint);
      }
    }

    _drawCalloutBubble(canvas, ledCenter, Offset(cx + 45, cy), 'LED Illuminates 💡', '✨', const Color(0xFFEF4444));
  }

  // ══════════════════════════════════════════════════════════════════
  // DIAGRAM: REAR DRIVE AXLE & SLANTED CATCH TOOTH (Rubber Band Step 1)
  // EXACT SPEC: 12 cm Bamboo Skewer Axle (Ø 3 mm)
  // Shallow 0.5 mm center notch at 6.0 cm, with glued tooth slanted at 60°
  // Allows backward winding lock and clean forward slip-off release
  // ══════════════════════════════════════════════════════════════════
  void _drawAxleNotchDiagram(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final isDark = mode == InfographicMode.blueprint || mode == InfographicMode.physics;

    const axleLen = 250.0;
    const axleH = 10.0;
    final axleRect = Rect.fromCenter(center: Offset(cx, cy), width: axleLen, height: axleH);

    // Axle Body (Bamboo / Wood with grain)
    final axleColor = isDark ? const Color(0xFF1E3A5F) : const Color(0xFFFED7AA);
    final axleBorder = isDark ? const Color(0xFF38BDF8) : const Color(0xFFCA8A04);
    canvas.drawRRect(RRect.fromRectAndRadius(axleRect, const Radius.circular(5)), Paint()..color = axleColor);
    canvas.drawRRect(RRect.fromRectAndRadius(axleRect, const Radius.circular(5)), Paint()..color = axleBorder..strokeWidth = 1.5..style = PaintingStyle.stroke);

    // Bamboo grain lines
    final grainPaint = Paint()..color = axleBorder.withValues(alpha: 0.3)..strokeWidth = 1.0;
    canvas.drawLine(Offset(axleRect.left + 10, cy - 2), Offset(axleRect.right - 10, cy - 2), grainPaint);
    canvas.drawLine(Offset(axleRect.left + 15, cy + 2), Offset(axleRect.right - 15, cy + 2), grainPaint);

    if (stageIndex == 0) {
      // Stage 1: Measure & Carve 0.5mm Center Notch at 6.0 cm
      final rulerRect = Rect.fromLTWH(axleRect.left, axleRect.top - 26, axleLen, 18);
      _drawRealisticRuler(canvas, rulerRect, 12.0);

      // Centerline mark at 6.0 cm
      final pMark = Paint()..color = const Color(0xFFDC2626)..strokeWidth = 2.0;
      canvas.drawLine(Offset(cx, cy - 10), Offset(cx, cy + 10), pMark);

      // Craft knife blade carving notch
      final knifeTip = Offset(cx, cy - 5);
      final bladePath = Path()
        ..moveTo(knifeTip.dx, knifeTip.dy)
        ..lineTo(knifeTip.dx + 16, knifeTip.dy - 22)
        ..lineTo(knifeTip.dx + 22, knifeTip.dy - 22)
        ..lineTo(knifeTip.dx + 6, knifeTip.dy)
        ..close();
      canvas.drawPath(bladePath, Paint()..color = const Color(0xFFCBD5E1));
      canvas.drawPath(bladePath, Paint()..color = const Color(0xFF64748B)..strokeWidth = 1.0..style = PaintingStyle.stroke);

      _drawDimensionLine(canvas, Offset(axleRect.left, cy + 20), Offset(axleRect.right, cy + 20), '12.0 cm Bamboo Axle');
      _drawDimensionLine(canvas, Offset(axleRect.left, cy + 38), Offset(cx, cy + 38), '6.0 cm Center Notch');

      _drawCalloutBubble(canvas, Offset(cx, cy), Offset(cx - 35, cy - 45), 'Carve Shallow 0.5mm Notch', '🔪', const Color(0xFFDC2626));

    } else if (stageIndex == 1) {
      // Stage 2: Glue Slanted Catch Tooth (60° backward slant)
      final notchPath = Path()
        ..moveTo(cx - 4, cy - 5)
        ..lineTo(cx, cy - 1)
        ..lineTo(cx + 4, cy - 5)
        ..close();
      canvas.drawPath(notchPath, Paint()..color = isDark ? const Color(0xFF0B192C) : const Color(0xFFFDE68A));

      // Slanted Tooth (Toothpick sliver pointing backward/left at 60°)
      final toothPath = Path()
        ..moveTo(cx - 3, cy - 4)
        ..lineTo(cx - 14, cy - 22)
        ..lineTo(cx - 9, cy - 23)
        ..lineTo(cx + 1, cy - 4)
        ..close();
      canvas.drawPath(toothPath, Paint()..color = const Color(0xFFF59E0B));
      canvas.drawPath(toothPath, Paint()..color = const Color(0xFFB45309)..strokeWidth = 1.2..style = PaintingStyle.stroke);

      // Glue droplet at joint
      canvas.drawCircle(Offset(cx, cy - 4), 4.5, Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.6));
      canvas.drawCircle(Offset(cx, cy - 4), 4.5, Paint()..color = const Color(0xFF0284C7)..strokeWidth = 1.0..style = PaintingStyle.stroke);

      _drawCalloutBubble(canvas, Offset(cx - 10, cy - 20), Offset(cx - 50, cy - 50), 'Slanted Catch Tooth (60°)', '🪵', const Color(0xFFF59E0B));
      _drawCalloutBubble(canvas, Offset(cx, cy - 4), Offset(cx + 50, cy - 35), 'Reinforced Glue Bead', '💧', const Color(0xFF0284C7));

    } else {
      // Stage 3: Elastic Loop Hook & Zero-Jam Release Slip Test
      final toothPath = Path()
        ..moveTo(cx - 3, cy - 4)
        ..lineTo(cx - 14, cy - 22)
        ..lineTo(cx - 9, cy - 23)
        ..lineTo(cx + 1, cy - 4)
        ..close();
      canvas.drawPath(toothPath, Paint()..color = const Color(0xFFF59E0B));
      canvas.drawPath(toothPath, Paint()..color = const Color(0xFFB45309)..strokeWidth = 1.2..style = PaintingStyle.stroke);

      // Rubber band loop wrapping around tooth & axle
      final bandPaint = Paint()..color = const Color(0xFFEF4444)..strokeWidth = 3.5..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
      final tensionOffset = math.sin(animationProgress * math.pi * 2) * 8.0;

      // Elastic band loop stretched forward towards front chassis
      canvas.drawLine(Offset(cx - 10, cy - 18), Offset(cx - 90 + tensionOffset, cy - 18), bandPaint);
      canvas.drawLine(Offset(cx, cy - 1), Offset(cx - 90 + tensionOffset, cy + 4), bandPaint);

      // Loop over tooth
      canvas.drawArc(Rect.fromCenter(center: Offset(cx - 8, cy - 18), width: 12, height: 12), -math.pi / 2, math.pi, false, bandPaint);

      // Free-slip arrow when uncoiling
      final slipPaint = Paint()..color = const Color(0xFF10B981)..strokeWidth = 2.0;
      canvas.drawLine(Offset(cx - 12, cy - 26), Offset(cx - 24, cy - 36), slipPaint);

      _drawCalloutBubble(canvas, Offset(cx - 8, cy - 18), Offset(cx + 45, cy - 45), 'Hook Holds on Wind-Up', '🔒', const Color(0xFFEF4444));
      _drawCalloutBubble(canvas, Offset(cx - 18, cy - 30), Offset(cx - 65, cy - 50), 'Slips Free on Coasting', '🚀', const Color(0xFF10B981));
    }

    if (mode == InfographicMode.physics) {
      _drawForceVector(canvas, Offset(cx, cy), Offset(cx - 60, cy), const Color(0xFFEF4444), 'F_elastic Tension');
      _drawForceVector(canvas, Offset(cx, cy), Offset(cx, cy - 35), const Color(0xFF22C55E), 'τ Rotational Torque');
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // DIAGRAM: CHASSIS WINDOW & PARALLEL STRAW BEARINGS (Rubber Band Step 2)
  // EXACT SPEC: 18×8 cm Cardboard Chassis, 4×4 cm rear cutout window
  // Front 8 cm straw, split rear 2 cm straws flanking the window
  // ══════════════════════════════════════════════════════════════════
  void _drawChassisWindowDiagram(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final isDark = mode == InfographicMode.blueprint || mode == InfographicMode.physics;

    const chassisW = 240.0;
    const chassisH = 110.0;
    final chassisRect = Rect.fromCenter(center: Offset(cx, cy), width: chassisW, height: chassisH);

    // Chassis Cardboard base plate
    _drawCardboardTexture(canvas, chassisRect, horizontal: true);

    // Cutout Window at Rear (Left side: front, Right side: rear)
    // 4x4 cm window scaled: 55px wide x 55px high at rear right
    final windowRect = Rect.fromCenter(
      center: Offset(chassisRect.right - 45, cy),
      width: 55,
      height: 55,
    );

    if (stageIndex == 0) {
      // Stage 1: Mark & Measure 4x4 cm Window at Rear Edge
      final rulerRect = Rect.fromLTWH(chassisRect.right - 80, chassisRect.top - 24, 75, 18);
      _drawRealisticRuler(canvas, rulerRect, 5.0);

      // Window outline marked in dotted red
      final dotP = Paint()..color = const Color(0xFFDC2626)..strokeWidth = 1.8..style = PaintingStyle.stroke;
      canvas.drawRect(windowRect, dotP);

      // Marking Pencil
      _drawRealisticPencil(canvas, Offset(windowRect.left, windowRect.top), -0.7);

      _drawDimensionLine(canvas, Offset(windowRect.left, windowRect.bottom + 12), Offset(windowRect.right, windowRect.bottom + 12), '4.0 cm');
      _drawDimensionLine(canvas, Offset(windowRect.right + 12, windowRect.top), Offset(windowRect.right + 12, windowRect.bottom), '4.0 cm', isVertical: true);

      _drawCalloutBubble(canvas, Offset(windowRect.center.dx, windowRect.center.dy), Offset(windowRect.center.dx, cy - 50), '4×4 cm Winding Window', '📐', const Color(0xFFDC2626));

    } else if (stageIndex == 1) {
      // Stage 2: Cut Out Window with Craft Knife / Scissors
      final cutHole = Paint()..color = isDark ? const Color(0xFF0B192C) : const Color(0xFFE2E8F0);
      canvas.drawRect(windowRect, cutHole);
      canvas.drawRect(windowRect, Paint()..color = const Color(0xFFDC2626)..strokeWidth = 1.5..style = PaintingStyle.stroke);

      // Scissors cutting along edge
      final cutProg = animationProgress;
      final cutPos = Offset(windowRect.left, windowRect.top + (windowRect.height * cutProg));
      _drawRealisticScissors(canvas, cutPos, 0.25, scale: 0.85);

      _drawCalloutBubble(canvas, windowRect.center, Offset(windowRect.center.dx, cy - 45), 'Clearance Winding Port', '✂️', const Color(0xFFDC2626));

    } else {
      // Stage 3: Mount Straw Sleeves & Front Anchor Crossbar
      // Cutout window open
      canvas.drawRect(windowRect, Paint()..color = isDark ? const Color(0xFF0B192C) : const Color(0xFFE2E8F0));
      canvas.drawRect(windowRect, Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 1.2..style = PaintingStyle.stroke);

      // Front Straw Bearing (8 cm sleeve across front)
      final frontStraw = Rect.fromCenter(center: Offset(chassisRect.left + 22, cy), width: 14, height: chassisH - 12);
      canvas.drawRRect(RRect.fromRectAndRadius(frontStraw, const Radius.circular(3)), Paint()..color = const Color(0xFF38BDF8));
      canvas.drawRRect(RRect.fromRectAndRadius(frontStraw, const Radius.circular(3)), Paint()..color = const Color(0xFF0284C7)..strokeWidth = 1.2..style = PaintingStyle.stroke);

      // Rear Straw Bearings (Two split 2 cm sleeves flanking window)
      final topRearStraw = Rect.fromCenter(center: Offset(chassisRect.right - 22, chassisRect.top + 16), width: 14, height: 26);
      final botRearStraw = Rect.fromCenter(center: Offset(chassisRect.right - 22, chassisRect.bottom - 16), width: 14, height: 26);
      for (final r in [topRearStraw, botRearStraw]) {
        canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(3)), Paint()..color = const Color(0xFF38BDF8));
        canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(3)), Paint()..color = const Color(0xFF0284C7)..strokeWidth = 1.2..style = PaintingStyle.stroke);
      }

      // Front Anchor Crossbar Pin
      final anchorPin = Offset(chassisRect.left + 45, cy);
      canvas.drawCircle(anchorPin, 5, Paint()..color = const Color(0xFFF59E0B));
      canvas.drawCircle(anchorPin, 5, Paint()..color = const Color(0xFFB45309)..strokeWidth = 1.5..style = PaintingStyle.stroke);

      // Rear Axle spanning window
      final rearAxlePaint = Paint()..color = const Color(0xFFD97706)..strokeWidth = 4.0;
      canvas.drawLine(Offset(chassisRect.right - 22, chassisRect.top + 4), Offset(chassisRect.right - 22, chassisRect.bottom - 4), rearAxlePaint);

      // Parallel check line
      final pCheck = Paint()..color = const Color(0xFF10B981)..strokeWidth = 1.5;
      for (double x = chassisRect.left + 26; x < chassisRect.right - 26; x += 10) {
        canvas.drawLine(Offset(x, cy), Offset(x + 5, cy), pCheck);
      }

      _drawCalloutBubble(canvas, Offset(chassisRect.left + 22, cy - 30), Offset(chassisRect.left - 15, cy - 45), 'Front Straw 8cm', '🥤', const Color(0xFF0284C7));
      _drawCalloutBubble(canvas, anchorPin, Offset(anchorPin.dx, cy + 45), 'Front Anchor Crossbar', '📌', const Color(0xFFF59E0B));
      _drawCalloutBubble(canvas, Offset(chassisRect.right - 22, cy), Offset(chassisRect.right + 20, cy - 45), 'Drive Axle Spans Window', '🪵', const Color(0xFF10B981));
    }

    if (mode == InfographicMode.physics) {
      _drawForceVector(canvas, Offset(chassisRect.left + 22, cy), Offset(chassisRect.right - 22, cy), const Color(0xFF38BDF8), 'Strictly 90° Parallel Axes');
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // DIAGRAM: HIGH-TRACTION RUBBER TIRES (Rubber Band Step 3)
  // EXACT SPEC: 5.0 cm Cardboard Wheels with Wide Elastic Rubber Bands
  // Rubber tread increases friction from μ=0.18 to μ=0.85!
  // Donut spacers keep 1 mm clearance.
  // ══════════════════════════════════════════════════════════════════
  void _drawTractionTiresDiagram(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final isDark = mode == InfographicMode.blueprint || mode == InfographicMode.physics;

    final wheelCenter = Offset(cx - 65, cy);
    const wheelRadius = 45.0;

    if (stageIndex == 0) {
      // Stage 1: 5.0 cm Wheel Disc with Perimeter Tire Guideline
      canvas.drawCircle(wheelCenter, wheelRadius, Paint()..color = isDark ? const Color(0xFF1E3A5F) : const Color(0xFFFDE68A));
      canvas.drawCircle(wheelCenter, wheelRadius, Paint()..color = const Color(0xFFB45309)..strokeWidth = 2.0..style = PaintingStyle.stroke);

      // Flute lines across wheel
      final fPaint = Paint()..color = const Color(0xFFD97706).withValues(alpha: 0.25)..strokeWidth = 1.2;
      for (double y = wheelCenter.dy - 35; y <= wheelCenter.dy + 35; y += 10) {
        canvas.drawLine(Offset(wheelCenter.dx - 30, y), Offset(wheelCenter.dx + 30, y), fPaint);
      }

      // Center crosshair hole
      final crossP = Paint()..color = const Color(0xFFDC2626)..strokeWidth = 1.5;
      canvas.drawLine(Offset(wheelCenter.dx - 10, cy), Offset(wheelCenter.dx + 10, cy), crossP);
      canvas.drawLine(Offset(wheelCenter.dx, cy - 10), Offset(wheelCenter.dx, cy + 10), crossP);
      canvas.drawCircle(wheelCenter, 4, Paint()..color = Colors.white);
      canvas.drawCircle(wheelCenter, 4, Paint()..color = const Color(0xFFDC2626)..strokeWidth = 1.5..style = PaintingStyle.stroke);

      _drawDimensionLine(canvas, Offset(wheelCenter.dx - wheelRadius, cy + wheelRadius + 14), Offset(wheelCenter.dx + wheelRadius, cy + wheelRadius + 14), 'Ø 5.0 cm Wheel');

      // 4 wheels preview on right
      for (int i = 0; i < 4; i++) {
        final miniCenter = Offset(cx + 60 + (i % 2) * 45, cy - 25 + (i ~/ 2) * 50);
        canvas.drawCircle(miniCenter, 18, Paint()..color = const Color(0xFFFDE68A));
        canvas.drawCircle(miniCenter, 18, Paint()..color = const Color(0xFFB45309)..strokeWidth = 1.2..style = PaintingStyle.stroke);
        canvas.drawCircle(miniCenter, 2.5, Paint()..color = const Color(0xFFDC2626));
      }

      _drawCalloutBubble(canvas, wheelCenter, Offset(wheelCenter.dx, cy - 65), '4x Identical 5cm Discs', '⭕', const Color(0xFF0284C7));

    } else if (stageIndex == 1) {
      // Stage 2: Stretch Wide Rubber Band Around Wheel Rim
      canvas.drawCircle(wheelCenter, wheelRadius, Paint()..color = isDark ? const Color(0xFF1E3A5F) : const Color(0xFFFDE68A));

      // Outer Rubber Band Tire Rim
      const bandThickness = 6.0;
      final tirePaint = Paint()..color = const Color(0xFFEF4444)..strokeWidth = bandThickness..style = PaintingStyle.stroke;
      canvas.drawCircle(wheelCenter, wheelRadius - 1.0, tirePaint);

      // Grip tread bumps on outer perimeter
      final treadPaint = Paint()..color = const Color(0xFFB91C1C)..strokeWidth = 2.0;
      for (double a = 0; a < math.pi * 2; a += math.pi / 12) {
        final p1 = Offset(wheelCenter.dx + (wheelRadius - 1) * math.cos(a), wheelCenter.dy + (wheelRadius - 1) * math.sin(a));
        final p2 = Offset(wheelCenter.dx + (wheelRadius + 3) * math.cos(a), wheelCenter.dy + (wheelRadius + 3) * math.sin(a));
        canvas.drawLine(p1, p2, treadPaint);
      }

      // Stretch indicators
      final stretchArrow = Paint()..color = const Color(0xFF0284C7)..strokeWidth = 2.0;
      canvas.drawLine(Offset(wheelCenter.dx - wheelRadius - 15, cy), Offset(wheelCenter.dx - wheelRadius, cy), stretchArrow);
      canvas.drawLine(Offset(wheelCenter.dx + wheelRadius + 15, cy), Offset(wheelCenter.dx + wheelRadius, cy), stretchArrow);

      _drawCalloutBubble(canvas, Offset(wheelCenter.dx, wheelCenter.dy - wheelRadius), Offset(wheelCenter.dx, cy - 65), 'Wide Elastic Band Stretched Flat', '🛞', const Color(0xFFEF4444));
      _drawCalloutBubble(canvas, Offset(cx + 60, cy), Offset(cx + 60, cy - 45), 'Snug Rim Fit, Zero Twists', '✅', const Color(0xFF10B981));

    } else {
      // Stage 3: Exploded Assembly View (Axle + Straw + Donut Washer + Wheel + Tire)
      final axY = cy;

      // 1. Straw Bearing
      final strawRect = Rect.fromCenter(center: Offset(cx - 30, axY), width: 80, height: 18);
      canvas.drawRRect(RRect.fromRectAndRadius(strawRect, const Radius.circular(4)), Paint()..color = const Color(0xFF38BDF8));

      // 2. Bamboo Axle through straw
      final axleRect = Rect.fromCenter(center: Offset(cx + 10, axY), width: 220, height: 7);
      canvas.drawRRect(RRect.fromRectAndRadius(axleRect, const Radius.circular(3)), Paint()..color = const Color(0xFFFED7AA));

      // 3. Donut Washer Spacer (1mm gap)
      final washerRect = Rect.fromCenter(center: Offset(cx + 22, axY), width: 10, height: 32);
      canvas.drawRRect(RRect.fromRectAndRadius(washerRect, const Radius.circular(3)), Paint()..color = const Color(0xFFFDE68A));
      canvas.drawRRect(RRect.fromRectAndRadius(washerRect, const Radius.circular(3)), Paint()..color = const Color(0xFFB45309)..strokeWidth = 1.2..style = PaintingStyle.stroke);

      // 4. Cardboard Wheel with Tire
      final wheelSideRect = Rect.fromCenter(center: Offset(cx + 52, axY), width: 32, height: 75);
      canvas.drawRRect(RRect.fromRectAndRadius(wheelSideRect, const Radius.circular(5)), Paint()..color = const Color(0xFFFDE68A));
      // Red rubber tire wrapped around perimeter
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(wheelSideRect.left, wheelSideRect.top, wheelSideRect.width, 6), const Radius.circular(2)), Paint()..color = const Color(0xFFEF4444));
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(wheelSideRect.left, wheelSideRect.bottom - 6, wheelSideRect.width, 6), const Radius.circular(2)), Paint()..color = const Color(0xFFEF4444));

      // 5. Glue stop collar at axle tip
      canvas.drawCircle(Offset(cx + 72, axY), 5, Paint()..color = const Color(0xFFDC2626));

      // Dimension of 1mm clearance
      _drawDimensionLine(canvas, Offset(cx + 10, axY - 22), Offset(cx + 22, axY - 22), '1mm Gap');

      _drawCalloutBubble(canvas, Offset(cx - 30, axY), Offset(cx - 30, axY - 45), 'Straw Bearing', '🥤', const Color(0xFF0284C7));
      _drawCalloutBubble(canvas, Offset(cx + 22, axY), Offset(cx + 22, axY + 45), 'Donut Spacer', '🍩', const Color(0xFFF59E0B));
      _drawCalloutBubble(canvas, Offset(cx + 52, axY), Offset(cx + 65, axY - 45), 'Rubber-Tired Wheel', '🛞', const Color(0xFFEF4444));
    }

    if (mode == InfographicMode.physics) {
      _drawForceVector(canvas, Offset(wheelCenter.dx, wheelCenter.dy + wheelRadius), Offset(wheelCenter.dx + 45, wheelCenter.dy + wheelRadius), const Color(0xFF22C55E), 'Grip Traction μ=0.85');
      _drawForceVector(canvas, Offset(wheelCenter.dx, wheelCenter.dy + wheelRadius), Offset(wheelCenter.dx, wheelCenter.dy + wheelRadius - 30), const Color(0xFF38BDF8), 'Normal Force N');
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // DIAGRAM: HOOK, WIND & SPRINT LAUNCH (Rubber Band Step 4)
  // EXACT SPEC: Rubber band anchored to front pin, rear loop on axle tooth.
  // Wind 6-8 turns backward -> Release -> Sprint launch 4+ meters!
  // ══════════════════════════════════════════════════════════════════
  void _drawRubberLaunchDiagram(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final floorY = size.height - 35.0;

    if (stageIndex == 0) {
      // Stage 1: Hook Rubber Band to Front Anchor and Rear Axle Tooth
      final cartX = cx;
      final cartY = floorY - 30;

      // Chassis profile
      final chassisRect = Rect.fromCenter(center: Offset(cartX, cartY), width: 170, height: 20);
      _drawCardboardTexture(canvas, chassisRect, horizontal: true);

      // Wheels with rubber tires
      final frontWheel = Offset(cartX - 60, floorY - 18);
      final rearWheel = Offset(cartX + 60, floorY - 18);
      for (final wCenter in [frontWheel, rearWheel]) {
        canvas.drawCircle(wCenter, 18, Paint()..color = const Color(0xFFFDE68A));
        canvas.drawCircle(wCenter, 18, Paint()..color = const Color(0xFFEF4444)..style = PaintingStyle.stroke..strokeWidth = 3.5);
        canvas.drawCircle(wCenter, 3.5, Paint()..color = const Color(0xFFB45309));
      }

      // Front anchor pin & rear catch tooth
      final frontPin = Offset(cartX - 45, cartY - 5);
      final rearTooth = Offset(cartX + 50, cartY - 5);
      canvas.drawCircle(frontPin, 4, Paint()..color = const Color(0xFFF59E0B));
      canvas.drawCircle(rearTooth, 4, Paint()..color = const Color(0xFFF59E0B));

      // Relaxed rubber band stretched between anchor and tooth
      final bandPaint = Paint()..color = const Color(0xFFEF4444)..strokeWidth = 3.5..strokeCap = StrokeCap.round;
      canvas.drawLine(frontPin, rearTooth, bandPaint);

      // Floor line
      canvas.drawLine(Offset(20, floorY), Offset(size.width - 20, floorY), Paint()..color = const Color(0xFF64748B)..strokeWidth = 2.0);

      _drawCalloutBubble(canvas, frontPin, Offset(frontPin.dx - 25, cartY - 45), 'Front Anchor Pin', '📌', const Color(0xFFF59E0B));
      _drawCalloutBubble(canvas, rearTooth, Offset(rearTooth.dx + 25, cartY - 45), 'Rear Axle Tooth Hook', '🪵', const Color(0xFFEF4444));

    } else if (stageIndex == 1) {
      // Stage 2: Wind Rear Wheels Backward 6-8 Turns (Energy Stored)
      final cartX = cx;
      final cartY = floorY - 30;

      final chassisRect = Rect.fromCenter(center: Offset(cartX, cartY), width: 170, height: 20);
      _drawCardboardTexture(canvas, chassisRect, horizontal: true);

      final frontWheel = Offset(cartX - 60, floorY - 18);
      final rearWheel = Offset(cartX + 60, floorY - 18);
      for (final wCenter in [frontWheel, rearWheel]) {
        canvas.drawCircle(wCenter, 18, Paint()..color = const Color(0xFFFDE68A));
        canvas.drawCircle(wCenter, 18, Paint()..color = const Color(0xFFEF4444)..style = PaintingStyle.stroke..strokeWidth = 3.5);
        canvas.drawCircle(wCenter, 3.5, Paint()..color = const Color(0xFFB45309));
      }

      // Backward rotation arrow on rear wheel
      final arcPaint = Paint()..color = const Color(0xFF0284C7)..strokeWidth = 2.5..style = PaintingStyle.stroke;
      canvas.drawArc(Rect.fromCenter(center: rearWheel, width: 48, height: 48), math.pi * 0.2, math.pi * 1.2, false, arcPaint);

      // Wound Rubber Band coiled tightly around rear axle
      final frontPin = Offset(cartX - 45, cartY - 5);
      final rearAxle = Offset(cartX + 50, cartY - 5);

      // Coiled loops around axle
      final coilPaint = Paint()..color = const Color(0xFFDC2626)..strokeWidth = 3.0;
      for (int c = -6; c <= 6; c += 3) {
        canvas.drawOval(Rect.fromCenter(center: rearAxle + Offset(c.toDouble(), 0), width: 8, height: 16), coilPaint);
      }
      // Tight stretched band to front
      canvas.drawLine(frontPin, rearAxle - const Offset(6, 0), Paint()..color = const Color(0xFFDC2626)..strokeWidth = 4.0);

      // Floor line
      canvas.drawLine(Offset(20, floorY), Offset(size.width - 20, floorY), Paint()..color = const Color(0xFF64748B)..strokeWidth = 2.0);

      _drawCalloutBubble(canvas, rearWheel, Offset(rearWheel.dx, cartY - 55), 'Roll Backward 6-8 Turns', '🔄', const Color(0xFF0284C7));
      _drawCalloutBubble(canvas, rearAxle, Offset(cx, cartY - 45), 'Elastic Potential Energy Stored!', '⚡', const Color(0xFFDC2626));

    } else {
      // Stage 3: RELEASE! High-Speed Sprint Launch (4+ Meters)
      final sprintDist = animationProgress * (size.width - 180.0);
      final cartX = 80.0 + sprintDist;
      final cartY = floorY - 30;

      // Speed trail behind racer
      final trailP = Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.35)..strokeWidth = 2.0;
      canvas.drawLine(Offset(20, cartY - 8), Offset(cartX - 70, cartY - 8), trailP);
      canvas.drawLine(Offset(20, cartY + 6), Offset(cartX - 70, cartY + 6), trailP);

      // Chassis
      final chassisRect = Rect.fromCenter(center: Offset(cartX, cartY), width: 150, height: 18);
      _drawCardboardTexture(canvas, chassisRect, horizontal: true);

      // Wheels spinning rapidly
      final frontWheel = Offset(cartX - 50, floorY - 18);
      final rearWheel = Offset(cartX + 50, floorY - 18);
      for (final wCenter in [frontWheel, rearWheel]) {
        canvas.drawCircle(wCenter, 18, Paint()..color = const Color(0xFFFDE68A));
        canvas.drawCircle(wCenter, 18, Paint()..color = const Color(0xFFEF4444)..style = PaintingStyle.stroke..strokeWidth = 3.5);
        canvas.drawCircle(wCenter, 3.5, Paint()..color = const Color(0xFFB45309));
      }

      // Band slips free from tooth and relaxes
      canvas.drawCircle(Offset(cartX + 40, cartY - 5), 4, Paint()..color = const Color(0xFF10B981));

      // Floor runway
      canvas.drawLine(Offset(20, floorY), Offset(size.width - 20, floorY), Paint()..color = const Color(0xFF64748B)..strokeWidth = 2.0);
      _drawDimensionLine(canvas, Offset(20, floorY + 14), Offset(size.width - 20, floorY + 14), '4.0+ Meter Sprint Run');

      _drawCalloutBubble(canvas, Offset(cartX, cartY), Offset(cartX, cartY - 45), 'Sprinting Forward! 🚀', '🏎️', const Color(0xFF10B981));
    }

    if (mode == InfographicMode.physics) {
      final sprintDist = animationProgress * (size.width - 180.0);
      final cartX = 80.0 + sprintDist;
      _drawForceVector(canvas, Offset(cartX + 50, floorY - 30), Offset(cartX + 105, floorY - 30), const Color(0xFF22C55E), 'Forward Thrust F_thrust');
      _drawForceVector(canvas, Offset(cartX + 50, floorY - 18), Offset(cartX + 30, floorY - 45), const Color(0xFFEF4444), 'Torque τ = r × F');
    }
  }

  void _drawGenericStemBlueprint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final isDark = mode == InfographicMode.blueprint || mode == InfographicMode.physics;

    final frame = Rect.fromCenter(center: Offset(cx, cy), width: size.width - 60, height: size.height - 40);
    canvas.drawRRect(RRect.fromRectAndRadius(frame, const Radius.circular(8)), Paint()..color = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC));
    canvas.drawRRect(RRect.fromRectAndRadius(frame, const Radius.circular(8)), Paint()..color = const Color(0xFF0284C7)..strokeWidth = 1.5..style = PaintingStyle.stroke);

    final crossP = Paint()..color = const Color(0xFF0284C7).withValues(alpha: 0.4)..strokeWidth = 1.0;
    canvas.drawLine(Offset(frame.left, cy), Offset(frame.right, cy), crossP);
    canvas.drawLine(Offset(cx, frame.top), Offset(cx, frame.bottom), crossP);

    _drawCalloutBubble(canvas, Offset(cx, cy), Offset(cx, cy - 35), 'MakerQuest STEM Schematic', '📐', const Color(0xFF0284C7));
  }

  @override
  bool shouldRepaint(covariant StepInfographicPainter oldDelegate) {
    return oldDelegate.visualType != visualType ||
        oldDelegate.mode != mode ||
        oldDelegate.stageIndex != stageIndex ||
        oldDelegate.highlightedPart != highlightedPart ||
        oldDelegate.animationProgress != animationProgress;
  }
}
