import 'package:dungtak/constants/constants.dart';
import 'package:flutter/material.dart';

class Util {

  static Color getJudgeColor(String? judgeStr) {
    switch (judgeStr) {
      case "PERFECT":
        return Constants.judgeFontcolorPerfect;
      case "GREAT":
        return Constants.judgeFontcolorGreat;
      case "GOOD":
        return Constants.judgeFontcolorGood;
      case "BAD":
        return Constants.judgeFontcolorBad;
      case "MISS":
        return Constants.judgeFontcolorMiss;
      default:
        return Colors.white;
    }
  }

}