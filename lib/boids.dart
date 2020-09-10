import 'package:flutter/painting.dart';
export 'flocking_view.dart';

class Boid {
  Offset position;
  Offset velocity;
  double direction;

  Boid({
    this.position = Offset.zero,
    this.velocity = Offset.zero,
    this.direction = 0,
  });
}

