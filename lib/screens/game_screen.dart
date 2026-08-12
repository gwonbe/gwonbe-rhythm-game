import 'dart:async';

import 'package:dungtak/engine/game_engine.dart';
import 'package:dungtak/engine/game_state.dart';
import 'package:dungtak/model/song.dart';
import 'package:dungtak/screens/result_screen.dart';
import 'package:dungtak/widgets/pad_widget.dart';

import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  final Song song;

  const GameScreen({
    super.key,
    required this.song,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {

  late final GameEngine engine;
  StreamSubscription<Duration>? subscription;

  // 판정 표시
  late AnimationController _judgeController;
  late Animation<double> _judgeScale;
  late Animation<double> _judgeOpacity;
  String? _displayJudge;

  // 결과
  bool _resultShown = false; // 결과 화면 중복 진입 방지

  @override
  void initState() {
    super.initState();

    engine = GameEngine();

    _judgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _judgeScale = Tween<double>(begin: 1.5, end: 1.0).animate(
      CurvedAnimation(parent: _judgeController, curve: Curves.easeOut,),
    );

    _judgeOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15,),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 45,),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 40,),
    ]).animate(_judgeController);

    _initialize();
  }

  // 초기화
  Future<void> _initialize() async {
    await engine.loadSong(widget.song);

    if (!mounted) return;

    subscription = engine.audioManager.positionStream.listen(
      (position) {
        final currentTime = position.inMilliseconds;
        engine.update(currentTime); // 음악 position 기준으로 게임 상태 업데이트
        if (!mounted) return;
        setState(() {});
        _checkGameFinished();
      },
    );

    await engine.start();
  }

  @override
  void dispose() {
    _judgeController.dispose();
    subscription?.cancel();
    engine.audioManager.dispose();
    super.dispose();
  }

  // Pad
  bool isPadActive(int pad) {
    return engine.noteManager?.hasActiveNote(pad) ?? false;
  }

  // Pad Effect
  bool isPadEffect(int pad) {
    final currentTime = engine.currentTime.inMilliseconds;
    final note = engine.noteManager?.getEffectNote(currentTime);
    return note?.pad == pad;
  }

  // 패드를 눌렀을 때
  void onPadPressed(int pad) {
    final judge = engine.onPadPressed(pad);
    if (judge != null) showJudge(judge.name.toUpperCase());
    if (mounted) setState(() {}); // 터치 직후 UI를 즉시 갱신
    _checkGameFinished();
  }

  // 패드 진행상태 반환
  double getPadProgress(int pad) {
    return engine.noteManager?.getPadProgress(pad, engine.currentTime.inMilliseconds) ?? 0.0;
  }

  // 판정
  void showJudge(String judge) {
    if (!mounted) return;
    setState(() {_displayJudge = judge;});
    _judgeController.forward(from: 0.0);
  }

  // 판정별 텍스트 컬러 반환
  Color getJudgeColor() {
    switch (_displayJudge) {
      case "PERFECT":
        return Colors.white;
      case "GREAT":
        return Colors.yellow;
      case "GOOD":
        return Colors.green;
      case "BAD":
        return Colors.orange;
      case "MISS":
        return Colors.red;
      default:
        return Colors.white;
    }
  }

  // 게임 종료
  void _checkGameFinished() {
    if (!mounted) return;
    if (engine.state != GameState.finished) return;
    if (_resultShown) return;

    _resultShown = true;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) {
          return ResultScreen(
            scoreManager: engine.scoreManager,
          );
        },
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  // Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // 점수
            Text(
              engine.scoreManager.score.toStringAsFixed(2),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),

            // 판정
            SizedBox(
              height: 40,
              child: Center(
                child: AnimatedBuilder(
                  animation: _judgeController,
                  builder: (context, child) {
                    if (_displayJudge == null) {
                      return const SizedBox(
                        width: 1,
                      );
                    }
                    return Opacity(
                      opacity: _judgeOpacity.value,
                      child: Transform.scale(
                        scale: _judgeScale.value,
                        child: Text(
                          _displayJudge!,
                          style: TextStyle(
                            color: getJudgeColor(),
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 패드 영역
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        PadWidget(
                          index: 0,
                          isEffectActive: isPadActive(0),
                          isEffect: isPadEffect(0),
                          onTap: () => onPadPressed(0),
                        ),
                        PadWidget(
                          index: 1,
                          isEffectActive: isPadActive(1),
                          isEffect: isPadEffect(1),
                          onTap: () => onPadPressed(1),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        PadWidget(
                          index: 2,
                          isEffectActive: isPadActive(2),
                          isEffect: isPadEffect(2),
                          onTap: () => onPadPressed(2),
                        ),
                        PadWidget(
                          index: 3,
                          isEffectActive: isPadActive(3),
                          isEffect: isPadEffect(3),
                          onTap: () => onPadPressed(3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}