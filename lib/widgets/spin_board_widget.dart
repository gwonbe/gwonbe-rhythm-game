import 'dart:math' as math;

import 'package:flutter/material.dart';

class SpinBoardWidget extends StatelessWidget {
  final double rotationAngle;
  final int padCount;
  final Set<int> activePads; // 활성화된 패드
  final Color Function(int pad) getPadColor; // 패드별 색상
  final void Function(int pad) onPadPressed; // 패드 터치

  const SpinBoardWidget({
    super.key,
    this.rotationAngle = 0.0,
    this.padCount = 8,
    required this.activePads,
    required this.getPadColor,
    required this.onPadPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) {
          final pad = _getPadFromPosition(details.localPosition, context.size);
          if (pad == null) return;
          onPadPressed(pad);
        },
        child: CustomPaint(
          painter: _SpinBoardPainter(
            rotationAngle: rotationAngle,
            padCount: padCount,
            activePads: activePads,
            getPadColor: getPadColor,
          ),
        ),
      ),
    );
  }

  int? _getPadFromPosition(Offset position, Size? size) {
    if (size == null) return null;

    final center = Offset(size.width / 2, size.height / 2);
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final radius = math.min(size.width, size.height) / 2;

    // 원판 바깥을 누른 경우
    if (distance > radius) return null;

    // 중심을 누른 경우
    if (distance < radius * 0.18) return null;

    double touchAngle = math.atan2(dy, dx);
    touchAngle += math.pi / 2;
    touchAngle -= rotationAngle;
    touchAngle %= math.pi * 2;
    if (touchAngle < 0) touchAngle += math.pi * 2;
    final sectorAngle = (math.pi * 2) / padCount;
    final pad = (touchAngle / sectorAngle).floor();

    return pad.clamp(0, padCount - 1);
  }
}

class _SpinBoardPainter extends CustomPainter {
  final double rotationAngle;
  final int padCount;
  final Set<int> activePads;
  final Color Function(int pad) getPadColor;

  _SpinBoardPainter({
    required this.rotationAngle,
    required this.padCount,
    required this.activePads,
    required this.getPadColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final outerRadius = radius * 0.95;
    final innerRadius = radius * 0.18;
    final sectorAngle = (math.pi * 2) / padCount;

    canvas.save(); // 회전
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);

    // 배경 원판
    final boardPaint = Paint();
    boardPaint.color = const Color(0xFF111111);
    boardPaint.style = PaintingStyle.fill;
    canvas.drawCircle(center, outerRadius, boardPaint);

    // 패드
    for (int i = 0; i < padCount; i++) {
      _drawPad(
        canvas: canvas,
        center: center,
        outerRadius: outerRadius,
        innerRadius: innerRadius,
        startAngle: -math.pi / 2 + i * sectorAngle,
        sweepAngle: sectorAngle,
        pad: i,
      );
    }

    // 중심 원
    final centerPaint = Paint();
    centerPaint.color = const Color(0xFF080808);
    centerPaint.style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, centerPaint);

    // 중심 테두리
    final centerBorderPaint = Paint();
    centerBorderPaint.color = Colors.white24;
    centerBorderPaint.style = PaintingStyle.stroke;
    centerBorderPaint.strokeWidth = 2;
    canvas.drawCircle(center, innerRadius, centerBorderPaint);
    canvas.restore();

    // 바깥 테두리는 회전하지 않도록 별도로 그림
    final borderPaint = Paint();
    borderPaint.color = Colors.white24;
    borderPaint.style = PaintingStyle.stroke;
    borderPaint.strokeWidth = 2;
    canvas.drawCircle(center, outerRadius, borderPaint);
  }

  void _drawPad({required Canvas canvas, required Offset center, required double outerRadius, required double innerRadius, required double startAngle, required double sweepAngle, required int pad}) {
    final rect = Rect.fromCircle(center: center, radius: outerRadius);
    final path = Path();
    final outerStart = Offset(center.dx + outerRadius * math.cos(startAngle), center.dy + outerRadius * math.sin(startAngle));
    final innerStart = Offset(center.dx + innerRadius * math.cos(startAngle), center.dy + innerRadius * math.sin(startAngle));
    final innerEnd = Offset(center.dx + innerRadius * math.cos(startAngle + sweepAngle), center.dy + innerRadius * math.sin(startAngle + sweepAngle));

    path.moveTo(innerStart.dx, innerStart.dy);
    path.lineTo(outerStart.dx, outerStart.dy);
    path.arcTo(rect, startAngle, sweepAngle, false);
    path.lineTo(innerEnd.dx, innerEnd.dy);
    path.arcTo(Rect.fromCircle(center: center, radius: innerRadius,), startAngle + sweepAngle, -sweepAngle, false);
    path.close();

    final isActive = activePads.contains(pad);
    final paint = Paint();
    paint.color = isActive ? getPadColor(pad) : const Color(0xFF202020);
    paint.style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    // 패드 구분선
    final borderPaint = Paint();
    borderPaint.color = Colors.white24;
    borderPaint.style = PaintingStyle.stroke;
    borderPaint.strokeWidth = 2;

    canvas.drawPath(path, borderPaint);

    // 패드 번호
    _drawPadNumber(canvas, center, innerRadius, outerRadius, startAngle, sweepAngle, pad);
  }

  void _drawPadNumber(Canvas canvas, Offset center, double innerRadius, double outerRadius, double startAngle, double sweepAngle, int pad) {
    final middleAngle = startAngle + sweepAngle / 2;
    final textRadius = innerRadius + (outerRadius - innerRadius) * 0.55;
    final position = Offset(center.dx + textRadius * math.cos(middleAngle), center.dy + textRadius * math.sin(middleAngle));

    final textPainter = TextPainter(
      text: TextSpan(
        text: pad.toString(),
        style: const TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset(position.dx - textPainter.width / 2, position.dy - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _SpinBoardPainter oldDelegate) {
    return oldDelegate.rotationAngle != rotationAngle || oldDelegate.padCount != padCount || oldDelegate.activePads != activePads;
  }

}