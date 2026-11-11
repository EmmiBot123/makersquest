// Frosted Cloud Light Glassmorphic Design System & Ambient Background Animation
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

bool get _isRunningTests =>
    WidgetsBinding.instance.runtimeType.toString().contains('Test');

/// Full-bleed Frosted Cloud Light background with gently drifting pastel orbs,
/// translucent bubble rings, and subtle floating STEM sparkles.
class FrostedCloudBackdrop extends StatefulWidget {
  final Widget child;
  final Color? accentColor;

  const FrostedCloudBackdrop({
    super.key,
    required this.child,
    this.accentColor,
  });

  @override
  State<FrostedCloudBackdrop> createState() => _FrostedCloudBackdropState();
}

class _FrostedCloudBackdropState extends State<FrostedCloudBackdrop>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    );
    if (_isRunningTests) {
      _controller.value = 0.28;
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _FrostedCloudBackdropPainter(
                    progress: _controller.value,
                    accentColor: widget.accentColor,
                  ),
                );
              },
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _FrostedCloudBackdropPainter extends CustomPainter {
  final double progress;
  final Color? accentColor;

  const _FrostedCloudBackdropPainter({
    required this.progress,
    this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    final theta = progress * 2 * math.pi;

    // 1. Airy Frosted Studio Base Gradient
    final basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFEAF2FF),
          Color(0xFFF6F4FF),
          Color(0xFFECFEFF),
          Color(0xFFFFF7ED),
        ],
        stops: [0.0, 0.35, 0.72, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), basePaint);

    // 2. Seamless Drifting Pastel Cloud Orbs (soft radial gradients behind glass cards)
    final accent = accentColor ?? const Color(0xFF6366F1);
    final baseSpan = math.max(w, h);

    _drawCloudOrb(
      canvas,
      center: Offset(
        w * (0.16 + 0.08 * math.sin(theta)),
        h * (0.18 + 0.07 * math.cos(theta)),
      ),
      radius: baseSpan * (0.36 + 0.03 * math.sin(theta * 2)),
      color: const Color(0xFF38BDF8),
      peakAlpha: 0.22,
    );

    _drawCloudOrb(
      canvas,
      center: Offset(
        w * (0.84 + 0.07 * math.cos(theta + 0.8)),
        h * (0.20 + 0.08 * math.sin(theta)),
      ),
      radius: baseSpan * (0.38 + 0.03 * math.cos(theta * 2)),
      color: accent,
      peakAlpha: 0.19,
    );

    _drawCloudOrb(
      canvas,
      center: Offset(
        w * (0.24 + 0.09 * math.cos(theta + 2.1)),
        h * (0.80 + 0.07 * math.sin(theta + 1.4)),
      ),
      radius: baseSpan * (0.34 + 0.025 * math.sin(theta)),
      color: const Color(0xFF34D399),
      peakAlpha: 0.17,
    );

    _drawCloudOrb(
      canvas,
      center: Offset(
        w * (0.80 + 0.08 * math.sin(theta + 2.6)),
        h * (0.82 + 0.06 * math.cos(theta + 0.5)),
      ),
      radius: baseSpan * (0.30 + 0.025 * math.cos(theta)),
      color: const Color(0xFFFBBF24),
      peakAlpha: 0.16,
    );

    // 3. Subtle Frosted Blueprint Grid Wash
    final gridPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.028)
      ..strokeWidth = 1;
    const gridSpacing = 44.0;
    for (double x = 0; x < w; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y < h; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // 4. Gently Bobbing Frosted Bokeh Rings & Twinkling 4-Point STEM Sparkles
    const particles = <({double x, double y, double r, double phase, bool isSpark})>[
      (x: 0.09, y: 0.24, r: 10, phase: 0.2, isSpark: true),
      (x: 0.22, y: 0.12, r: 22, phase: 1.4, isSpark: false),
      (x: 0.48, y: 0.14, r: 8, phase: 2.3, isSpark: true),
      (x: 0.72, y: 0.11, r: 26, phase: 3.1, isSpark: false),
      (x: 0.91, y: 0.34, r: 11, phase: 0.9, isSpark: true),
      (x: 0.12, y: 0.62, r: 24, phase: 4.0, isSpark: false),
      (x: 0.35, y: 0.86, r: 9, phase: 2.7, isSpark: true),
      (x: 0.63, y: 0.76, r: 28, phase: 1.9, isSpark: false),
      (x: 0.88, y: 0.68, r: 10, phase: 5.0, isSpark: true),
      (x: 0.54, y: 0.52, r: 18, phase: 3.8, isSpark: false),
    ];

    for (final p in particles) {
      final px = w * p.x + math.sin(theta + p.phase) * 14;
      final py = h * p.y + math.cos(theta + p.phase) * 12;
      final shimmer = 0.55 + 0.45 * math.sin(theta * 2 + p.phase);

      if (p.isSpark) {
        _drawSparkleDiamond(
          canvas,
          Offset(px, py),
          p.r * (0.85 + 0.2 * shimmer),
          Colors.white.withValues(alpha: 0.45 + 0.35 * shimmer),
        );
      } else {
        // Frosted bubble ring
        canvas.drawCircle(
          Offset(px, py),
          p.r,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.24 * shimmer)
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          Offset(px, py),
          p.r,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.65 * shimmer)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      }
    }
  }

  void _drawCloudOrb(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
    required double peakAlpha,
  }) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: peakAlpha),
          color.withValues(alpha: peakAlpha * 0.42),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.52, 1.0],
      ).createShader(rect);
    canvas.drawCircle(center, radius, paint);
  }

  void _drawSparkleDiamond(Canvas canvas, Offset c, double r, Color color) {
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _FrostedCloudBackdropPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accentColor != accentColor;
  }
}

