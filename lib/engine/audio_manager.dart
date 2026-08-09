import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';

class AudioManager {

  final _tag = "[AudioManager]";
  final AudioPlayer _player = AudioPlayer();

  // getter

  AudioPlayer get player => _player;

  Duration get currentPosition => _player.position;

  Stream<Duration> get positionStream => _player.positionStream;

  // function

  Future<void> load(String path) async {
    try {
      await _player.setAsset(path);
      debugPrint("$_tag Audio loaded : $path");
    } catch (e, stackTrace) {
      debugPrint("$_tag Audio load error : $e");
      debugPrint(stackTrace.toString());
    }
  }

  Future<void> play() async {
    try {
      await _player.play();
      debugPrint("$_tag Audio playing");
    } catch (e) {
      debugPrint("$_tag Play error : $e");
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }

}