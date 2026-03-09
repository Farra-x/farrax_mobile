import 'package:flutter/material.dart';
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
              // Cattle head
              AnimatedBuilder(
                animation: _headCtrl,
                builder: (_, __) => Opacity(
                  opacity: _headOpacity.value,
                  child: Transform.scale(
                    scale: _headScale.value,
                    child: const SizedBox(
                      width: 180,
                      height: 180,
                      child: CustomPaint(painter: CattleHeadPainter()),
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

// ─── Cattle Head CustomPainter ────────────────────────────────────────────────

class CattleHeadPainter extends CustomPainter {
  const CattleHeadPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double scale = size.width / 200.0;

    final Paint white = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.5 * scale;

    final Paint whiteFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint amber = Paint()
      ..color = const Color(0xFFF0A500)
      ..style = PaintingStyle.fill;

    final double s = scale;

    // ── Head oval ─────────────────────────────────────────────────────────
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, cy - 5 * s), width: 110 * s, height: 130 * s),
      white,
    );

    // ── Muzzle ────────────────────────────────────────────────────────────
    final RRect muzzle = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(cx, cy + 42 * s), width: 70 * s, height: 36 * s),
      Radius.circular(18 * s),
    );
    canvas.drawRRect(muzzle, white);

    // Nostrils
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx - 16 * s, cy + 46 * s),
            width: 14 * s,
            height: 10 * s),
        white);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx + 16 * s, cy + 46 * s),
            width: 14 * s,
            height: 10 * s),
        white);

    // ── Eyes ──────────────────────────────────────────────────────────────
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx - 28 * s, cy - 22 * s),
            width: 22 * s,
            height: 18 * s),
        white);
    canvas.drawCircle(Offset(cx - 28 * s, cy - 22 * s), 5 * s, whiteFill);

    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx + 28 * s, cy - 22 * s),
            width: 22 * s,
            height: 18 * s),
        white);
    canvas.drawCircle(Offset(cx + 28 * s, cy - 22 * s), 5 * s, whiteFill);

    // ── Ears ──────────────────────────────────────────────────────────────
    final Path leftEar = Path()
      ..moveTo(cx - 55 * s, cy - 10 * s)
      ..lineTo(cx - 90 * s, cy - 40 * s)
      ..lineTo(cx - 72 * s, cy - 60 * s)
      ..lineTo(cx - 50 * s, cy - 35 * s)
      ..close();
    canvas.drawPath(leftEar, white);

    final Path rightEar = Path()
      ..moveTo(cx + 55 * s, cy - 10 * s)
      ..lineTo(cx + 90 * s, cy - 40 * s)
      ..lineTo(cx + 72 * s, cy - 60 * s)
      ..lineTo(cx + 50 * s, cy - 35 * s)
      ..close();
    canvas.drawPath(rightEar, white);

    // ── Horns ─────────────────────────────────────────────────────────────
    final Paint hornPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4 * scale;

    final Path leftHorn = Path()
      ..moveTo(cx - 42 * s, cy - 60 * s)
      ..quadraticBezierTo(
          cx - 65 * s, cy - 100 * s, cx - 38 * s, cy - 110 * s);
    canvas.drawPath(leftHorn, hornPaint);

    final Path rightHorn = Path()
      ..moveTo(cx + 42 * s, cy - 60 * s)
      ..quadraticBezierTo(
          cx + 65 * s, cy - 100 * s, cx + 38 * s, cy - 110 * s);
    canvas.drawPath(rightHorn, hornPaint);

    // ── Ear tags (amber rectangles) ───────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx - 96 * s, cy - 42 * s),
            width: 18 * s,
            height: 12 * s),
        Radius.circular(3 * s),
      ),
      amber,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx + 96 * s, cy - 42 * s),
            width: 18 * s,
            height: 12 * s),
        Radius.circular(3 * s),
      ),
      amber,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