/// Reusable frosted glassmorphic surface with BackdropFilter blur, specular highlight
/// rim border, and soft pastel/obsidian depth shadow.
class GlassSurface extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blurSigma;
  final bool isDark;
  final Color? tintColor;
  final Color? borderColor;
  final double borderWidth;
  final double topOpacity;
  final double bottomOpacity;
  final List<BoxShadow>? shadows;

  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.blurSigma = 14,
    this.isDark = false,
    this.tintColor,
    this.borderColor,
    this.borderWidth = 1.4,
    this.topOpacity = 0.80,
    this.bottomOpacity = 0.58,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final effectiveTint = tintColor ?? AppColors.primary;

    final Gradient gradient = isDark
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F172A).withValues(alpha: 0.88),
              const Color(0xFF1E293B).withValues(alpha: 0.78),
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(Colors.white, effectiveTint, 0.04)!
                  .withValues(alpha: topOpacity),
              Color.lerp(Colors.white, effectiveTint, 0.07)!
                  .withValues(alpha: bottomOpacity),
            ],
          );

    final Color resolvedBorder = borderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.20)
            : Colors.white.withValues(alpha: 0.88));

    final List<BoxShadow> resolvedShadows = shadows ??
        [
          BoxShadow(
            color: (isDark ? const Color(0xFF0F172A) : effectiveTint)
                .withValues(alpha: isDark ? 0.20 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          if (!isDark)
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.55),
              blurRadius: 2,
              offset: const Offset(-1, -1),
            ),
        ];

    Widget surface = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: radius,
            border: Border.all(color: resolvedBorder, width: borderWidth),
          ),
          child: child,
        ),
      ),
    );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: resolvedShadows,
      ),
      child: surface,
    );
  }
}

/// Rectangular frosted glass bar (for AppBar, NavigationRail, NavigationBar, Top Nav).
class GlassChromeBar extends StatelessWidget {
  final Widget child;
  final Border? border;
  final double blurSigma;
  final EdgeInsetsGeometry? padding;
  final double opacity;

  const GlassChromeBar({
    super.key,
    required this.child,
    this.border,
    this.blurSigma = 14,
    this.padding,
    this.opacity = 0.74,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: opacity + 0.06),
                const Color(0xFFF8FAFF).withValues(alpha: opacity),
              ],
            ),
            border: border ??
                Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.85),
                    width: 1.2,
                  ),
                ),
          ),
          child: child,
        ),
      ),
    );
  }
}
