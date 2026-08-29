import 'dart:async';

import 'package:dungtak/constants/game_constants.dart';
import 'package:dungtak/engine/game_engine.dart';
import 'package:dungtak/engine/game_state.dart';
import 'package:dungtak/engine/rotation_manager.dart';
import 'package:dungtak/model/song.dart';
import 'package:dungtak/screens/result_screen.dart';
import 'package:dungtak/widgets/spin_board_widget.dart';

import 'package:flutter/material.dart';

class GameSpinModeScreen extends StatefulWidget {
  final Song song;

  const GameSpinModeScreen({
    super.key,
    required this.song,
  });

  @override
  State<GameSpinModeScreen> createState() => _GameSpinModeScreenState();
}

class _GameSpinModeScreenState extends State<GameSpinModeScreen> with TickerProviderStateMixin {

  late final GameEngine engine;
  late final RotationManager rotationManager;
  StreamSubscription<Duration>? subscription;
  late AnimationController _rotationController;

  // 판정 표시
  late AnimationController _judgeController;
  late Animation<double> _judgeScale;
  late Animation<double> _judgeOpacity;
  String? _displayJudge;

  // 결과 화면 중복 방지
  bool _resultShown = false;

  // 회전 시간 계산
  Duration _lastRotationElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();

    engine = GameEngine();

    rotationManager = RotationManager();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    )..addListener(_updateRotation);

    _judgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _judgeScale = Tween<double>(
      begin: 1.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _judgeController,
        curve: Curves.easeOut,
      ),
    );

    _judgeOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 40),
    ]).animate(_judgeController);

    _initialize();
  }

  // 초기화
  Future<void> _initialize() async {
    await engine.loadSong(widget.song);

    if (!mounted) return;

    subscription = engine.audioManager.positionStream.listen((position) {
      final currentTime = position.inMilliseconds;
      engine.update(currentTime);
      if (!mounted) return;
      setState(() {});
      _checkGameFinished();
    });

    _rotationController.repeat();

    await engine.start();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _judgeController.dispose();
    subscription?.cancel();
    engine.audioManager.dispose();
    super.dispose();
  }


  void _updateRotation() {
    final elapsed = _rotationController.lastElapsedDuration ?? Duration.zero;
    final delta = elapsed - _lastRotationElapsed;
    _lastRotationElapsed = elapsed;
    if (delta <= Duration.zero) return;

    rotationManager.update(delta.inMicroseconds / 1000000.0);

    if (mounted) {
      setState(() {});
    }
  }

  // 현재 활성화된 패드
  Set<int> get activePads {
    final manager = engine.noteManager;
    if (manager == null) return {};
    return manager.activeNotes.map((note) => note.pad).toSet();
  }

  // 패드 색상
  Color getPadColor(int pad) {
    final manager = engine.noteManager;
    if (manager == null) return GameConstants.noteColorActive;

    final currentTime = engine.currentTime.inMilliseconds;

    for (final note in manager.activeNotes) {
      if (note.pad == pad) {
        return manager.getNoteColor(note, currentTime);
      }
    }

    return GameConstants.noteColorActive;
  }

  // 패드 터치
  void onPadPressed(int pad) {
    final judge = engine.onPadPressed(pad);
    if (judge != null) showJudge(judge.name.toUpperCase());
    if (mounted) setState(() {});
    _checkGameFinished();
  }

  // 판정 표시
  void showJudge(String judge) {
    if (!mounted) return;
    setState(() {_displayJudge = judge;});
    _judgeController.forward(from: 0.0);
  }

  // 판정 색상
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
    _rotationController.stop();

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

            // 상단 정보 영역
            SizedBox(
              height: 80,
              child: Row(
                children: [

                  // 곡 정보
                  Expanded(
                    child: Row(
                      children: [

                        // 앨범 커버
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(widget.song.imagePath, width: 60, height: 60, fit: BoxFit.cover),
                          ),
                        ),

                        // 제목 + 아티스트
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.song.title,
                                maxLines: 1,
                                overflow:  TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                widget.song.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 현재 판정
                  Expanded(
                    child: SizedBox(
                      height: 80,
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _judgeController,
                          builder: (context, child) {
                            if (_displayJudge == null) {
                              return const SizedBox(width: 1);
                            }
                            return Opacity(
                              opacity: _judgeOpacity.value,
                              child: Transform.scale(
                                scale: _judgeScale.value,
                                child: Text(
                                  _displayJudge!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: getJudgeColor(),
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // 현재 점수
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            engine.scoreManager.score.toStringAsFixed(2),
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox( height: 2),
                          const Text(
                            "SCORE",
                            style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 회전판
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SpinBoardWidget(
                    rotationAngle: rotationManager.angle,
                    activePads: activePads,
                    getPadColor: getPadColor,
                    onPadPressed: onPadPressed,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}