import 'package:flutter/material.dart';

class PadWidget extends StatelessWidget {
  final int index;
  final bool isEffect; // 노트 타이밍에 패드가 변하는가
  final bool isEffectActive; // 노트가 활성화되어 있는가
  final bool isPressed; // 사용자가 방금 터치했는가
  final VoidCallback onTap;

  const PadWidget({
    super.key,
    required this.index,
    required this.isEffect,
    required this.isEffectActive,
    required this.isPressed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isEffectActive ? Colors.blue : Colors.grey.shade800,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'PAD ${index + 1}',
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