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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // 점수
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "SCORE",
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
                      ],
                    ),
                  ),

                  // 판정 결과
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ResultRow(title: "PERFECT", value: scoreManager.perfect, isBold: false,),
                          _ResultRow(title: "GREAT", value: scoreManager.great, isBold: false,),
                          _ResultRow(title: "GOOD", value: scoreManager.good, isBold: false,),
                          _ResultRow(title: "BAD", value: scoreManager.bad, isBold: false,),
                          _ResultRow(title: "MISS", value: scoreManager.miss, isBold: false,),
                          _ResultRow(title: "MAX COMBO", value: scoreManager.maxCombo, isBold: true,),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),

                ],
              ),

              // 홈 버튼
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                ),
                onPressed: () {Navigator.popUntil(context, (route) => route.isFirst);},
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
  final bool isBold;

  const _ResultRow({
    required this.title,
    required this.value,
    required this.isBold,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: Text(
              title,
              style: isBold
                  ? const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                  : const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value.toString(),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
