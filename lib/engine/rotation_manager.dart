import 'dart:math' as math;

enum RotationDirection {
  clockwise,
  counterClockwise,
}

class RotationManager {

  double angle = 0.0; // 현재 회전 각도
  double rotationSpeed = math.pi / 2; // 초당 회전 속도 (rad/s)
  RotationDirection direction = RotationDirection.clockwise;

  // 회전 업데이트
  void update(double deltaSeconds) {
    final directionValue =
    direction == RotationDirection.clockwise ? 1.0 : -1.0;
    angle += rotationSpeed * deltaSeconds * directionValue;
    angle %= math.pi * 2; // 각도를 0 ~ 2π 범위로 정규화
  }

  // 초기화
  void reset() {
    angle = 0.0;
    direction = RotationDirection.clockwise;
  }

  // 시계 방향
  void setClockwise() {
    direction = RotationDirection.clockwise;
  }

  // 반시계 방향
  void setCounterClockwise() {
    direction = RotationDirection.counterClockwise;
  }

}