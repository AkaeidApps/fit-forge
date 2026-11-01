import 'package:flutter/foundation.dart';

class Exercise {
  const Exercise({
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    required this.defaultSets,
    required this.repRange,
  });

  final String name;
  final String muscleGroup;
  final String equipment;
  final int defaultSets;
  final String repRange;
}

class WorkoutPlan {
  WorkoutPlan({
    required this.name,
    required this.focus,
    required this.exercises,
    this.isCustom = false,
  });

  final String name;
  final String focus;
  final List<Exercise> exercises;
  final bool isCustom;
}

class WorkoutLog {
  const WorkoutLog({
    required this.planName,
    required this.completedAt,
    required this.exerciseCount,
    required this.setCount,
    required this.setLogs,
  });

  final String planName;
  final DateTime completedAt;
  final int exerciseCount;
  final int setCount;
  final List<LoggedSet> setLogs;
}

class LoggedSet {
  const LoggedSet({
    required this.exerciseName,
    required this.setNumber,
    required this.weightKg,
    required this.reps,
  });

  final String exerciseName;
  final int setNumber;
  final double weightKg;
  final int reps;
}

class MealEntry {
  const MealEntry({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.loggedAt,
  });

  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final DateTime loggedAt;
}

class BodyMeasurement {
  const BodyMeasurement({
    required this.weightKg,
    required this.waistCm,
    required this.recordedAt,
  });

  final double weightKg;
  final double waistCm;
  final DateTime recordedAt;
}

class FitnessGoal {
  FitnessGoal({
    required this.title,
    required this.target,
    this.current = 0,
    this.isComplete = false,
  });

  final String title;
  final String target;
  double current;
  bool isComplete;
}

class GymStore extends ChangeNotifier {
  GymStore._();

  static final GymStore instance = GymStore._();

  final List<Exercise> exerciseLibrary = const [
    Exercise(
      name: 'Barbell Bench Press',
      muscleGroup: 'Chest',
      equipment: 'Barbell',
      defaultSets: 4,
      repRange: '6–10 reps',
    ),
    Exercise(
      name: 'Incline Dumbbell Press',
      muscleGroup: 'Chest',
      equipment: 'Dumbbells',
      defaultSets: 3,
      repRange: '8–12 reps',
    ),
    Exercise(
      name: 'Lat Pulldown',
      muscleGroup: 'Back',
      equipment: 'Cable',
      defaultSets: 4,
      repRange: '8–12 reps',
    ),
    Exercise(
      name: 'Barbell Row',
      muscleGroup: 'Back',
      equipment: 'Barbell',
      defaultSets: 4,
      repRange: '6–10 reps',
    ),
    Exercise(
      name: 'Dumbbell Shoulder Press',
      muscleGroup: 'Shoulders',
      equipment: 'Dumbbells',
      defaultSets: 3,
      repRange: '8–12 reps',
    ),
    Exercise(
      name: 'Lateral Raise',
      muscleGroup: 'Shoulders',
      equipment: 'Dumbbells',
      defaultSets: 3,
      repRange: '12–15 reps',
    ),
    Exercise(
      name: 'Barbell Squat',
      muscleGroup: 'Legs',
      equipment: 'Barbell',
      defaultSets: 4,
      repRange: '6–10 reps',
    ),
    Exercise(
      name: 'Romanian Deadlift',
      muscleGroup: 'Hamstrings',
      equipment: 'Barbell',
      defaultSets: 3,
      repRange: '8–12 reps',
    ),
    Exercise(
      name: 'Dumbbell Curl',
      muscleGroup: 'Arms',
      equipment: 'Dumbbells',
      defaultSets: 3,
      repRange: '10–15 reps',
    ),
    Exercise(
      name: 'Cable Triceps Pushdown',
      muscleGroup: 'Arms',
      equipment: 'Cable',
      defaultSets: 3,
      repRange: '10–15 reps',
    ),
  ];

  late final List<WorkoutPlan> plans = [
    WorkoutPlan(
      name: 'Push Day',
      focus: 'Chest · Shoulders · Triceps',
      exercises: [
        GymStore._exercise('Barbell Bench Press'),
        GymStore._exercise('Incline Dumbbell Press'),
        GymStore._exercise('Dumbbell Shoulder Press'),
        GymStore._exercise('Lateral Raise'),
        GymStore._exercise('Cable Triceps Pushdown'),
      ],
    ),
    WorkoutPlan(
      name: 'Pull Day',
      focus: 'Back · Rear delts · Biceps',
      exercises: [
        GymStore._exercise('Lat Pulldown'),
        GymStore._exercise('Barbell Row'),
        GymStore._exercise('Dumbbell Curl'),
      ],
    ),
    WorkoutPlan(
      name: 'Leg Day',
      focus: 'Quads · Hamstrings · Glutes',
      exercises: [
        GymStore._exercise('Barbell Squat'),
        GymStore._exercise('Romanian Deadlift'),
      ],
    ),
  ];

  final List<WorkoutLog> workoutHistory = [];
  final List<LoggedSet> activeSetLogs = [];
  final List<MealEntry> meals = [];
  final List<BodyMeasurement> measurements = [
    BodyMeasurement(weightKg: 75.5, waistCm: 82, recordedAt: DateTime.now()),
  ];
  final List<FitnessGoal> goals = [
    FitnessGoal(title: 'Daily protein', target: '160 g', current: 0),
    FitnessGoal(title: 'Train this week', target: '4 sessions', current: 0),
    FitnessGoal(title: 'Body weight', target: '72 kg', current: 75.5),
  ];
  final Map<String, bool> reminders = {
    'Workout reminder': true,
    'Meal logging reminder': false,
    'Weekly progress check-in': true,
  };

