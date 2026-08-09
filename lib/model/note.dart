class Note {

  final int id;
  final int time; /// 음악 시작 후 몇 ms에 눌러야 하는지
  final int pad;
  final NoteType type;
  bool isHit;
  bool isMissed;
  bool missDisplayed;
  bool effectTriggered;
  NoteState state;

  Note({
    required this.id,
    required this.time,
    required this.pad,
    this.type = NoteType.tap,
    this.isHit = false,
    this.isMissed = false,
    this.missDisplayed = false,
    this.effectTriggered = false,
    this.state = NoteState.waiting,
  });

}

enum NoteType {
  tap,
  hold,
  flick,
}

enum NoteState {
  waiting,
  active,
  hit,
  miss,
}
