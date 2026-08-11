import 'package:dungtak/engine/score_manager.dart';

import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final ScoreManager scoreManager;

  const ResultScreen({
    super.key,
    required this.scoreManager,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "RESULT",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              Text(
                scoreManager.score.toStringAsFixed(2),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              // 판정 결과
              Padding(
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ResultRow(title: "PERFECT", value: scoreManager.perfect,),
                    _ResultRow(title: "GREAT", value: scoreManager.great,),
                    _ResultRow(title: "GOOD", value: scoreManager.good,),
                    _ResultRow(title: "BAD", value: scoreManager.bad,),
                    _ResultRow(title: "MISS", value: scoreManager.miss,),
                    const SizedBox(height: 20),
                    _ResultRow(title: "MAX COMBO", value: scoreManager.maxCombo, ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("HOME"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String title;
  final int value;
  const _ResultRow({ required this.title, required this.value, });

  @override Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 20,),
          ),
          const Spacer(),
          Text(
            value.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold,),
          ),
        ],
      ),
    );
  }
}