  static Exercise _exercise(String name) =>
      instance.exerciseLibrary.firstWhere((exercise) => exercise.name == name);

  String activePlanName = 'Push Day';
  int completedSetsToday = 0;
  bool workoutInProgress = false;
  bool workoutPaused = false;
  int dailyCalorieTarget = 2500;
  int dailyProteinTarget = 160;

  int get caloriesToday => meals
      .where((meal) => _isToday(meal.loggedAt))
      .fold(0, (total, meal) => total + meal.calories);

  int get proteinToday => meals
      .where((meal) => _isToday(meal.loggedAt))
      .fold(0, (total, meal) => total + meal.protein);

  int get workoutsThisWeek => workoutHistory
      .where((log) => DateTime.now().difference(log.completedAt).inDays < 7)
      .length;

  WorkoutPlan get activePlan =>
      plans.firstWhere((plan) => plan.name == activePlanName);

  void selectPlan(String name) {
    activePlanName = name;
    workoutInProgress = false;
    workoutPaused = false;
    completedSetsToday = 0;
    activeSetLogs.clear();
    notifyListeners();
  }

  void startWorkout() {
    workoutInProgress = true;
    workoutPaused = false;
    completedSetsToday = 0;
    activeSetLogs.clear();
    notifyListeners();
  }

  void addCompletedSet({
    required String exerciseName,
    required int setNumber,
    required double weightKg,
    required int reps,
  }) {
    activeSetLogs.add(
      LoggedSet(
        exerciseName: exerciseName,
        setNumber: setNumber,
        weightKg: weightKg,
        reps: reps,
      ),
    );
    completedSetsToday++;
    workoutInProgress = true;
    notifyListeners();
  }

  void removeCompletedSet(String exerciseName, int setNumber) {
    activeSetLogs.removeWhere(
      (log) =>
          log.exerciseName == exerciseName && log.setNumber == setNumber,
    );
    completedSetsToday = activeSetLogs.length;
    notifyListeners();
  }

  void toggleWorkoutPause() {
    workoutPaused = !workoutPaused;
    notifyListeners();
  }

  void finishWorkout() {
    if (completedSetsToday > 0) {
      workoutHistory.insert(
        0,
        WorkoutLog(
          planName: activePlanName,
          completedAt: DateTime.now(),
          exerciseCount: activePlan.exercises.length,
          setCount: completedSetsToday,
          setLogs: List.unmodifiable(activeSetLogs),
        ),
      );
      final trainingGoal = goals.firstWhere(
        (goal) => goal.title == 'Train this week',
      );
      trainingGoal.current++;
      trainingGoal.isComplete = trainingGoal.current >= 4;
    }
    workoutInProgress = false;
    workoutPaused = false;
    completedSetsToday = 0;
    activeSetLogs.clear();
    notifyListeners();
  }

  void addPlan(String name, List<Exercise> exercises) {
    plans.add(
      WorkoutPlan(
        name: name,
        focus: 'Custom training plan',
        exercises: List.unmodifiable(exercises),
        isCustom: true,
      ),
    );
    notifyListeners();
  }

  void addMeal(MealEntry meal) {
    meals.insert(0, meal);
    final proteinGoal = goals.firstWhere(
      (goal) => goal.title == 'Daily protein',
    );
    proteinGoal.current = proteinToday.toDouble();
    proteinGoal.isComplete = proteinToday >= dailyProteinTarget;
    notifyListeners();
  }

  void addMeasurement(double weightKg, double waistCm) {
    measurements.insert(
      0,
      BodyMeasurement(
        weightKg: weightKg,
        waistCm: waistCm,
        recordedAt: DateTime.now(),
      ),
    );
    final weightGoal = goals.firstWhere((goal) => goal.title == 'Body weight');
    weightGoal.current = weightKg;
    weightGoal.isComplete = weightKg <= 72;
    notifyListeners();
  }

  void addGoal(String title, String target) {
    goals.add(FitnessGoal(title: title, target: target));
    notifyListeners();
  }

  void setReminder(String title, bool enabled) {
    reminders[title] = enabled;
    notifyListeners();
  }

  void updateTargets({int? calories, int? protein}) {
    if (calories != null) dailyCalorieTarget = calories;
    if (protein != null) {
      dailyProteinTarget = protein;
      final goal = goals.firstWhere((item) => item.title == 'Daily protein');
      goal.isComplete = goal.current >= protein;
    }
    notifyListeners();
  }

  void resetDemoData() {
    plans.removeWhere((plan) => plan.isCustom);
    workoutHistory.clear();
    activeSetLogs.clear();
    meals.clear();
    measurements
      ..clear()
      ..add(
        BodyMeasurement(
          weightKg: 75.5,
          waistCm: 82,
          recordedAt: DateTime.now(),
        ),
      );
    goals
      ..clear()
      ..addAll([
        FitnessGoal(title: 'Daily protein', target: '160 g'),
        FitnessGoal(title: 'Train this week', target: '4 sessions'),
        FitnessGoal(title: 'Body weight', target: '72 kg', current: 75.5),
      ]);
    reminders
      ..clear()
      ..addAll({
        'Workout reminder': true,
        'Meal logging reminder': false,
        'Weekly progress check-in': true,
      });
    activePlanName = 'Push Day';
    completedSetsToday = 0;
    workoutInProgress = false;
    workoutPaused = false;
    dailyCalorieTarget = 2500;
    dailyProteinTarget = 160;
    notifyListeners();
  }

  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
