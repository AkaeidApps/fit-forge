import 'dart:async';

import 'package:flutter/material.dart';

import '../core/gym_store.dart';
import '../core/responsive_content.dart';
import '../core/theme.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final GymStore _store = GymStore.instance;
  Timer? _restTimer;
  int _restSeconds = 0;
  String _exerciseFilter = 'All';

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Workout'),
          actions: [
            IconButton(
              tooltip: 'Create a training plan',
              onPressed: _createPlan,
              icon: const Icon(Icons.add),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: 'Training'),
              Tab(text: 'Plans'),
              Tab(text: 'Exercises'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: ResponsiveContent(
          child: AnimatedBuilder(
            animation: _store,
            builder: (context, _) => TabBarView(
              children: [
                _trainingTab(),
                _plansTab(),
                _exerciseLibraryTab(),
                _historyTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _trainingTab() {
    final plan = _store.activePlan;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                plan.focus,
                style: const TextStyle(color: AppTheme.textGrey),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text('${plan.exercises.length} exercises')),
                  Chip(label: Text('${_store.completedSetsToday} sets logged')),
                  if (_store.workoutInProgress)
                    const Chip(
                      avatar: Icon(
                        Icons.circle,
                        size: 10,
                        color: AppTheme.primaryGreen,
                      ),
                      label: Text('In progress'),
                    ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: _store.workoutInProgress
                        ? null
                        : () {
                            _store.startWorkout();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Workout started')),
                            );
                          },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start workout'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _store.workoutInProgress
                        ? _store.toggleWorkoutPause
                        : null,
                    icon: Icon(
                      _store.workoutPaused ? Icons.play_arrow : Icons.pause,
                    ),
                    label: Text(_store.workoutPaused ? 'Resume' : 'Pause'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _store.workoutInProgress ? _finishWorkout : null,
                    icon: const Icon(Icons.flag),
                    label: const Text('Finish'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          child: Row(
            children: [
              const Icon(Icons.timer_outlined, color: AppTheme.primaryGreen),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _restSeconds > 0
                      ? 'Rest timer  ${_formatTime(_restSeconds)}'
                      : 'Rest timer ready',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: _restSeconds > 0 ? _stopRestTimer : _startRestTimer,
                child: Text(_restSeconds > 0 ? 'Stop' : 'Start 90s'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Exercises (${plan.exercises.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        for (final exercise in plan.exercises) _exerciseLoggingCard(exercise),
        if (plan.exercises.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'This plan has no exercises yet. Add exercises in the plan builder.',
            ),
          ),
      ],
    );
  }

  Widget _exerciseLoggingCard(Exercise exercise) {
    return _sectionCard(
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _exerciseArtwork(exercise, size: 58),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${exercise.muscleGroup} · ${exercise.equipment} · ${exercise.repRange}',
                      style: const TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: List.generate(exercise.defaultSets, (index) {
              final setNumber = index + 1;
              LoggedSet? setLog;
              for (final entry in _store.activeSetLogs) {
                if (entry.exerciseName == exercise.name &&
                    entry.setNumber == setNumber) {
                  setLog = entry;
                  break;
                }
              }
              return FilterChip(
                label: Text(
                  setLog == null
                      ? 'Set $setNumber'
                      : 'Set $setNumber · ${setLog.weightKg}kg × ${setLog.reps}',
                ),
                selected: setLog != null,
                onSelected: (selected) => selected
                    ? _logSet(exercise, setNumber)
                    : _store.removeCompletedSet(exercise.name, setNumber),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _plansTab() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      FilledButton.icon(
        onPressed: _createPlan,
        icon: const Icon(Icons.add),
        label: const Text('Build a custom plan'),
      ),
      const SizedBox(height: 12),
      for (final plan in _store.plans)
        _sectionCard(
          margin: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                plan.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${plan.focus}\n${plan.exercises.length} exercises',
              ),
              isThreeLine: true,
              leading: _planArtwork(plan, size: 52),
              trailing: _store.activePlanName == plan.name
                  ? const Icon(Icons.check_circle, color: AppTheme.primaryGreen)
                  : const Icon(Icons.chevron_right),
              onTap: () {
                _store.selectPlan(plan.name);
                DefaultTabController.of(context).animateTo(0);
              },
            ),
          ),
        ),
    ],
  );

  Widget _exerciseLibraryTab() {
    final groups = [
      'All',
      ..._store.exerciseLibrary.map((e) => e.muscleGroup).toSet(),
    ];
    final exercises = _store.exerciseLibrary
        .where(
          (exercise) =>
              _exerciseFilter == 'All' ||
              exercise.muscleGroup == _exerciseFilter,
        )
        .toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<String>(
          initialValue: _exerciseFilter,
          decoration: const InputDecoration(
            labelText: 'Filter by muscle group',
          ),
          items: groups
              .map(
                (group) => DropdownMenuItem(value: group, child: Text(group)),
              )
              .toList(),
          onChanged: (value) =>
              setState(() => _exerciseFilter = value ?? 'All'),
        ),
        const SizedBox(height: 8),
        for (final exercise in exercises)
          _sectionCard(
            margin: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _exerciseArtwork(exercise, size: 52),
                title: Text(exercise.name),
                subtitle: Text(
                  '${exercise.muscleGroup} · ${exercise.equipment} · ${exercise.defaultSets} sets · ${exercise.repRange}',
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _historyTab() => AnimatedBuilder(
    animation: _store,
    builder: (context, _) => _store.workoutHistory.isEmpty
        ? const Center(child: Text('Completed workouts will appear here.'))
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final log in _store.workoutHistory)
                _sectionCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryGreen,
                      ),
                      title: Text(log.planName),
                      subtitle: Text(
                        '${log.exerciseCount} exercises · ${log.setCount} sets',
                      ),
                      trailing: Text(_formatDate(log.completedAt)),
                      children: [
                        for (final set in log.setLogs)
                          ListTile(
                            dense: true,
                            title: Text(
                              '${set.exerciseName} · Set ${set.setNumber}',
                            ),
                            trailing: Text('${set.weightKg} kg × ${set.reps}'),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
  );

  Widget _sectionCard({required Widget child, EdgeInsets? margin}) => Container(
    margin: margin,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTheme.cardDarkGrey,
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );

  Widget _exerciseArtwork(Exercise exercise, {required double size}) {
    final imageUrl = _imageForMuscleGroup(exercise.muscleGroup);
    final icon = _iconForMuscleGroup(exercise.muscleGroup);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          semanticLabel: '${exercise.muscleGroup} workout image',
          errorBuilder: (context, error, stackTrace) => ColoredBox(
            color: AppTheme.backgroundBlack,
            child: Icon(icon, color: AppTheme.primaryGreen, size: size * 0.48),
          ),
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) return child;
            return ColoredBox(
              color: AppTheme.backgroundBlack,
              child: Icon(
                icon,
                color: AppTheme.primaryGreen,
                size: size * 0.48,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _planArtwork(WorkoutPlan plan, {required double size}) {
    final focus = plan.focus.toLowerCase();
    final group = focus.contains('back')
        ? 'Back'
        : focus.contains('leg') || focus.contains('quad')
        ? 'Legs'
        : focus.contains('chest') || focus.contains('push')
        ? 'Chest'
        : 'Arms';
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              _imageForMuscleGroup(group),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: AppTheme.backgroundBlack,
                child: Icon(
                  _iconForMuscleGroup(group),
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppTheme.backgroundBlack,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconForMuscleGroup(group),
                  size: 16,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _imageForMuscleGroup(String muscleGroup) {
    final group = muscleGroup.toLowerCase();
    if (group.contains('chest')) {
      return 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=240&h=240&q=80';
    }
    if (group.contains('back')) {
      return 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?auto=format&fit=crop&w=240&h=240&q=80';
    }
    if (group.contains('shoulder')) {
      return 'https://images.unsplash.com/photo-1534367610401-9f5ed68180aa?auto=format&fit=crop&w=240&h=240&q=80';
    }
    if (group.contains('leg') || group.contains('hamstring')) {
      return 'https://images.unsplash.com/photo-1579758629938-03607ccdbaba?auto=format&fit=crop&w=240&h=240&q=80';
    }
    return 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?auto=format&fit=crop&w=240&h=240&q=80';
  }

  IconData _iconForMuscleGroup(String muscleGroup) {
    final group = muscleGroup.toLowerCase();
    if (group.contains('chest')) return Icons.accessibility_new;
    if (group.contains('back')) return Icons.airline_seat_recline_extra;
    if (group.contains('shoulder')) return Icons.fitness_center;
    if (group.contains('leg') || group.contains('hamstring')) {
      return Icons.directions_run;
    }
    return Icons.sports_gymnastics;
  }

  Future<void> _createPlan() async {
    final nameController = TextEditingController();
    final selected = <Exercise>{};
    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Build a training plan'),
          content: SizedBox(
            width: 420,
            height: (MediaQuery.sizeOf(context).height * 0.5).clamp(
              200.0,
              380.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Plan name'),
                  onChanged: (_) => setDialogState(() {}),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: _store.exerciseLibrary.map((exercise) {
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(exercise.name),
                        subtitle: Text(exercise.muscleGroup),
                        value: selected.contains(exercise),
                        onChanged: (value) => setDialogState(() {
                          if (value ?? false) {
                            selected.add(exercise);
                          } else {
                            selected.remove(exercise);
                          }
                        }),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed:
                  nameController.text.trim().isNotEmpty && selected.isNotEmpty
                  ? () => Navigator.pop(dialogContext, true)
                  : null,
              child: const Text('Create plan'),
            ),
          ],
        ),
      ),
    );
    if (created == true && mounted) {
      _store.addPlan(nameController.text.trim(), selected.toList());
      _store.selectPlan(nameController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${nameController.text.trim()} created')),
      );
    }
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    setState(() => _restSeconds = 90);
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _restSeconds <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() => _restSeconds = 0);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rest complete — ready for your next set'),
            ),
          );
        }
      } else {
        setState(() => _restSeconds--);
      }
    });
  }

  void _stopRestTimer() {
    _restTimer?.cancel();
    setState(() => _restSeconds = 0);
  }

  void _finishWorkout() {
    final sets = _store.completedSetsToday;
    _store.finishWorkout();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sets == 0 ? 'Workout ended' : 'Workout saved · $sets sets logged',
        ),
      ),
    );
  }

  Future<void> _logSet(Exercise exercise, int setNumber) async {
    final weightController = TextEditingController();
    final repsController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${exercise.name} · Set $setNumber'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                validator: (value) {
                  final amount = double.tryParse(value ?? '');
                  return amount == null || amount < 0
                      ? 'Enter a valid weight'
                      : null;
                },
              ),
              TextFormField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Reps'),
                validator: (value) {
                  final amount = int.tryParse(value ?? '');
                  return amount == null || amount <= 0
                      ? 'Enter a valid rep count'
                      : null;
                },
              ),
            ],
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
            child: const Text('Log set'),
          ),
        ],
      ),
    );
    if (saved == true && mounted) {
      _store.addCompletedSet(
        exerciseName: exercise.name,
        setNumber: setNumber,
        weightKg: double.parse(weightController.text),
        reps: int.parse(repsController.text),
      );
      _startRestTimer();
    }
  }

  static String _formatTime(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

  static String _formatDate(DateTime date) => '${date.month}/${date.day}';
}
