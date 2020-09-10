import 'dart:math';
import 'dart:core';
import 'package:flutter/widgets.dart';
import 'boids.dart';

class SimulationConfig {
  double visibleRange;
  double separation;
  double alignment;
  double cohesion;

  SimulationConfig({
    this.visibleRange = 80,
    this.separation = 0.03,
    this.alignment = 0.03,
    this.cohesion = 0.04,
  });
}

class FlockingSimulation {
  static const totalBoids = 12;
  static const double maxVelocity = 30;
  Size size = Size(100, 100);
  List<Boid> _boids = [];
  SimulationConfig config = SimulationConfig();

  List<Boid> get bolds => _boids;

  init({Size size}) {
    this.size = size ?? this.size;
    final rand = Random();
    _boids = List.generate(totalBoids, (i) {
      return Boid(
        position: Offset(
          this.size.width * rand.nextDouble(),
          this.size.height * rand.nextDouble(),
        ),
        velocity: Offset(
          maxVelocity * 2 * rand.nextDouble() - maxVelocity / 2,
          maxVelocity * 2 * rand.nextDouble() - maxVelocity / 2,
        ),
      );
    });
  }

  bool _isVisible(Boid from, Boid to) {
    var diff = to.position - from.position;
    if (diff.distance > config.visibleRange) {
      return false;
    } else {
      final angle = atan2(diff.dy, diff.dx) - atan2(from.velocity.dy, from.velocity.dx);
      return angle.abs() < pi / 2;
    }
  }

  void _separation(Boid boid) {
    var v = Offset.zero;
    var count = 0;

    for (final b in _boids) {
      final posDiff = b.position - boid.position;
      if (b != boid && posDiff.distance < 40) {
        v = v - (posDiff);
      }
      count += 1;
    }

    if (count > 0) {
      boid.velocity += v * config.separation;
    }
  }

  void _alignment(Boid boid) {
    var v = Offset.zero;
    var count = 0;

    for (final b in _boids) {
      if (b != boid && _isVisible(boid, b)) {
        v += b.velocity;
        count += 1;
      }
    }

    if (count > 0) {
      v = v / count.toDouble();
      boid.velocity += (v - boid.velocity) * config.alignment;
    }
  }

  void _cohesion(Boid boid) {
    var perceivedCentre = Offset.zero;
    var count = 0;

    for (final b in _boids) {
      if (b != boid && _isVisible(boid, b)) {
        perceivedCentre += b.position;
        count += 1;
      }
    }

    if (count > 0) {
      perceivedCentre = perceivedCentre / count.toDouble();
      boid.velocity += (perceivedCentre - boid.position) * config.cohesion;
    }
  }

  _bounding(Boid boid) {
    const double margin = 80;
    const double turningFactor = 2;
    var p = boid.position;
    if (p.dx < margin) {
      boid.velocity = boid.velocity.translate(turningFactor, 0);
    } else if (p.dx > size.width - margin) {
      boid.velocity = boid.velocity.translate(-turningFactor, 0);
    }

    if (p.dy < margin) {
      boid.velocity = boid.velocity.translate(0, turningFactor);
    } else if (p.dy > size.height - margin) {
      boid.velocity = boid.velocity.translate(0, -turningFactor);
    }

  }

  _limitSpeed(Boid boid) {
    var v = boid.velocity;
    if (v.dx.abs() > maxVelocity || v.dy.abs() > maxVelocity) {
      boid.velocity = Offset(
        v.dx.clamp(-maxVelocity, maxVelocity),
        v.dy.clamp(-maxVelocity, maxVelocity),
      );
    }
  }

  void computeStep(Duration deltaTime) {
    for (var b in _boids) {
      _cohesion(b);
      _alignment(b);
      _separation(b);
      _bounding(b);
      _limitSpeed(b);
      b.position += b.velocity * (deltaTime.inMilliseconds / 100);
    }
  }
}
