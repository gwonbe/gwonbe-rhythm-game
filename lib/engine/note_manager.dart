import 'package:dungtak/constants/constants.dart';
import 'package:dungtak/engine/score_manager.dart';
import 'package:dungtak/model/note.dart';

import 'package:flutter/material.dart';

class NoteManager {

  static const int appearTime = 800; // 노트 색상이 바뀌는 시작하는 시간
  static const int missWindow = 400; // 노트 시간이 지난 후에도 활성화 상태를 유지하는 시간

  // 판정 기준
  static const int timePerfect = 500;
  static const int timeGreat = 700;
  static const int timeGood = 900;
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

    // 현재 패드에서 활성화된 노트 중 첫 번째 노트를 찾는다.
    for (final note in notes) {
      if (note.pad != pad) continue;
      if (note.state != NoteState.active) continue;
      targetNote = note;
      break;
    }

    // 활성 노트가 없을 때
    if (targetNote == null) return null;

    // 노트 등장 후 경과 시간
    final startTime = targetNote.time - appearTime;
    final elapsed = currentTime - startTime;

    // HIT 처리
    targetNote.state = NoteState.hit;

    // 판정
    if (elapsed <= timePerfect) {
      return Judge.perfect;
    } else if (elapsed <= timeGreat) {
      return Judge.great;
    } else if (elapsed <= timeGood) {
      return Judge.good;
    } else {
      return Judge.bad;
    }
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
    if (target == null) return Constants.noteColorInactive;

    final progress = getProgress(target, currentTime);
    return Color.lerp(Constants.noteColorActive, Constants.noteColorInactive, progress)!;
  }

  // 특정 노트의 현재 색상
  Color getNoteColor(Note note, int currentTime) {
    final progress = getProgress(note, currentTime);
    return Color.lerp(Constants.noteColorActive, Constants.noteColorInactive, progress)!;
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