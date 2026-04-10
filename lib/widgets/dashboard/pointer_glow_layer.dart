import 'package:flutter/material.dart';

/// Radial highlight following pointer — visual parity with React [PointerGlow].
class PointerGlowLayer extends StatefulWidget {
  const PointerGlowLayer({super.key});

  @override
  State<PointerGlowLayer> createState() => _PointerGlowLayerState();
}

class _PointerGlowLayerState extends State<PointerGlowLayer> {
  Offset _fraction = const Offset(0.5, 0.5);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: MouseRegion(
        onHover: (e) {
          final box = context.findRenderObject() as RenderBox?;
          if (box == null || !box.hasSize) return;
          final local = box.globalToLocal(e.position);
          setState(() {
            _fraction = Offset(
              (local.dx / box.size.width).clamp(0.0, 1.0),
              (local.dy / box.size.height).clamp(0.0, 1.0),
            );
          });
        },
        child: CustomPaint(
          painter: _GlowPainter(fraction: _fraction),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  _GlowPainter({required this.fraction});

  final Offset fraction;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(fraction.dx * size.width, fraction.dy * size.height);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.06),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
        radius: size.shortestSide * 0.45,
      ).createShader(Rect.fromCircle(center: center, radius: size.shortestSide * 0.5));
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _GlowPainter oldDelegate) {
    return oldDelegate.fraction != fraction;
  }
}
