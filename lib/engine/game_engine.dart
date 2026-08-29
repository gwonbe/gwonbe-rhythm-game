import 'package:dungtak/engine/audio_manager.dart';
import 'package:dungtak/engine/beatmap_loader.dart';
import 'package:dungtak/engine/game_state.dart';
import 'package:dungtak/engine/note_manager.dart';
import 'package:dungtak/engine/score_manager.dart';
import 'package:dungtak/model/beat_map.dart';
import 'package:dungtak/model/note.dart';
import 'package:dungtak/model/song.dart';

import 'package:flutter/cupertino.dart';

class GameEngine {
  final _tag = "[GameEngine]";

  // 점수
  final ScoreManager scoreManager = ScoreManager();
  Judge? lastJudge;
  int judgeStartTime = 0;

  // 음악
  final AudioManager audioManager = AudioManager();
  final BeatMapLoader loader = BeatMapLoader();
  BeatMap? beatMap;
  Song? currentSong;

  // 노트
  NoteManager? noteManager;
  Note? effectNote;
  Note? lastMissedNote;
  int effectStartTime = 0;
  int missStartTime = 0;

  // 전체 진행
  GameState state = GameState.ready;

  // 음악 파일과 비트맵 로드
  Future<void> loadSong(Song song) async {
    currentSong = song;
    beatMap = await loader.load(song.beatMapPath);
    await audioManager.load(song.musicPath);
    state = GameState.ready;
    noteManager = NoteManager(beatMap!.notes);
    debugPrint("$_tag [loadSong] note count : ${beatMap!.notes.length}");
  }

  // 게임 상태를 진행중으로 변경하고 음악 재생 시작
  Future<void> start() async {
    state = GameState.playing;
    await audioManager.play();
    debugPrint("$_tag [start] START : position=${audioManager.currentPosition.inMilliseconds}ms");
  }

  // 게임 상태를 일시정지로 변경하고 음악도 일시정지
  Future<void> pause() async {
    state = GameState.paused;
    await audioManager.pause();
  }

  // 게임 상태를 종료로 변경
  void finish() {
    if (state == GameState.finished) return;
    state = GameState.finished;
    debugPrint("$_tag [finish] GAME FINISHED");
  }

  // 현재 음악 재생 위치 반환
  Duration get currentTime {
    return audioManager.currentPosition;
  }

  // 게임 시간에 맞춰 노트 상태를 업데이트하고 MISS 및 게임 종료 여부 확인
  void update(int currentTime,) {
    if (state != GameState.playing) return;

    final manager = noteManager;
    if (manager == null) return;

    // Note 상태 업데이트
    manager.update(currentTime,);

    // MISS 처리
    final missedNote = manager.getMissedNote();

    if (missedNote != null) {
      if (beatMap != null && beatMap!.notes.isNotEmpty) {
        final unitScore = 100 / beatMap!.notes.length;
        scoreManager.addJudge(Judge.miss, unitScore);
      }
      lastMissedNote = missedNote;
      missStartTime = currentTime;
    }

    // MISS 표시 종료
    if (lastMissedNote != null) {
      if (currentTime - missStartTime >= 500) {
        lastMissedNote = null;
      }
    }

    // 게임 종료
    _checkFinished(currentTime);
  }

  // 게임 종료 확인
  void _checkFinished(int currentTime) {
    if (beatMap == null || noteManager == null) return;
    if (noteManager!.notes.isEmpty) return;

    final allFinished = noteManager!.notes.every((note) => note.state == NoteState.hit || note.state == NoteState.miss);
    if (!allFinished) return;

    final lastNoteTime = noteManager!.notes.map((note) => note.time).reduce((a, b) => a > b ? a : b,);
    if (currentTime > lastNoteTime + 300) finish();
  }

  // 패드 터치했을 때
  Judge? onPadPressed(int pad) {
    if (state != GameState.playing) return null;
    if (noteManager == null || beatMap == null || beatMap!.notes.isEmpty) return null;

    // 터치한 순간에 노트 상태 업데이트
    final touchTime = audioManager.currentPosition.inMilliseconds;
    noteManager!.update(touchTime);

    // 판정
    final judge = noteManager!.hit(pad, touchTime);
    if (judge == null) return null;

    // 점수
    final unitScore = 100 / beatMap!.notes.length;

    // 점수 반영
    scoreManager.addJudge(judge, unitScore);
    lastJudge = judge;
    judgeStartTime = touchTime;

    // 모든 노트가 처리됐는지 즉시 확인
    _checkFinished(touchTime);

    return judge;
  }

}