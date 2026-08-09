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
  final _tag = "[GameScreen]";

  late final GameEngine engine;
  StreamSubscription<Duration>? subscription;

  // 터치 판정
  final Set<int> _pressedPads = {};
  Timer? _judgeTimer;
  late AnimationController _judgeController;
  late Animation<double> _judgeScale;
  late Animation<double> _judgeOpacity;
  String? _displayJudge;

  // 결과
  bool _resultShown = false;

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

  Future<void> _initialize() async {
    await engine.loadSong(widget.song);

    subscription = engine.audioManager.positionStream.listen((position) {
      engine.update(position.inMilliseconds);
      if (!mounted) {
        return;
      }
      setState(() {});
      _checkGameFinished();
    });

    await engine.start();
  }

  @override
  void dispose() {
    _judgeController.dispose();
    _judgeTimer?.cancel();
    subscription?.cancel();
    engine.audioManager.dispose();
    super.dispose();
  }

  bool isPadActive(int pad) {
    final active = engine.noteManager?.activeNotes.any((e) => e.pad == pad) ?? false;
    return active;
  }

  bool isPadEffect(int pad) {
    final currentTime = engine.currentTime.inMilliseconds;
    final note = engine.noteManager?.getEffectNote(currentTime);
    return note?.pad == pad;
  }

  bool isPadEffectActive(int pad) {
    return engine.effectNote?.pad == pad;
  }

  void onPadPressed(int pad) {
    debugPrint("$_tag [onPadPressed] TOUCH, pad=$pad, time=${engine.currentTime.inMilliseconds}",);

    setState(() {
      _pressedPads.add(pad);
    });

    Timer(
      const Duration(milliseconds: 100),
      () {
        if (!mounted) return;
        setState(() {
          _pressedPads.remove(pad);
        });
      },
    );

    final judge = engine.onPadPressed(pad);

    if (judge != null) {
      debugPrint("$_tag [onPadPressed] JUDGE=${judge.name}",);
      showJudge(judge.name.toUpperCase());
    } else {
      debugPrint("$_tag [onPadPressed] NO JUDGE",);
    }
  }

  double getProgress(int pad) {
    return engine.noteManager?.getPadProgress(pad, engine.currentTime.inMilliseconds,) ?? 0.0;
  }

  double getPadProgress(int pad) {
    return engine.noteManager?.getPadProgress(pad, engine.currentTime.inMilliseconds,) ?? 0.0;
  }

  void showJudge(String judge) {
    setState(() {
      _displayJudge = judge;
    });

    _judgeController.forward(from: 0.0);
  }

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

  void _checkGameFinished() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [

            // 정보
            SizedBox(
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Score : ${engine.scoreManager.score.toStringAsFixed(2)}",
                    style: const TextStyle(color: Colors.white, fontSize: 24,),
                  ),
                  Text(
                    "${engine.currentTime.inMilliseconds} ms",
                    style: const TextStyle(color: Colors.white70,),
                  ),
                  Text(
                    engine.state.name,
                    style: const TextStyle(color: Colors.white, fontSize: 18,),
                  ),
                ],
              ),
            ),

            // 판정
            SizedBox(
              height: 60,
              child: Center(
                child: AnimatedBuilder(
                  animation: _judgeController,
                  builder: (context, child) {
                    if (_displayJudge == null) {
                      return const SizedBox(height: 40,);
                    }
                    return Opacity(
                      opacity: _judgeOpacity.value,
                      child: Transform.scale(
                        scale: _judgeScale.value,
                        child: Text(
                          _displayJudge!,
                          style: TextStyle(color: getJudgeColor(), fontSize: 32, fontWeight: FontWeight.bold,),
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
                          isPressed: _pressedPads.contains(0),
                          onTap: () => onPadPressed(0),
                        ),
                        PadWidget(
                          index: 1,
                          isEffectActive: isPadActive(1),
                          isEffect: isPadEffect(1),
                          isPressed: _pressedPads.contains(1),
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
                          isPressed: _pressedPads.contains(2),
                          onTap: () => onPadPressed(2),
                        ),
                        PadWidget(
                          index: 3,
                          isEffectActive: isPadActive(3),
                          isEffect: isPadEffect(3),
                          isPressed: _pressedPads.contains(3),
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