import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const Spacer(flex: 3),
              // Logo / name
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A7A3C),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.agriculture_rounded,
                  size: 52,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Farrax',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A7A3C),
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Smart Herd Management\nfor Irish & UK Farmers',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: Color(0xFF555555),
                  height: 1.45,
                ),
              ),
              const Spacer(flex: 4),
              // CTA button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF0A500),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Continue as Guest',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Login & Sync coming soon',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF888888),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
