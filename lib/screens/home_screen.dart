import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../core/gym_store.dart';
import '../core/responsive_content.dart';
import '../core/theme.dart';
import 'nutrition_screen.dart';
import 'workout_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = GymStore.instance;
    return Scaffold(
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) => ResponsiveContent(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      CircleAvatar(child: Icon(Icons.person)),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Morning',
                            style: TextStyle(
                              color: AppTheme.textGrey,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Jacob Jones',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    tooltip: 'Notifications',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('You are all caught up!')),
                      );
                    },
                    icon: const Icon(Icons.notifications_none),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _StreakBanner(streakDays: store.workoutsThisWeek),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stats = Column(
                    children: [
                      _statRow(
                        'Calories',
                        '${store.caloriesToday} / ${store.dailyCalorieTarget}',
                        Colors.orange,
                      ),
                      _statRow(
                        'Protein',
                        '${store.proteinToday} / ${store.dailyProteinTarget}g',
                        Colors.purple,
                      ),
                      _statRow('Workouts', '${store.workoutsThisWeek} / 4 this week', Colors.blue),
                    ],
                  );
                  return _HomeCard(
                    child: constraints.maxWidth < 380
                        ? Column(
                            children: [
                              _ProgressRing(
                                progress: (store.caloriesToday / store.dailyCalorieTarget)
                                    .clamp(0.0, 1.0),
                              ),
                              const SizedBox(height: 12),
                              stats,
                            ],
                          )
                        : Row(
                            children: [
                              _ProgressRing(
                                progress:
                                    (store.caloriesToday / store.dailyCalorieTarget)
                                        .clamp(0.0, 1.0),
                              ),
                              const SizedBox(width: 20),
                              Expanded(child: stats),
                            ],
                          ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NutritionScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.restaurant_menu),
                  label: const Text('Nutrition details'),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Today's Workout",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              _WorkoutCard(
                duration: '45 min',
                title: store.activePlanName,
                exerciseCount: store.activePlan.exercises.length,
                onStart: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WorkoutScreen(),
                  ),
                ),
              ),
            ],
            ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statRow(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(Icons.circle, color: color, size: 12),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDarkGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.progress})
    : assert(progress >= 0 && progress <= 1);

  final double progress;

  @override
  Widget build(BuildContext context) {
    const size = 100.0;
    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: size * 0.38,
              startDegreeOffset: -90,
              sections: [
                PieChartSectionData(
                  color: AppTheme.primaryGreen,
                  value: progress,
                  radius: size * 0.1,
                  showTitle: false,
                ),
                PieChartSectionData(
                  color: AppTheme.backgroundBlack,
                  value: 1 - progress,
                  radius: size * 0.1,
                  showTitle: false,
                ),
              ],
            ),
          ),
          Text(
            '${(progress * 100).round()}%',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
    );
  }
}

class _StreakBanner extends StatelessWidget {
  const _StreakBanner({required this.streakDays});

  final int streakDays;

  @override
  Widget build(BuildContext context) {
    return _HomeCard(
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: AppTheme.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$streakDays-day streak! Keep showing up.',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({
    required this.title,
    required this.duration,
    required this.exerciseCount,
    required this.onStart,
  });

  final String title;
  final String duration;
  final int exerciseCount;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final workoutInfo = Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: AppTheme.backgroundBlack,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$duration • $exerciseCount exercises',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        final startButton = ElevatedButton(
          onPressed: onStart,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 14),
          ),
          child: const Text('Start'),
        );

        return _HomeCard(
          child: constraints.maxWidth < 360
              ? Column(
                  children: [
                    workoutInfo,
                    const SizedBox(height: 12),
                    SizedBox(width: double.infinity, child: startButton),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: workoutInfo),
                    const SizedBox(width: 8),
                    startButton,
                  ],
                ),
        );
      },
    );
  }
}
