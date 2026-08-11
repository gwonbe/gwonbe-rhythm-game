import 'package:flutter/material.dart';

class PadWidget extends StatefulWidget {
  final int index;
  final bool isEffectActive;
  final bool isEffect;
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

  void _press() {
    setState(() {
      _pressed = true;
    });

    widget.onTap();

    Future.delayed(
      const Duration(milliseconds: 100), () {
        if (!mounted) return;
        setState(() {
          _pressed = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) {
          _press();
        },
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _pressed ? Colors.blue[600] : widget.isEffectActive ? Colors.blue : Colors.grey.shade800,
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