import 'dart:async';

import 'package:flutter/material.dart';

class PadWidget extends StatefulWidget {
  final int index;
  final bool isEffectActive; // 현재 노트가 파란색으로 활성화되어 있는지
  final bool isEffect; // 노트 타격 순간의 이펙트
  final VoidCallback onTap;

  const PadWidget({
    super.key,
    required this.index,
    required this.isEffectActive,
    required this.isEffect,
    required this.onTap,
  });

  @override
  State<PadWidget> createState() => _PadWidgetState();
}

class _PadWidgetState extends State<PadWidget> {
  bool _pressed = false;
  Timer? _pressTimer;

  // Pointer Down
  void _press() {
    _pressTimer?.cancel();
    setState(() { _pressed = true; });
    widget.onTap(); // 판정은 즉시 실행

    // 시각적인 눌림 효과만 100ms 유지
    _pressTimer = Timer(
      const Duration(milliseconds: 100), () {
        if (!mounted) return;
        setState(() {
          _pressed = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _pressTimer?.cancel();
    super.dispose();
  }

  // Build

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;

    if (_pressed) {
      backgroundColor = Colors.blue.shade600;
    } else if (widget.isEffectActive) {
      backgroundColor = Colors.blue;
    } else {
      backgroundColor = Colors.grey.shade800;
    }

    return Expanded(
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) {
          _press();
        },
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'PAD ${widget.index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}