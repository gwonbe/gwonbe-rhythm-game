import 'package:dungtak/engine/score_manager.dart';
import 'package:dungtak/model/note.dart';

import 'package:flutter/material.dart';

class NoteManager {

  final _tag = "[NoteManager]";

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
        debugPrint("$_tag [update] MISS : id=${note.id}, pad=${note.pad}, noteTime=${note.time}, currentTime=$currentTime");
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

  List<Note> get activeNotes {
    return notes.where((note) => note.state == NoteState.active).toList();
  }

  // HIT
  Judge? hit(int pad, int currentTime) {
    Note? targetNote;

    // 현재 패드에서 활성화된 노트 중 현재 시간과 가장 가까운 노트를 찾는다.
    for (final note in notes) {
      if (note.pad != pad) continue;
      if (note.state != NoteState.active) continue;
      targetNote = note;
      break;
    }

    // 활성 노트가 없을 때
    if (targetNote == null) return null;

    // hit 처리
    final startTime = targetNote.time - appearTime;
    final elapsed = currentTime - startTime;
    targetNote.state = NoteState.hit;

    if (elapsed <= 500) {
      return Judge.perfect;
    } else if (elapsed <= 700) {
      return Judge.great;
    } else if (elapsed <= 900) {
      return Judge.good;
    } else {
      return Judge.bad;
    }
  }

  // 색상 계산
  Color getNoteColor(Note note, int currentTime) {
    final startTime = note.time - appearTime;
    if (currentTime <= startTime) {
      return noteColor;
    }

    final elapsed = currentTime - startTime;
    if (elapsed >= appearTime) {
      return Colors.grey;
    }

    final progress = elapsed / appearTime;
    return Color.lerp(noteColor, Colors.grey, progress,)!;
  }

  // 진행상태 반환
  double getProgress(Note note, int currentTime) {
    final start = note.time - appearTime;

    if (currentTime <= start) {
      return 0.0;
    } else if (currentTime >= note.time) {
      return 1.0;
    } else {
      return (currentTime - start) / appearTime;
    }
  }

  // 패드 진행상태 반환
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

  // 노트 반환
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

  // Effect
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