import 'package:flutter/material.dart';
import '../theme.dart';
import 'location_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.navy, AppColors.navy2, Color(0xFF0E3B3A)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -70,
              bottom: 60,
              child: Icon(Icons.electric_car,
                  size: 340, color: Colors.white.withOpacity(0.06)),
            ),
            Positioned(
              left: -40,
              top: 50,
              child: Icon(Icons.bolt,
                  size: 240, color: AppColors.green.withOpacity(0.08)),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, box) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: box.maxHeight),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const _Logo(),
                              const SizedBox(height: 28),
                              const Text(
                                'EV-M+REW Connector',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Find Your Nearest EV Charging Station',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.green,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Share your location, see chargers around you, '
                                'and check which ports are free before you drive there.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 40),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: () => Navigator.of(context)
                                      .push(fadeSlide(const LocationScreen())),
                                  child: const Text('Get Started'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.navy2,
        border: Border.all(color: AppColors.green, width: 3),
        boxShadow: [
          BoxShadow(
              color: AppColors.green.withOpacity(0.35),
              blurRadius: 30,
              spreadRadius: 2),
        ],
      ),
      child: const Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.electric_car, color: Colors.white, size: 52),
          Positioned(
              top: 18,
              right: 22,
              child: Icon(Icons.bolt, color: AppColors.green, size: 30)),
        ],
      ),
    );
  }
}
