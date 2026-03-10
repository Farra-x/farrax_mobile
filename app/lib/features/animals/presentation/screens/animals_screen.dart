import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/database.dart';
import '../providers/animal_provider.dart';
import '../../../scanner/presentation/widgets/scan_input_sheet.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/providers/locale_provider.dart';

class AnimalsScreen extends ConsumerStatefulWidget {
  const AnimalsScreen({super.key});

  @override
  ConsumerState<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends ConsumerState<AnimalsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openScanner() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScanInputSheet(
        tagHandler: ref.read(tagHandlerProvider),
        outerContext: context,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Animal>> animalsAsync =
        ref.watch(filteredAnimalsProvider);
    final AnimalFilterOption filter = ref.watch(animalListFilterProvider);
    final AppL10n l10n = AppL10n(ref.watch(appLocaleProvider));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A7A3C),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.myHerd,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            onPressed: _openScanner,
            tooltip: 'Scan Tag',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: const Color(0xFF1A7A3C),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (String v) =>
                  ref.read(animalSearchQueryProvider.notifier).set(v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                hintStyle:
                    const TextStyle(color: Color(0xAAFFFFFF), fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: Color(0xAAFFFFFF)),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: Color(0xAAFFFFFF)),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref
                              .read(animalSearchQueryProvider.notifier)
                              .set('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),

          // Filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: AnimalFilterOption.values.map((AnimalFilterOption f) {
                  final bool selected = filter == f;
                  final String label = switch (f) {
                    AnimalFilterOption.all => l10n.filterAll,
                    AnimalFilterOption.active => l10n.active,
                    AnimalFilterOption.male => l10n.male,
                    AnimalFilterOption.female => l10n.female,
                  };
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: (_) =>
                          ref.read(animalListFilterProvider.notifier).set(f),
                      backgroundColor: Colors.white,
                      selectedColor:
                          const Color(0xFF1A7A3C).withValues(alpha: 0.12),
                      checkmarkColor: const Color(0xFF1A7A3C),
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        color: selected
                            ? const Color(0xFF1A7A3C)
                            : const Color(0xFF444444),
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 13,
                      ),
                      side: BorderSide(
                        color: selected
                            ? const Color(0xFF1A7A3C)
                            : Colors.grey.shade300,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Animal list
          Expanded(
            child: animalsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF1A7A3C)),
              ),
              error: (Object e, _) => Center(child: Text('Error: $e')),
              data: (List<Animal> animals) => animals.isEmpty
                  ? _EmptyState(
                      onAdd: () => context.push('/animals/add'),
                      message: l10n.noAnimalsYet,
                      hint: l10n.tapBelowToRegister,
                      buttonLabel: l10n.registerFirstAnimal,
                    )
                  : RefreshIndicator(
                      color: const Color(0xFF1A7A3C),
                      onRefresh: () async =>
                          ref.invalidate(filteredAnimalsProvider),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: animals.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, int i) {
                          final Animal a = animals[i];
                          return _AnimalTile(
                            animal: a,
                            onTap: () => context.push('/animals/${a.id}'),
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_animals',
        onPressed: () => context.push('/animals/add'),
        backgroundColor: const Color(0xFF1A7A3C),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          l10n.addAnimal,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  final String message;
  final String hint;
  final String buttonLabel;
  const _EmptyState({
    required this.onAdd,
    required this.message,
    required this.hint,
    required this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF555555),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A7A3C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text(
                buttonLabel,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Animal Tile ──────────────────────────────────────────────────────────────

class _AnimalTile extends ConsumerWidget {
  final Animal animal;
  final VoidCallback onTap;

  const _AnimalTile({required this.animal, required this.onTap});

  String _age(DateTime dob) {
    final int days = DateTime.now().difference(dob).inDays;
    if (days < 30) return '$days days';
    if (days < 365) return '${(days / 30).floor()} months';
    final int years = (days / 365).floor();
    final int months = ((days % 365) / 30).floor();
    return months > 0 ? '${years}y ${months}m' : '${years}y';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppL10n l10n = AppL10n(ref.watch(appLocaleProvider));
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Sex icon
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A7A3C).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  animal.sex == 'M'
                      ? Icons.male_rounded
                      : Icons.female_rounded,
                  color: const Color(0xFF1A7A3C),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      animal.tagNumber,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D1F14),
                        fontFamily: 'monospace',
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${animal.breed} · ${animal.sex == 'M' ? l10n.male : l10n.female} · ${_age(animal.dateOfBirth)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
              ),

              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: animal.isActive
                      ? const Color(0xFF1A7A3C).withValues(alpha: 0.08)
                      : Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  animal.isActive ? l10n.active : l10n.inactive,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: animal.isActive
                        ? const Color(0xFF1A7A3C)
                        : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFFCCCCCC), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
