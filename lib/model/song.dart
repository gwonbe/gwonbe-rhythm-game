class Song {

  final String title;
  final String artist;
  final String musicPath;
  final String beatMapPath;
  final String imagePath;
  final Duration previewStart;
  final Duration previewEnd;
  final Duration? duration;

  Song({
    required this.title,
    required this.artist,
    required this.musicPath,
    required this.beatMapPath,
    required this.imagePath,
    required this.previewStart,
    required this.previewEnd,
    required this.duration,
  });

}