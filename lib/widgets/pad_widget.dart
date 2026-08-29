import 'dart:async';

import 'package:dungtak/constants/game_constants.dart';
import 'package:flutter/material.dart';

class PadWidget extends StatefulWidget {
  final int index;
  final bool isEffectActive; // 현재 노트가 파란색으로 활성화되어 있는지
  final bool isEffect; // 노트 타격 순간의 이펙트
  final VoidCallback onTap;
  final Color? activeColor;

  const PadWidget({
    super.key,
    required this.index,
    required this.isEffectActive,
    required this.isEffect,
    required this.onTap,
    this.activeColor,
  });

  @override
  State<PadWidget> createState() => _PadWidgetState();
}

class _PadWidgetState extends State<PadWidget> {
  Timer? _pressTimer;

  @override
  void dispose() {
    _pressTimer?.cancel();
    super.dispose();
  }

  // Build
  @override
  Widget build(BuildContext context,) {
    final padColor = widget.activeColor ?? GameConstants.noteColorActive;

    return Expanded(
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: widget.isEffectActive ? padColor : const Color(0xFF202020),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isEffectActive ? padColor : Colors.white24,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              "PAD ${widget.index + 1}",
              style: TextStyle(
                color: widget.isEffectActive ? Colors.white : Colors.white54,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

}