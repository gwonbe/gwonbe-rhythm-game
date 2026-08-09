import 'package:flutter/material.dart';

class PadWidget extends StatelessWidget {
  final int index;
  final bool isEffect;
  final bool isEffectActive;
  final VoidCallback onTap;

  const PadWidget({
    super.key,
    required this.index,
    required this.isEffect,
    required this.isEffectActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 50),
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