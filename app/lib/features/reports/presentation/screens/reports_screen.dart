import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/database/database.dart';
import '../../../animals/presentation/providers/animal_provider.dart';
import '../../../health/presentation/providers/health_provider.dart';
import '../../../movements/presentation/providers/movement_provider.dart';
import '../../data/report_generator.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: const Color(0xFF1A7A3C),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle('Export Data'),
          _ReportCard(
            icon: Icons.pets_rounded,
            title: 'Herd Register',
            subtitle: 'All animals — PDF or CSV',
            color: const Color(0xFF1A7A3C),
            onPdf: () => _exportHerdPdf(context, ref),
            onCsv: () => _exportHerdCsv(context, ref),
          ),
          const SizedBox(height: 12),
          _ReportCard(
            icon: Icons.swap_horiz_rounded,
            title: 'Movement Records',
            subtitle: 'All movement events — CSV',
            color: const Color(0xFFF0A500),
            onCsv: () => _exportMovementsCsv(context, ref),
          ),
          const SizedBox(height: 12),
          _ReportCard(
            icon: Icons.medication_rounded,
            title: 'Medicine Register',
            subtitle: 'All treatments — PDF or CSV',
            color: const Color(0xFF0D6EAF),
            onPdf: () => _exportMedicinePdf(context, ref),
            onCsv: () => _exportMedicineCsv(context, ref),
          ),
          const SizedBox(height: 12),
          _ReportCard(
            icon: Icons.biotech_rounded,
            title: 'TB Test Records',
            subtitle: 'All TB tests — CSV',
            color: Colors.red,
            onCsv: () => _exportTbCsv(context, ref),
          ),
        ],
      ),
    );
  }

  // ── Herd ────────────────────────────────────────────────────────────────────

  Future<void> _exportHerdPdf(BuildContext context, WidgetRef ref) async {
    await _run(context, () async {
      final List<Animal> animals =
          ref.read(allAnimalsProvider).valueOrNull ?? [];
      final bytes = await ReportGenerator.generateHerdRegisterPdf(
        animals: animals,
        farmName: 'My Farm',
        herdNumber: '',
      );
      await ReportGenerator.printPdf(bytes, 'Herd Register');
    });
  }

  Future<void> _exportHerdCsv(BuildContext context, WidgetRef ref) async {
    await _run(context, () async {
      final List<Animal> animals =
          ref.read(allAnimalsProvider).valueOrNull ?? [];
      final String csv = ReportGenerator.generateAnimalsCsv(animals);
      await Share.share(csv, subject: 'Herd Register');
    });
  }

  // ── Movements ──────────────────────────────────────────────────────────────

  Future<void> _exportMovementsCsv(BuildContext context, WidgetRef ref) async {
    await _run(context, () async {
      final List<MovementEvent> events =
          ref.read(allMovementsProvider).valueOrNull ?? [];
      final String csv = ReportGenerator.generateMovementsCsv(events);
      await Share.share(csv, subject: 'Movement Records');
    });
  }

  // ── Medicine ───────────────────────────────────────────────────────────────

  Future<void> _exportMedicinePdf(BuildContext context, WidgetRef ref) async {
    await _run(context, () async {
      final List<MedicineEvent> events =
          ref.read(allMedicineEventsProvider).valueOrNull ?? [];
      final bytes = await ReportGenerator.generateMedicineRegisterPdf(
        events: events,
        farmName: 'My Farm',
        herdNumber: '',
      );
      await ReportGenerator.printPdf(bytes, 'Medicine Register');
    });
  }

  Future<void> _exportMedicineCsv(BuildContext context, WidgetRef ref) async {
    await _run(context, () async {
      final List<MedicineEvent> events =
          ref.read(allMedicineEventsProvider).valueOrNull ?? [];
      final String csv = ReportGenerator.generateMedicineCsv(events);
      await Share.share(csv, subject: 'Medicine Register');
    });
  }

  // ── TB ─────────────────────────────────────────────────────────────────────

  Future<void> _exportTbCsv(BuildContext context, WidgetRef ref) async {
    await _run(context, () async {
      final List<TbTestEvent> tests =
          ref.read(allTbTestsProvider).valueOrNull ?? [];
      final String csv = ReportGenerator.generateTbTestsCsv(tests);
      await Share.share(csv, subject: 'TB Test Records');
    });
  }

  // ── Helper ─────────────────────────────────────────────────────────────────

  Future<void> _run(BuildContext context, Future<void> Function() fn) async {
    try {
      await fn();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }
}

// ─── Section Title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF888888),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Report Card ──────────────────────────────────────────────────────────────

class _ReportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onPdf;
  final VoidCallback? onCsv;

  const _ReportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onPdf,
    this.onCsv,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D1F14),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (onPdf != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPdf,
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                    label: const Text('PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(color: color),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              if (onPdf != null && onCsv != null) const SizedBox(width: 10),
              if (onCsv != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCsv,
                    icon: const Icon(Icons.table_chart_rounded, size: 16),
                    label: const Text('CSV'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(color: color),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
