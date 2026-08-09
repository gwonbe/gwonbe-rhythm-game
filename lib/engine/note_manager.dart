import 'package:dungtak/engine/score_manager.dart';
import 'package:dungtak/model/note.dart';

import 'package:flutter/cupertino.dart';

class NoteManager {

  final _tag = "[NoteManager]";
  static const appearTime = 500;
  static const missWindow = 150;
  final List<Note> notes;
  NoteManager(this.notes);

  void update(int currentTime) {
    debugPrint("$_tag currentTime: $currentTime");

    for (final note in notes) {
      if (note.state == NoteState.waiting && currentTime >= note.time - appearTime) {
        note.state = NoteState.active;
        debugPrint("$_tag ACTIVE id=${note.id} pad=${note.pad} time=${note.time}");
      }
      if (note.state == NoteState.active && currentTime > note.time + missWindow) {
        note.state = NoteState.miss;
      }
    }
  }

  Judge? hit(int pad, int currentTime) {
    debugPrint("$_tag HIT pad=$pad currentTime=$currentTime");

    for (final note in notes) {
      debugPrint("$_tag note=${note.id}, pad=${note.pad}, time=${note.time}, state=${note.state}",);
      if (note.state != NoteState.active) continue;
      if (note.pad != pad) continue;

      final diff = (currentTime - note.time).abs();
      debugPrint("$_tag MATCH note=${note.id} diff=$diff");

      // 판정

      if (diff <= 80) {
        note.state = NoteState.hit;
        return Judge.perfect;
      }
      if (diff <= 160) {
        note.state = NoteState.hit;
        return Judge.great;
      }
      if (diff <= 240) {
        note.state = NoteState.hit;
        return Judge.good;
      }
      if (diff <= 320) {
        note.state = NoteState.hit;
        return Judge.bad;
      }

    }

    return null;
  }

  List<Note> get activeNotes {
    return notes.where((note) {
      return note.state == NoteState.active;
    }).toList();
  }

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

  double getPadProgress(int pad, int currentTime) {
    for (final note in activeNotes) {
      if (note.pad == pad) return getProgress(note, currentTime);
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
      if (currentTime >= note.time && currentTime < note.time + 150) {
        return note;
      }
    }

    return null;
  }

  Note? getMissedNote() {
    for (final note in notes) {
      if (note.state == NoteState.miss && !note.missDisplayed) {
        note.missDisplayed = true;
        return note;
      }
    }

    return null;
  }

}