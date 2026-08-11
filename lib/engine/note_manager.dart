import 'package:dungtak/engine/score_manager.dart';
import 'package:dungtak/model/note.dart';

import 'package:flutter/cupertino.dart';

class NoteManager {

  final _tag = "[NoteManager]";

  static const int appearTime = 800;
  static const int missWindow = 400; // 색상을 유지할 시간
  final List<Note> notes;

  NoteManager(this.notes);

  void update(int currentTime) {
    for (final note in notes) {
      // 이미 처리된 노트
      if (note.state == NoteState.hit || note.state == NoteState.miss) {
        continue;
      }

      // 색상 활성화
      if (note.state == NoteState.waiting && currentTime >= note.time - appearTime) {
        note.state = NoteState.active;
        debugPrint("$_tag [update] ACTIVE : id=${note.id}, pad=${note.pad}, noteTime=${note.time}, currentTime=$currentTime",);
      }

      // 파란색 상태가 끝남 → MISS
      if (note.state == NoteState.active && currentTime > note.time + missWindow) {
        note.state = NoteState.miss;
        debugPrint("$_tag [update] MISS : id=${note.id}, pad=${note.pad}, noteTime=${note.time}, currentTime=$currentTime");
      }
    }
  }

  Judge? hit(int pad, int currentTime) {
    for (final note in notes) {
      if (note.pad != pad) continue; // 다른 패드
      if (note.state != NoteState.active) continue; // 현재 색칠된 노트 이외는 무시
      note.state = NoteState.hit; //  색칠된 노트이면 시간 상관없이 판정
      debugPrint("$_tag [hit] HIT : id=${note.id}, pad=${note.pad}, noteTime=${note.time}, currentTime=$currentTime",);
      return Judge.perfect;
    }

    debugPrint("$_tag [hit] NO ACTIVE NOTE : pad=$pad currentTime=$currentTime",);

    return null;
  }

  List<Note> get activeNotes {
    return notes.where((note) => note.state == NoteState.active,).toList();
  }

  double getProgress(Note note, int currentTime) {
    final start = note.time - appearTime;

    if (currentTime <= start) return 0.0;
    if (currentTime >= note.time) return 1.0;
    return (currentTime - start) / appearTime;
  }

  double getPadProgress(int pad, int currentTime) {
    for (final note in activeNotes) {
      if (note.pad == pad) {
        return getProgress(note, currentTime);
      }
    }

    return 0.0;
  }

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

  Note? getEffectNote(int currentTime) {
    for (final note in notes) {
      if (note.state != NoteState.active) {
        continue;
      }
      if (currentTime >= note.time &&
          currentTime < note.time + 100) {
        return note;
      }
    }

    return null;
  }

  Note? getMissedNote() {
    for (final note in notes) {
      if (note.state == NoteState.miss && !note.missProcessed) {
        note.missProcessed = true;
        debugPrint("$_tag [getMissedNote] MISSED: id=${note.id}, pad=${note.pad}, time=${note.time}",);
        return note;
      }
    }

    return null;
  }

}