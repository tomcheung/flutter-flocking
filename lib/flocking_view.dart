import 'package:flock_simulation/core/app_theme.dart';
import 'package:flock_simulation/core/frosted_glass.dart';
import 'package:flutter/material.dart';

import 'flocking_painer_view.dart';
import 'flocking_simulation.dart';

class FlockingView extends StatefulWidget {
  final bool showSettings;

  FlockingView({this.showSettings = true});

  @override
  _FlockingViewState createState() => _FlockingViewState();
}

class _FlockingViewState extends State<FlockingView> {
  bool _isActive = true;
  SimulationConfig simulationConfig = SimulationConfig();
  Key _painterKey = UniqueKey();

  _onRunToggleChange(bool value) {
    setState(() {
      _isActive = value;
    });
  }

  _resetSimulation() {
    setState(() {
      // Force flutter dispose the old widget state by assign a new widget key
      _painterKey = UniqueKey();
    });
  }

  TableRow _buildOption(
          String title, double value, ValueChanged<double> handler,
          {double min = 0, double max = 0.1}) =>
      TableRow(children: [
        Text('$title: ${value.toStringAsPrecision(3)}'),
        Slider(
          value: value,
          onChanged: (v) {
            setState(() {
              handler(v);
            });
          },
          min: min,
          max: max,
        ),
      ]);

  List<TableRow> _buildOptions(BuildContext context) {
    var appTheme = AppTheme.of(context);
    var onThemeChange = (AppThemeType theme) {
      appTheme.setTheme(theme);
    };

    return [
      TableRow(children: [
        const Text('Run'),
        Checkbox(value: _isActive, onChanged: _onRunToggleChange),
      ]),
      _buildOption('Visible Range', simulationConfig.visibleRange, (value) {
        simulationConfig.visibleRange = value;
      }, min: 10, max: 200),
      _buildOption('Separation Speed', simulationConfig.separation, (value) {
        simulationConfig.separation = value;
      }),
      _buildOption('Alignment', simulationConfig.alignment, (value) {
        simulationConfig.alignment = value;
      }),
      _buildOption('Cohesion', simulationConfig.cohesion, (value) {
        simulationConfig.cohesion = value;
      }),
      TableRow(children: [
        const Text('Theme'),
        Row(
          children: [
            Radio(
              groupValue: appTheme.currentTheme,
              value: AppThemeType.light,
              onChanged: onThemeChange,
            ),
            const Text('Light'),
            Radio(
              groupValue: appTheme.currentTheme,
              value: AppThemeType.dark,
              onChanged: onThemeChange,
            ),
            const Text('Dark')
          ],
        )
      ]),
      TableRow(children: [
        const SizedBox.shrink(),
        RaisedButton(
          child: Text('Reset'),
          onPressed: _resetSimulation,
        )
      ])
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        FlockingPainterView(
          key: _painterKey,
          enable: _isActive,
          child: Container(),
          config: simulationConfig,
        ),
        if (widget.showSettings)
          Positioned(
            bottom: 80,
            right: 12,
            child: FrostedGlass(
              blurRadius: 6,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: theme.backgroundColor.withOpacity(0.5),
                child: Table(
                  defaultColumnWidth: const MaxColumnWidth(
                    FixedColumnWidth(80),
                    IntrinsicColumnWidth(),
                  ),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: _buildOptions(context),
                ),
              ),
            ),
          )
      ],
    );
  }
}
