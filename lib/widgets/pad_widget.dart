import 'dart:async';

import 'package:dungtak/constants/constants.dart';
import 'package:flutter/material.dart';

class PadWidget extends StatefulWidget {
  final int index;
  final bool isEffectActive; // 현재 노트가 활성화되어 있는지
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
  bool _isPressed = false;

  @override
  void dispose() {
    _pressTimer?.cancel();
    super.dispose();
  }

  // Pad Press
  void _onTapDown() {
    setState(() {_isPressed = true;});
  }

  void _onTapUp() {
    _pressTimer?.cancel();
    _pressTimer = Timer(const Duration(milliseconds: 80), () {
      if (!mounted) return;
      setState(() {_isPressed = false;});
    });
    widget.onTap();
  }

  // Build
  @override
  Widget build(BuildContext context) {
    final padColor = widget.activeColor ?? Constants.noteColorActive;

    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _onTapDown(),
        onTapUp: (_) => _onTapUp(),
        onTapCancel: () {
          setState(() {_isPressed = false;});
        },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 50),
          scale: _isPressed ? 0.96 : 1.0,
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: padColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: padColor, width: 2),
              boxShadow: widget.isEffectActive
                ? [BoxShadow(color: padColor.withValues(alpha: 0.6), blurRadius: _isPressed ? 20 : 10, spreadRadius: _isPressed ? 2 : 0)]
                : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    "PAD",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_isPressed) ... [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

}
