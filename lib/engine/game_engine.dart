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

  // * * * * * 게임 상태 변경 * * * * *

  /// 게임 상태를 ready 상태로 초기화
  Future<void> loadSong(Song song) async {
    currentSong = song;
    beatMap = await loader.load(song.beatMapPath);
    await audioManager.load(song.musicPath);
    state = GameState.ready;
    noteManager = NoteManager(beatMap!.notes);
    debugPrint("$_tag 노트 개수 : ${beatMap!.notes.length}");
  }

  /// 게임 상태를 playing으로 변경하고 음악 재생 시작
  Future<void> start() async {
    state = GameState.playing;
    await audioManager.play();
  }

  /// 게임 상태를 paused로 변경하고 음악 일시정지
  Future<void> pause() async {
    state = GameState.paused;
    await audioManager.pause();
  }

  /// 게임 상태를 finished로 변경
  void finish() {
    state = GameState.finished;
  }

  // * * * * * 게임 진행 * * * * *

  /// 현재 음악 재생 위치를 반환
  Duration get currentTime {
    return audioManager.currentPosition;
  }

  /// 게임 시간에 맞춰 노트 상태를 업데이트하고 MISS 및 게임 종료 여부 확인
  void update(int currentTime) {
    noteManager?.update(currentTime);
    final missedNote = noteManager?.getMissedNote();

    if (missedNote != null) {
      final unitScore = 100 / beatMap!.notes.length;

      scoreManager.addJudge(Judge.miss, unitScore,);
      lastMissedNote = missedNote;
      missStartTime = currentTime;
    }

    if (lastMissedNote != null) {
      if (currentTime - missStartTime >= 500) {
        lastMissedNote = null;
      }
    }

    // 게임 종료 확인
    if (beatMap != null && noteManager != null) {
      final allFinished = noteManager!.notes.every((Note note) => note.state == NoteState.hit || note.state == NoteState.miss,);
      if (allFinished) {
        final lastNoteTime = noteManager!.notes.map((Note note) => note.time).reduce((a, b) => a > b ? a : b);
        if (currentTime > lastNoteTime + 300) {
          finish();
        }
      }
    }
  }

  /// 플레이어가 패드를 눌렀을 때 노트를 판정하고 점수에 반영
  Judge? onPadPressed(int pad) {
    final judge = noteManager?.hit(pad, currentTime.inMilliseconds,);
    if (judge == null) return null;

    final unitScore = 100 / beatMap!.notes.length;
    scoreManager.addJudge(judge, unitScore,);
    lastJudge = judge;
    judgeStartTime = currentTime.inMilliseconds;

    return judge;
  }

}