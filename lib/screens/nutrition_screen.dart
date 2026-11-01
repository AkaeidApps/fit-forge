import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/gym_store.dart';
import '../core/responsive_content.dart';
import '../core/theme.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  static final _quickMeals = <MealEntry>[
    MealEntry(
      name: 'Chicken & rice',
      calories: 520,
      protein: 42,
      carbs: 58,
      fat: 12,
      loggedAt: DateTime(2000),
    ),
    MealEntry(
      name: 'Protein oatmeal',
      calories: 420,
      protein: 30,
      carbs: 55,
      fat: 10,
      loggedAt: DateTime(2000),
    ),
    MealEntry(
      name: 'Greek yogurt bowl',
      calories: 280,
      protein: 25,
      carbs: 32,
      fat: 6,
      loggedAt: DateTime(2000),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final store = GymStore.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
        actions: [
          IconButton(
            tooltip: 'Log custom meal',
            onPressed: () => _addCustomMeal(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ResponsiveContent(
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _nutritionSummary(store),
              const SizedBox(height: 22),
              const Text(
                'Quick add meal',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              for (final meal in _quickMeals) _mealRow(context, meal, store),
              const SizedBox(height: 20),
              const Text(
                "Today's food log",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              if (store.meals.where((meal) => _isToday(meal.loggedAt)).isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Text(
                    'No meals logged yet. Add a quick meal or create your own entry.',
                    style: TextStyle(color: AppTheme.textGrey),
                  ),
                ),
              for (final meal in store.meals.where((meal) => _isToday(meal.loggedAt)))
                _loggedMeal(meal),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nutritionSummary(GymStore store) {
    final caloriesProgress =
        (store.caloriesToday / store.dailyCalorieTarget).clamp(0.0, 1.0);
    final remaining = (store.dailyCalorieTarget - store.caloriesToday).clamp(
      0,
      store.dailyCalorieTarget,
    );
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardDarkGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 43,
                        sections: [
                          PieChartSectionData(
                            color: AppTheme.primaryGreen,
                            value: store.caloriesToday.toDouble().clamp(1, double.infinity),
                            radius: 12,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            color: AppTheme.textGrey.withValues(alpha: 0.22),
                            value: (store.dailyCalorieTarget - store.caloriesToday)
                                .clamp(0, store.dailyCalorieTarget)
                                .toDouble()
                                .clamp(1, double.infinity),
                            radius: 12,
                            showTitle: false,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${store.caloriesToday}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Text('kcal', style: TextStyle(color: AppTheme.textGrey)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Daily calories', style: TextStyle(color: AppTheme.textGrey)),
                    const SizedBox(height: 5),
                    Text(
                      '$remaining kcal remaining',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: caloriesProgress,
                      color: AppTheme.primaryGreen,
                      backgroundColor: AppTheme.backgroundBlack,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          _macroProgress('Protein', store.proteinToday, store.dailyProteinTarget, 'g', AppTheme.primaryGreen),
          _macroProgress('Carbs', _todayMacro(store, (meal) => meal.carbs), 280, 'g', Colors.orange),
          _macroProgress('Fat', _todayMacro(store, (meal) => meal.fat), 75, 'g', Colors.purple),
        ],
      ),
    );
  }

  Widget _macroProgress(
    String title,
    int current,
    int target,
    String unit,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(width: 65, child: Text(title, style: const TextStyle(color: AppTheme.textGrey))),
          Expanded(
            child: LinearProgressIndicator(
              value: (current / target).clamp(0.0, 1.0),
              color: color,
              backgroundColor: AppTheme.backgroundBlack,
            ),
          ),
          const SizedBox(width: 10),
          Text('$current / $target$unit', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _mealRow(BuildContext context, MealEntry meal, GymStore store) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardDarkGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.restaurant, color: AppTheme.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  '${meal.calories} kcal · ${meal.protein}g protein · ${meal.carbs}g carbs · ${meal.fat}g fat',
                  style: const TextStyle(color: AppTheme.textGrey, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Add ${meal.name} to today’s log',
            onPressed: () {
              store.addMeal(
                MealEntry(
                  name: meal.name,
                  calories: meal.calories,
                  protein: meal.protein,
                  carbs: meal.carbs,
                  fat: meal.fat,
                  loggedAt: DateTime.now(),
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${meal.name} added to today’s log')),
              );
            },
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryGreen),
          ),
        ],
      ),
    );
  }

  Widget _loggedMeal(MealEntry meal) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    leading: const CircleAvatar(
      backgroundColor: AppTheme.cardDarkGrey,
      child: Icon(Icons.restaurant, color: AppTheme.primaryGreen),
    ),
    title: Text(meal.name),
    subtitle: Text('${meal.calories} kcal · P ${meal.protein}g · C ${meal.carbs}g · F ${meal.fat}g'),
    trailing: Text(
      '${meal.loggedAt.hour.toString().padLeft(2, '0')}:${meal.loggedAt.minute.toString().padLeft(2, '0')}',
      style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
    ),
  );

  Future<void> _addCustomMeal(BuildContext context) async {
    final name = TextEditingController();
    final calories = TextEditingController();
    final protein = TextEditingController();
    final carbs = TextEditingController();
    final fat = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final submit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log a meal'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Meal name'), validator: (value) => value == null || value.trim().isEmpty ? 'Enter a meal name' : null),
                _numberField(calories, 'Calories'),
                _numberField(protein, 'Protein (g)'),
                _numberField(carbs, 'Carbs (g)'),
                _numberField(fat, 'Fat (g)'),
              ],
            ),
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
            child: const Text('Add meal'),
          ),
        ],
      ),
    );
    if (submit == true) {
      GymStore.instance.addMeal(
        MealEntry(
          name: name.text.trim(),
          calories: int.parse(calories.text),
          protein: int.parse(protein.text),
          carbs: int.parse(carbs.text),
          fat: int.parse(fat.text),
          loggedAt: DateTime.now(),
        ),
      );
    }
  }

  Widget _numberField(TextEditingController controller, String label) =>
      TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
        validator: (value) => int.tryParse(value ?? '') == null || int.parse(value!) < 0
            ? 'Enter a valid amount'
            : null,
      );

  static int _todayMacro(GymStore store, int Function(MealEntry) select) =>
      store.meals.where((meal) => _isToday(meal.loggedAt)).fold(0, (total, meal) => total + select(meal));

  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
