import 'dart:convert';

import 'package:dungtak/model/beat_map.dart';
import 'package:dungtak/model/note.dart';

import 'package:flutter/services.dart';

class BeatMapLoader {

  Future<BeatMap> load(String path) async {
    final jsonString = await rootBundle.loadString(path);
    final json = jsonDecode(jsonString);
    final notes = (json["notes"] as List).map((e) => Note(id: e["id"], time: e["time"], pad: e["pad"],),).toList();

    return BeatMap(
      title: json["title"],
      artist: json["artist"],
      notes: notes,
    );
  }

}