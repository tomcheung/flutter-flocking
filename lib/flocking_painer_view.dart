import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'boids.dart';
import 'flocking_simulation.dart';

class FlockingPainterView extends StatefulWidget {
  final bool enable;
  final Widget child;
  final SimulationConfig config;

  const FlockingPainterView({Key key, this.enable = true, this.child, this.config})
      : super(key: key);

  @override
  _FlockingPainterViewState createState() => _FlockingPainterViewState();
}

class _FlockingPainterViewState extends State<FlockingPainterView> {
  FlockingSimulation _simulation;
  ValueNotifier<List<Boid>> _boidsValue;
  Ticker _ticker;
  Duration _lastTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _simulation = FlockingSimulation();
    _boidsValue = ValueNotifier(_simulation.bolds);
    _ticker = Ticker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    if (_simulation.bolds.isEmpty) {
      _simulation.init(size: size);
    } else {
      _simulation.size = size;
    }
    _updateState();
  }

  @override
  void didUpdateWidget(FlockingPainterView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateState();
  }

  void _updateState() {
    if (widget.enable && !_ticker.isActive) {
      _lastTime = Duration.zero;
      _ticker.start();
    } else if (!widget.enable && _ticker.isActive) {
      _ticker.stop();
    }

    _simulation.config = widget.config;
  }

  void _onTick(Duration time) {
    Duration dt = time - _lastTime;
    _simulation.computeStep(dt);
    _boidsValue.value = _simulation.bolds.toList(growable: false);
    // use toList to create a new array
    // otherwise putting same reference into ValueNotifier will cause nothing update
    _lastTime = time;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomPaint(
      foregroundPainter: _BoidsPainter(_boidsValue, color: theme.colorScheme.primary),
      child: widget.child
    );
  }
}

class _BoidsPainter extends CustomPainter {
  static const double boidSize = 12;
  final Paint _paint = Paint();
  final ValueListenable<List<Boid>> boidsListener;

  List<Boid> get boids => boidsListener.value;

  _BoidsPainter(this.boidsListener, {Color color = Colors.amber}) :super(repaint: boidsListener) {
    _paint.color = color;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var b in boids) {
      canvas.save();
      canvas.translate(b.position.dx, b.position.dy);

      if (b.velocity != Offset.zero) {
        final angle = atan2(b.velocity.dy, b.velocity.dx);
        canvas.rotate(angle);
      }

      const halfSize = boidSize / 2;
      final path = Path()
        ..moveTo(halfSize + 5, 0)
        ..lineTo(-halfSize, halfSize)
        ..lineTo(-halfSize, -halfSize)
        ..close();

      canvas.drawPath(path, _paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
