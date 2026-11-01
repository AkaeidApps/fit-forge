import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/gym_store.dart';
import '../core/responsive_content.dart';
import '../core/theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = GymStore.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        actions: [
          IconButton(
            tooltip: 'Add measurement',
            onPressed: () => _addMeasurement(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ResponsiveContent(
        maxWidth: 900,
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _summary(store),
              const SizedBox(height: 18),
              _weightChart(store),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Goals',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () => _addGoal(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add goal'),
                  ),
                ],
              ),
              for (final goal in store.goals) _goalCard(goal),
              const SizedBox(height: 18),
              const Text(
                'Measurement history',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              for (final measurement in store.measurements)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDarkGrey,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.monitor_weight_outlined,
                      color: AppTheme.primaryGreen,
                    ),
                    title: Text(
                      '${measurement.weightKg.toStringAsFixed(1)} kg',
                    ),
                    subtitle: Text(
                      'Waist ${measurement.waistCm.toStringAsFixed(1)} cm',
                    ),
                    trailing: Text(
                      '${measurement.recordedAt.month}/${measurement.recordedAt.day}/${measurement.recordedAt.year}',
                      style: const TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              const Text(
                'Workout history',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (store.workoutHistory.isEmpty)
                const Text(
                  'Finish a workout to start building your training history.',
                  style: TextStyle(color: AppTheme.textGrey),
                ),
              for (final workout in store.workoutHistory.take(5))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.fitness_center,
                    color: AppTheme.primaryGreen,
                  ),
                  title: Text(workout.planName),
                  subtitle: Text(
                    '${workout.exerciseCount} exercises · ${workout.setCount} sets',
                  ),
                  trailing: Text(
                    '${workout.completedAt.month}/${workout.completedAt.day}',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summary(GymStore store) {
    final latest = store.measurements.first;
    final previous = store.measurements.length > 1
        ? store.measurements[1]
        : latest;
    final change = latest.weightKg - previous.weightKg;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _metricCard(
          'Current weight',
          '${latest.weightKg.toStringAsFixed(1)} kg',
          Icons.monitor_weight_outlined,
        ),
        _metricCard(
          'Weight change',
          '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)} kg',
          Icons.show_chart,
        ),
        _metricCard(
          'This week',
          '${store.workoutsThisWeek} workouts',
          Icons.fitness_center,
        ),
      ],
    );
  }

  Widget _metricCard(String title, String value, IconData icon) => Container(
    constraints: const BoxConstraints(minWidth: 150),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTheme.cardDarkGrey,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryGreen),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
        ),
      ],
    ),
  );

  Widget _weightChart(GymStore store) {
    final history = store.measurements.reversed.toList();
    final spots = history.length == 1
        ? [FlSpot(0, history.first.weightKg)]
        : [
            for (var index = 0; index < history.length; index++)
              FlSpot(index.toDouble(), history[index].weightKg),
          ];
    final minY =
        history.map((item) => item.weightKg).reduce((a, b) => a < b ? a : b) -
        2;
    final maxY =
        history.map((item) => item.weightKg).reduce((a, b) => a > b ? a : b) +
        2;
    return Container(
      height: 245,
      padding: const EdgeInsets.fromLTRB(12, 16, 20, 12),
      decoration: BoxDecoration(
        color: AppTheme.cardDarkGrey,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Body weight trend',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                titlesData: const FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 36),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.primaryGreen,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _goalCard(FitnessGoal goal) {
    final done = goal.isComplete;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardDarkGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.flag_outlined,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  goal.current > 0
                      ? '${goal.current.toStringAsFixed(goal.current % 1 == 0 ? 0 : 1)} / ${goal.target}'
                      : 'Target: ${goal.target}',
                  style: const TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (done)
            const Text('Done', style: TextStyle(color: AppTheme.primaryGreen)),
        ],
      ),
    );
  }

  Future<void> _addMeasurement(BuildContext context) async {
    final weight = TextEditingController();
    final waist = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Record measurements'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _measurementField(weight, 'Weight (kg)'),
                _measurementField(waist, 'Waist (cm)'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (shouldSave == true) {
      GymStore.instance.addMeasurement(
        double.parse(weight.text),
        double.parse(waist.text),
      );
    }
  }

  Future<void> _addGoal(BuildContext context) async {
    final title = TextEditingController();
    final target = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create a goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Goal'),
                onChanged: (_) => setDialogState(() {}),
              ),
              TextField(
                controller: target,
                decoration: const InputDecoration(labelText: 'Target'),
                onChanged: (_) => setDialogState(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed:
                  title.text.trim().isNotEmpty && target.text.trim().isNotEmpty
                  ? () => Navigator.pop(dialogContext, true)
                  : null,
              child: const Text('Add goal'),
            ),
          ],
        ),
      ),
    );
    if (saved == true) {
      GymStore.instance.addGoal(title.text.trim(), target.text.trim());
    }
  }

  Widget _measurementField(TextEditingController controller, String label) =>
      TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          final amount = double.tryParse(value ?? '');
          return amount == null || amount <= 0
              ? 'Enter a value greater than zero'
              : null;
        },
      );
}
