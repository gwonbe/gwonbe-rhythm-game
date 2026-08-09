import 'dart:async';

import 'package:dungtak/engine/game_engine.dart';
import 'package:dungtak/engine/game_state.dart';
import 'package:dungtak/model/note.dart';
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

class _GameScreenState extends State<GameScreen> {
  final _tag = "[GameScreen]";

  late final GameEngine engine;
  StreamSubscription<Duration>? subscription;
  bool _resultShown = false;

  @override
  void initState() {
    super.initState();
    engine = GameEngine();
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
    subscription?.cancel();
    engine.audioManager.dispose();
    super.dispose();
  }

  bool isPadActive(int pad) {
    final active = engine.noteManager?.activeNotes.any((e) => e.pad == pad) ?? false;
    debugPrint("$_tag pad=$pad active=$active");
    return active;
  }

  bool isPadEffect(int pad) {
    final note = getEffectNote();
    return note?.pad == pad;
  }

  bool isPadEffectActive(int pad) {
    return engine.effectNote?.pad == pad;
  }

  void onPadPressed(int pad) {
    final judge = engine.onPadPressed(pad);
    if (judge != null) {
      debugPrint("$_tag judge.name : ${judge.name}");
    }
    setState(() {});
  }

  double getProgress(int pad) {
    return engine.noteManager?.getPadProgress(pad, engine.currentTime.inMilliseconds,) ?? 0.0;
  }

  double getPadProgress(int pad) {
    return engine.noteManager?.getPadProgress(pad, engine.currentTime.inMilliseconds,) ?? 0.0;
  }

  Note? getEffectNote() {
    return engine.noteManager?.getEffectNote(engine.currentTime.inMilliseconds);
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    "${engine.currentTime.inMilliseconds} ms",
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    engine.state.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            // 판정
            SizedBox(
              height: 60,
              child: Center(
                child: Text(
                  engine.lastJudge?.name.toUpperCase() ?? (engine.lastMissedNote != null ? 'MISS' : ''),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
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