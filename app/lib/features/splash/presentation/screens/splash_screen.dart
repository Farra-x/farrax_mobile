import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _headCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _lineCtrl;

  late final Animation<double> _headScale;
  late final Animation<double> _headOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<double> _lineWidth;

  @override
  void initState() {
    super.initState();

    // Head: 0–600ms scale + fade, 600–900ms bounce
    _headCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _headScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 67,
      ),
      TweenSequenceItem(
        tween: TweenSequence<double>([
          TweenSequenceItem(
              tween: Tween<double>(begin: 1.0, end: 1.06), weight: 50),
          TweenSequenceItem(
              tween: Tween<double>(begin: 1.06, end: 1.0), weight: 50),
        ]),
        weight: 33,
      ),
    ]).animate(_headCtrl);

    _headOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Text: 800–1200ms fade in
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn),
    );

    // Underline: slides in 1100–1500ms
    _lineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _lineWidth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lineCtrl, curve: Curves.easeOutCubic),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await _headCtrl.forward();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _textCtrl.forward();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _lineCtrl.forward();
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    _navigate();
  }

  Future<void> _navigate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool setupDone = prefs.getBool('farm_setup_complete') ?? false;
    if (!mounted) return;
    context.go(setupDone ? '/home' : '/onboarding');
  }

  @override
  void dispose() {
    _headCtrl.dispose();
    _textCtrl.dispose();
    _lineCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A7A3C), Color(0xFF0D1F14)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Farrax F icon
              AnimatedBuilder(
                animation: _headCtrl,
                builder: (_, __) => Opacity(
                  opacity: _headOpacity.value,
                  child: Transform.scale(
                    scale: _headScale.value,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: SvgPicture.asset(
                        'assets/icons/app_icon.svg',
                        width: 140,
                        height: 140,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // FARRAX text
              AnimatedBuilder(
                animation: _textCtrl,
                builder: (_, __) => Opacity(
                  opacity: _textOpacity.value,
                  child: const Text(
                    'FARRAX',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 28,
                      letterSpacing: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Amber underline sliding in
              AnimatedBuilder(
                animation: _lineCtrl,
                builder: (_, __) => Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: _lineWidth.value,
                    child: Container(
                      width: 120,
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0A500),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
