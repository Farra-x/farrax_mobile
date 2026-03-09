import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database.dart';
import '../providers/farm_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Farm form fields
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _farmNameController = TextEditingController();
  final TextEditingController _herdNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _selectedCountry = 'IE';

  @override
  void dispose() {
    _pageController.dispose();
    _farmNameController.dispose();
    _herdNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.animateToPage(
      _currentPage + 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _saveFarmAndFinish() async {
    final String farmId = const Uuid().v4();
    final FarmsCompanion farm = FarmsCompanion.insert(
      id: farmId,
      name: _farmNameController.text.trim(),
      herdNumber: _herdNumberController.text.trim().toUpperCase(),
      country: Value(_selectedCountry),
      address: Value(_addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim()),
    );
    await ref.read(farmRepositoryProvider).addFarm(farm);
    await ref.read(farmRepositoryProvider).setActiveFarm(farmId);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: List.generate(3, (int i) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: i <= _currentPage
                            ? const Color(0xFF1A7A3C)
                            : const Color(0xFFDDDDDD),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (int p) => setState(() => _currentPage = p),
                children: [
                  _WelcomePage(onNext: _nextPage),
                  _FarmSetupPage(
                    formKey: _formKey,
                    farmNameController: _farmNameController,
                    herdNumberController: _herdNumberController,
                    addressController: _addressController,
                    selectedCountry: _selectedCountry,
                    onCountryChanged: (String c) =>
                        setState(() => _selectedCountry = c),
                    onNext: () {
                      if (_formKey.currentState!.validate()) _nextPage();
                    },
                  ),
                  _ScannerPage(onFinish: _saveFarmAndFinish),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Page 1: Welcome ──────────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  final VoidCallback onNext;
  const _WelcomePage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF1A7A3C).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.pets_rounded,
              size: 80,
              color: Color(0xFF1A7A3C),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Welcome to Farrax',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0D1F14),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            "Let's get your farm set up",
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF888888),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A7A3C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Page 2: Farm Setup ───────────────────────────────────────────────────────

class _FarmSetupPage extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController farmNameController;
  final TextEditingController herdNumberController;
  final TextEditingController addressController;
  final String selectedCountry;
  final ValueChanged<String> onCountryChanged;
  final VoidCallback onNext;

  const _FarmSetupPage({
    required this.formKey,
    required this.farmNameController,
    required this.herdNumberController,
    required this.addressController,
    required this.selectedCountry,
    required this.onCountryChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Farm Setup',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0D1F14),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Enter your farm details',
              style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
            ),
            const SizedBox(height: 28),

            TextFormField(
              controller: farmNameController,
              decoration: const InputDecoration(
                labelText: 'Farm Name',
                hintText: 'e.g. Murphy Family Farm',
                prefixIcon: Icon(Icons.home_rounded),
              ),
              validator: (String? v) =>
                  (v == null || v.trim().isEmpty) ? 'Farm name is required' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: herdNumberController,
              decoration: const InputDecoration(
                labelText: 'Herd Number',
                hintText: 'e.g. IE141234',
                prefixIcon: Icon(Icons.tag_rounded),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (String? v) =>
                  (v == null || v.trim().isEmpty) ? 'Herd number is required' : null,
            ),
            const SizedBox(height: 16),

            // Country toggle
            const Text(
              'Country',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF888888),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _CountryButton(
                  label: 'IE',
                  flag: '🇮🇪',
                  isSelected: selectedCountry == 'IE',
                  onTap: () => onCountryChanged('IE'),
                ),
                const SizedBox(width: 12),
                _CountryButton(
                  label: 'UK',
                  flag: '🇬🇧',
                  isSelected: selectedCountry == 'UK',
                  onTap: () => onCountryChanged('UK'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Address (optional)',
                hintText: 'Farm address',
                prefixIcon: Icon(Icons.location_on_rounded),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A7A3C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryButton extends StatelessWidget {
  final String label;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const _CountryButton({
    required this.label,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF1A7A3C)
                : const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Page 3: Scanner ──────────────────────────────────────────────────────────

class _ScannerPage extends StatelessWidget {
  final Future<void> Function() onFinish;
  const _ScannerPage({required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFF0A500).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              size: 56,
              color: Color(0xFFF0A500),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Connect your EID Reader',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0D1F14),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Connect a Bluetooth EID reader to scan animal tags directly. You can skip this and connect later from settings.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF888888),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => context.push('/scanner/ble'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A7A3C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Connect Reader',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: onFinish,
            child: const Text(
              'Skip for now',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF888888),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
