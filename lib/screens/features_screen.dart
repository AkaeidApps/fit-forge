import 'package:flutter/material.dart';

import '../core/responsive_content.dart';
import '../core/theme.dart';
import 'login_screen.dart';

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveContent(
        maxWidth: 760,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 40),
            LayoutBuilder(
              builder: (context, constraints) {
                final tileWidth = ((constraints.maxWidth - 16) / 3).clamp(
                  100.0,
                  220.0,
                );
                return Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _featureCard(
                      Icons.fitness_center,
                      'Workout\nPlan',
                      Colors.green,
                      tileWidth,
                    ),
                    _featureCard(
                      Icons.apple,
                      'Nutrition\nGuide',
                      Colors.purple,
                      tileWidth,
                    ),
                    _featureCard(
                      Icons.bar_chart,
                      'Track\nProgress',
                      Colors.blue,
                      tileWidth,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 40),
            const Text(
              'Your Complete\nFitness Companion',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Personalized plans, expert guidance and progress tracking.',
              style: TextStyle(color: AppTheme.textGrey),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text('Next'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _featureCard(IconData icon, String title, Color color, double width) {
    return Container(
      height: 100,
      width: width,
      decoration: BoxDecoration(
        color: AppTheme.cardDarkGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
