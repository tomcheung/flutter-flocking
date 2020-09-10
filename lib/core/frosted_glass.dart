import 'dart:ui';

import 'package:flutter/material.dart';

class FrostedGlass extends StatelessWidget {
  final Widget child;
  final double blurRadius;

  FrostedGlass({this.child, this.blurRadius = 10});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: new BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
        child: child,
      ),
    );
  }
}
