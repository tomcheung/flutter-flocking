import 'package:flock_simulation/core/app_theme.dart';
import 'package:flock_simulation/boids.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static final themeMapping = {
    AppThemeType.light: ThemeData.from(
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.orange,
        backgroundColor: Colors.white,
      ),
    ),
    AppThemeType.dark: ThemeData.from(
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.amber,
        backgroundColor: Colors.black,
        brightness: Brightness.dark,
      ),
    )
  };
  var _showSetting = true;

  @override
  Widget build(BuildContext context) {
    return AppThemeSwitcher(
      child: Scaffold(
        body: FlockingView(showSettings: _showSetting),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _showSetting = !_showSetting;
            });
          },
          child: Icon(Icons.settings),
        ),
      ),
      builder: (context, child, theme) {
        return MaterialApp(
          title: 'Flock Demo',
          theme: themeMapping[theme],
          home: child,
        );
      },
    );
  }
}
