import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../database/database.dart';

class TagHandler {
  final FarraxDatabase _db;

  TagHandler(this._db);

  Future<void> handleTag(String tagNumber, BuildContext context) async {
    // Look up tag in local database
    final Animal? animal = await (_db.select(_db.animals)
          ..where((tbl) => tbl.tagNumber.equals(tagNumber)))
        .getSingleOrNull();

    if (!context.mounted) return;

    if (animal != null) {
      await _showQuickSummary(context, animal);
    } else {
      await _showUnregisteredTag(context, tagNumber);
    }
  }

  // ─── Quick Summary Sheet ──────────────────────────────────────────────────

  Future<void> _showQuickSummary(BuildContext context, Animal animal) async {
    final String age = _formatAge(animal.dateOfBirth);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuickSummarySheet(animal: animal, age: age),
    );
  }

  // ─── Unregistered Tag Sheet ───────────────────────────────────────────────

  Future<void> _showUnregisteredTag(
      BuildContext context, String tagNumber) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetCtx) =>
          _UnregisteredTagSheet(tagNumber: tagNumber),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _formatAge(DateTime dob) {
    final Duration diff = DateTime.now().difference(dob);
    final int days = diff.inDays;
    if (days < 30) return '$days days';
    if (days < 365) return '${(days / 30).floor()} months';
    final int years = (days / 365).floor();
    final int months = ((days % 365) / 30).floor();
    return months > 0 ? '${years}y ${months}m' : '${years}y';
  }
}

// ─── Quick Summary Bottom Sheet ───────────────────────────────────────────────

class _QuickSummarySheet extends StatelessWidget {
  final Animal animal;
  final String age;

  const _QuickSummarySheet({required this.animal, required this.age});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Tag badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A7A3C).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  animal.tagNumber,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF1A7A3C),
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: animal.isActive
                      ? Colors.green.withValues(alpha:0.1)
                      : Colors.grey.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  animal.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: animal.isActive ? Colors.green[700] : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Info rows
          _InfoRow(label: 'Breed', value: animal.breed),
          _InfoRow(label: 'Sex', value: animal.sex == 'M' ? 'Male' : 'Female'),
          _InfoRow(label: 'Age', value: age),
          _InfoRow(label: 'Herd', value: animal.herdNumber),
          if (animal.damTagNumber != null)
            _InfoRow(label: 'Dam', value: animal.damTagNumber!),
          const SizedBox(height: 24),
          // Open full profile button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/animals/${animal.id}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A7A3C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Open Full Profile',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF555555),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Unregistered Tag Bottom Sheet ────────────────────────────────────────────

class _UnregisteredTagSheet extends StatelessWidget {
  final String tagNumber;

  const _UnregisteredTagSheet({required this.tagNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Warning icon + title
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0A500).withValues(alpha:0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: Color(0xFFF0A500),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Tag Not Registered',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              tagNumber,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: Color(0xFF333333),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Register Animal
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/animals/add', extra: {'tagNumber': tagNumber});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A7A3C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Register Animal',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Add to Batch List
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$tagNumber added to batch list'),
                    backgroundColor: const Color(0xFF1A7A3C),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1A7A3C),
                side: const BorderSide(color: Color(0xFF1A7A3C)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add to Batch List',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Dismiss
          SizedBox(
            width: double.infinity,
            height: 52,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Dismiss',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF888888),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
