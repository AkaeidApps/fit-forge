import 'package:flutter/material.dart';

import '../core/gym_store.dart';
import '../core/responsive_content.dart';
import '../core/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = GymStore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ResponsiveContent(
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: AppTheme.cardDarkGrey,
                  child: Icon(Icons.person, size: 44, color: AppTheme.primaryGreen),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text('Jacob Jones', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const Center(child: Text('Bodybuilding · Demo athlete', style: TextStyle(color: AppTheme.textGrey))),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _statBox('${store.workoutHistory.length}', 'Sessions')),
                  const SizedBox(width: 8),
                  Expanded(child: _statBox('${store.caloriesToday}', 'Today kcal')),
                  const SizedBox(width: 8),
                  Expanded(child: _statBox('${store.goals.length}', 'Goals')),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Coaching tools', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _menuItem(
                context,
                Icons.flag_outlined,
                'My Goals',
                'Review your targets and current progress in the Progress tab.',
              ),
              _menuItem(
                context,
                Icons.list_alt,
                'My Plan',
                'Active plan: ${store.activePlanName} · ${store.activePlan.exercises.length} exercises. Manage plans in the Workout tab.',
              ),
              _menuItem(
                context,
                Icons.history,
                'Workout History',
                '${store.workoutHistory.length} completed workout${store.workoutHistory.length == 1 ? '' : 's'} logged.',
              ),
              const SizedBox(height: 16),
              const Text('Reminders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              for (final entry in store.reminders.entries)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(entry.key),
                  subtitle: Text(entry.value ? 'Reminder enabled' : 'Reminder disabled'),
                  value: entry.value,
                  activeThumbColor: AppTheme.primaryGreen,
                  onChanged: (value) => store.setReminder(entry.key, value),
                ),
              const SizedBox(height: 16),
              const Text('Daily targets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _targetTile(
                'Calories',
                '${store.dailyCalorieTarget} kcal',
                () => _editTarget(context, 'Daily calorie target', store.dailyCalorieTarget, (value) {
                  store.updateTargets(calories: value);
                }),
              ),
              _targetTile(
                'Protein',
                '${store.dailyProteinTarget} g',
                () => _editTarget(context, 'Daily protein target', store.dailyProteinTarget, (value) {
                  store.updateTargets(protein: value);
                }),
              ),
              const SizedBox(height: 12),
              _menuItem(
                context,
                Icons.info_outline,
                'Data & Privacy',
                'This demo keeps workout, food, goal, and measurement data in memory on this device. Data resets when the app process is restarted; no account or cloud sync is connected.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statBox(String value, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
    decoration: BoxDecoration(color: AppTheme.cardDarkGrey, borderRadius: BorderRadius.circular(15)),
    child: Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
      ],
    ),
  );

  Widget _menuItem(BuildContext context, IconData icon, String title, String detail) =>
      ListTile(
        leading: Icon(icon, color: AppTheme.primaryGreen),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        contentPadding: EdgeInsets.zero,
        onTap: () => showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(title),
            content: Text(detail),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close')),
            ],
          ),
        ),
      );

  Widget _targetTile(String title, String value, VoidCallback onTap) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(title),
    subtitle: Text(value, style: const TextStyle(color: AppTheme.textGrey)),
    trailing: const Icon(Icons.edit_outlined, color: AppTheme.primaryGreen),
    onTap: onTap,
  );

  Future<void> _editTarget(
    BuildContext context,
    String title,
    int current,
    ValueChanged<int> onSave,
  ) async {
    final controller = TextEditingController(text: current.toString());
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Target'),
            validator: (value) {
              final amount = int.tryParse(value ?? '');
              return amount == null || amount <= 0 ? 'Enter a value greater than zero' : null;
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
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
    if (saved == true) onSave(int.parse(controller.text));
  }
}
