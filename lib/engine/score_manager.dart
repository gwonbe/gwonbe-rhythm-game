enum Judge {
  perfect,
  great,
  good,
  bad,
  miss,
}

class ScoreManager {

  // 판정 횟수
  int perfect = 0;
  int great = 0;
  int good = 0;
  int bad = 0;
  int miss = 0;

  // 점수
  int combo = 0;
  int maxCombo = 0;
  double score = 0;

  void addJudge(Judge judge, double unitScore) {
    switch (judge) {

      case Judge.perfect:
        perfect++;
        combo++;
        score += unitScore;
        break;

      case Judge.great:
        great++;
        combo++;
        score += unitScore * 0.8;
        break;

      case Judge.good:
        good++;
        combo++;
        score += unitScore * 0.6;
        break;

      case Judge.bad:
        bad++;
        combo = 0;
        score += unitScore * 0.3;
        break;

      case Judge.miss:
        miss++;
        combo = 0;
        break;
    }

    if (combo > maxCombo) {
      maxCombo = combo;
    }
  }

}