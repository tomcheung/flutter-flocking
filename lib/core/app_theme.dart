import 'package:flutter/material.dart';

enum AppThemeType { light, dark }

class AppTheme {
  final AppThemeType currentTheme;
  final void Function(AppThemeType newTheme) _onThemeUpdate;

  AppTheme._(this.currentTheme, this._onThemeUpdate);

  setTheme(AppThemeType newTheme) {
    _onThemeUpdate(newTheme);
  }

  static AppTheme of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedAppTheme>()
        .theme;
  }
}

typedef ThemeWidgetBuilder = Widget Function(
    BuildContext context, Widget child, AppThemeType theme);

class AppThemeSwitcher extends StatefulWidget {
  final Widget child;
  final ThemeWidgetBuilder builder;

  const AppThemeSwitcher({@required this.builder, this.child});

  @override
  _AppThemeSwitcherState createState() => _AppThemeSwitcherState();
}

class _AppThemeSwitcherState extends State<AppThemeSwitcher> {
  AppTheme appTheme;

  @override
  void initState() {
    appTheme = AppTheme._(AppThemeType.dark, _updateTheme);
    super.initState();
  }

  _updateTheme(AppThemeType theme) {
    setState(() {
      appTheme = AppTheme._(theme, _updateTheme);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedAppTheme(
      appTheme,
      child: widget.builder(context, widget.child, appTheme.currentTheme),
    );
  }
}

class _InheritedAppTheme extends InheritedWidget {
  final AppTheme theme;

  _InheritedAppTheme(this.theme, {Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    if (oldWidget is _InheritedAppTheme) {
      return oldWidget.theme != this.theme || oldWidget.child != this.child;
    } else {
      return true;
    }
  }
}
