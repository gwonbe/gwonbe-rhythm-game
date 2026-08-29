import 'package:dungtak/constants/game_constants.dart';
import 'package:dungtak/engine/score_manager.dart';
import 'package:dungtak/model/note.dart';

import 'package:flutter/material.dart';

class NoteManager {
  static const Color noteColor = Colors.blue;
  static const int appearTime = 800; // 노트 색상이 바뀌는 시작하는 시간
  static const int missWindow = 400; // 노트 시간이 지난 후에도 활성화 상태를 유지하는 시간
  final List<Note> notes;

  NoteManager(this.notes);

  // 노트 진행 업데이트
  void update(int currentTime) {
    for (final note in notes) {
      // 이미 처리된 노트
      if (note.state == NoteState.hit || note.state == NoteState.miss) {
        continue;
      }

      // WAITING -> ACTIVE
      if (note.state == NoteState.waiting && currentTime >= note.time - appearTime) {
        note.state = NoteState.active;
      }

      // ACTIVE -> MISS
      if (note.state == NoteState.active && currentTime > note.time + missWindow) {
        note.state = NoteState.miss;
      }
    }
  }

  // 활성화 노트인지 확인
  bool hasActiveNote(int pad) {
    for (final note in notes) {
      if (note.pad == pad && note.state == NoteState.active) {
        return true;
      }
    }

    return false;
  }

  // 현재 활성화된 모든 노트
  List<Note> get activeNotes {
    return notes.where((note) => note.state == NoteState.active).toList();
  }

  // 특정 패드의 현재 노트
  Note? getActiveNote(int pad) {
    for (final note in notes) {
      if (note.pad == pad && note.state == NoteState.active) {
        return note;
      }
    }

    return null;
  }

  // HIT
  Judge? hit(int pad, int currentTime) {
    Note? targetNote;
    int smallestDistance = 1 << 30;

    // 현재 패드에서 가장 가까운 활성 노트를 찾는다.
    for (final note in notes) {
      if (note.pad != pad) continue;
      if (note.state != NoteState.active) continue;

      final distance = (currentTime - note.time).abs();
      if (distance < smallestDistance) {
        smallestDistance = distance;
        targetNote = note;
      }
    }

    // 활성 노트가 없을 때
    if (targetNote == null) return null;

    // 현재 노트의 진행률
    final progress = getProgress(targetNote, currentTime);

    // 판정 결정
    final judge = _getJudge(progress);

    // HIT 처리
    targetNote.state = NoteState.hit;
    
    return judge;
  }

  // 진행률에 따른 판정
  Judge _getJudge(double progress) {

    // 0.0 = 노트가 처음 등장한 순간, 1.0 = 노트 타이밍에 도달한 순간

    if (progress <= 0.20) return Judge.perfect;
    if (progress <= 0.45) return Judge.great;
    if (progress <= 0.70) return Judge.good;
    return Judge.bad;
  }

  // 노트 등장 후 현재 진행률
  double getProgress(Note note, int currentTime) {
    // 0.0 = 처음 등장, 1.0 = 정확한 노트 시간
    final start = note.time - appearTime;

    if (currentTime <= start) return 0.0;
    if (currentTime >= note.time) return 1.0;
    return (currentTime - start) / appearTime;
  }

  // 패드의 현재 노트 진행률
  double getPadProgress(int pad, int currentTime) {
    Note? target;
    int smallestDistance = 1 << 30;

    for (final note in notes) {
      if (note.pad != pad) continue;
      if (note.state != NoteState.active) continue;

      final distance = (currentTime - note.time).abs();
      if (distance < smallestDistance) {
        smallestDistance = distance;
        target = note;
      }
    }

    if (target == null) return 0.0;
    return getProgress(target, currentTime);
  }

  // 패드의 현재 색상
  Color getPadColor(int pad, int currentTime) {
    final target = getActiveNote(pad);
    if (target == null) return GameConstants.noteColorInactive;

    final progress = getProgress(target, currentTime);
    return Color.lerp(GameConstants.noteColorActive, GameConstants.noteColorInactive, progress)!;
  }

  // 특정 노트의 현재 색상
  Color getNoteColor(Note note, int currentTime) {
    final progress = getProgress(note, currentTime);
    return Color.lerp(GameConstants.noteColorActive, GameConstants.noteColorInactive, progress)!;
  }

  // Effect
  List<Note> getTriggeredNotes(int currentTime) {
    final result = <Note>[];

    for (final note in notes) {
      if (note.effectTriggered) {
        continue;
      }
      if (currentTime >= note.time) {
        note.effectTriggered = true;
        result.add(note);
      }
    }

    return result;
  }

  // EffectNote 찾기
  Note? getEffectNote(int currentTime) {
    for (final note in notes) {
      if (note.state != NoteState.active) {
        continue;
      }
      if (currentTime >= note.time && currentTime < note.time + 100) {
        return note;
      }
    }

    return null;
  }

  // MISS
  Note? getMissedNote() {
    for (final note in notes) {
      if (note.state == NoteState.miss && !note.missProcessed) {
        note.missProcessed = true;
        return note;
      }
    }

    return null;
  }

}