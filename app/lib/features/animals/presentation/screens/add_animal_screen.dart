import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/database.dart';
import '../../../../core/services/scanner_service.dart';
import '../providers/animal_provider.dart';
import '../../../scanner/presentation/providers/scanner_provider.dart';

class AddAnimalScreen extends ConsumerStatefulWidget {
  final String? initialTagNumber;
  const AddAnimalScreen({super.key, this.initialTagNumber});

  @override
  ConsumerState<AddAnimalScreen> createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends ConsumerState<AddAnimalScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _tagCtrl = TextEditingController();
  final TextEditingController _herdCtrl = TextEditingController();
  final TextEditingController _damCtrl = TextEditingController();
  final TextEditingController _sireCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  String _sex = 'M';
  String _breed = 'FR';
  DateTime _dob = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialTagNumber != null) {
      _tagCtrl.text = widget.initialTagNumber!;
    }
  }

  @override
  void dispose() {
    _tagCtrl.dispose();
    _herdCtrl.dispose();
    _damCtrl.dispose();
    _sireCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ─── Scan helpers ─────────────────────────────────────────────────────────

  /// Scan into the main tag field — opens camera, then checks if already registered.
  Future<void> _scanMainTag() async {
    final ScannerService svc = ref.read(scannerServiceProvider);
    final String? tag = await svc.scanWithCamera(context);
    if (tag == null || !mounted) return;

    // Check if already registered locally
    final Animal? existing =
        await ref.read(animalRepositoryProvider).findByTagNumber(tag);
    if (!mounted) return;

    if (existing != null) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.info_rounded, color: Color(0xFF1A7A3C)),
              SizedBox(width: 8),
              Text('Already Registered'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tag,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${existing.breed} · ${existing.sex == 'M' ? 'Male' : 'Female'} · Herd ${existing.herdNumber}',
                style: const TextStyle(color: Color(0xFF555555), fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Stay Here'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A7A3C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                context.pushReplacement('/animals/${existing.id}');
              },
              child: const Text('View Animal'),
            ),
          ],
        ),
      );
    } else {
      setState(() => _tagCtrl.text = tag);
    }
  }

  /// Scan into dam/sire fields — opens camera, just populates the field.
  Future<void> _scanIntoField(TextEditingController ctrl) async {
    final ScannerService svc = ref.read(scannerServiceProvider);
    final String? tag = await svc.scanWithCamera(context);
    if (tag != null && mounted) setState(() => ctrl.text = tag);
  }

  // ─── Breed picker ─────────────────────────────────────────────────────────

  Future<void> _pickBreed() async {
    final List<MapEntry<String, String>> breeds =
        FarraxConstants.breeds.entries.toList();
    final TextEditingController searchCtrl = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) => StatefulBuilder(
        builder: (BuildContext ctx2, StateSetter setModal) {
          final List<MapEntry<String, String>> filtered = breeds
              .where((e) =>
                  e.key
                      .toLowerCase()
                      .contains(searchCtrl.text.toLowerCase()) ||
                  e.value
                      .toLowerCase()
                      .contains(searchCtrl.text.toLowerCase()))
              .toList();

          return Container(
            height: MediaQuery.of(ctx).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: searchCtrl,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search breed…',
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F7F5),
                    ),
                    onChanged: (_) => setModal(() {}),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, int i) {
                      final MapEntry<String, String> e = filtered[i];
                      final bool selected = e.key == _breed;
                      return ListTile(
                        title: Text(e.value),
                        subtitle: Text(e.key),
                        trailing: selected
                            ? const Icon(Icons.check_rounded,
                                color: Color(0xFF1A7A3C))
                            : null,
                        onTap: () {
                          setState(() => _breed = e.key);
                          Navigator.pop(ctx2);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── DOB picker ───────────────────────────────────────────────────────────

  Future<void> _pickDob() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dob,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (BuildContext ctx, Widget? child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1A7A3C),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  // ─── Save ─────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final String id = const Uuid().v4();
    final AnimalsCompanion companion = AnimalsCompanion(
      id: Value(id),
      tagNumber: Value(_tagCtrl.text.trim().toUpperCase()),
      sex: Value(_sex),
      breed: Value(_breed),
      dateOfBirth: Value(_dob),
      herdNumber: Value(_herdCtrl.text.trim()),
      damTagNumber: _damCtrl.text.trim().isEmpty
          ? const Value.absent()
          : Value(_damCtrl.text.trim().toUpperCase()),
      sireTagNumber: _sireCtrl.text.trim().isEmpty
          ? const Value.absent()
          : Value(_sireCtrl.text.trim().toUpperCase()),
      notes: _notesCtrl.text.trim().isEmpty
          ? const Value.absent()
          : Value(_notesCtrl.text.trim()),
    );

    try {
      await ref.read(animalRepositoryProvider).addAnimal(companion);
      if (mounted) {
        context.pushReplacement('/animals/$id');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final String breedLabel =
        FarraxConstants.breeds[_breed] ?? _breed;
    final String dobFormatted =
        '${_dob.day.toString().padLeft(2, '0')}/${_dob.month.toString().padLeft(2, '0')}/${_dob.year}';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A7A3C),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Register Animal',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Tag Number ─────────────────────────────────────────────
            const _SectionLabel('Tag Number'),
            _TagField(
              controller: _tagCtrl,
              onScan: _scanMainTag,
            ),
            const SizedBox(height: 20),

            // ── Sex ────────────────────────────────────────────────────
            const _SectionLabel('Sex'),
            Row(
              children: ['M', 'F'].map((String s) {
                final bool selected = _sex == s;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: s == 'M' ? 8 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() => _sex = s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        height: 56,
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF1A7A3C)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF1A7A3C)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              s == 'M'
                                  ? Icons.male_rounded
                                  : Icons.female_rounded,
                              color: selected
                                  ? Colors.white
                                  : Colors.grey[500],
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              s == 'M' ? 'Male' : 'Female',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? Colors.white
                                    : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── Breed ──────────────────────────────────────────────────
            const _SectionLabel('Breed'),
            _TappableField(
              label: breedLabel,
              subtitle: _breed,
              icon: Icons.pets_rounded,
              onTap: _pickBreed,
            ),
            const SizedBox(height: 20),

            // ── Date of Birth ──────────────────────────────────────────
            const _SectionLabel('Date of Birth'),
            _TappableField(
              label: dobFormatted,
              icon: Icons.calendar_today_rounded,
              onTap: _pickDob,
            ),
            const SizedBox(height: 20),

            // ── Herd Number ────────────────────────────────────────────
            const _SectionLabel('Herd Number'),
            _FormTextField(
              controller: _herdCtrl,
              hint: 'e.g. E123456',
              validator: (String? v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 20),

            // ── Dam Tag ────────────────────────────────────────────────
            const _SectionLabel('Dam Tag (optional)'),
            _TagField(
              controller: _damCtrl,
              onScan: () => _scanIntoField(_damCtrl),
              required: false,
            ),
            const SizedBox(height: 20),

            // ── Sire Tag ───────────────────────────────────────────────
            const _SectionLabel('Sire Tag (optional)'),
            _TagField(
              controller: _sireCtrl,
              onScan: () => _scanIntoField(_sireCtrl),
              required: false,
            ),
            const SizedBox(height: 20),

            // ── Notes ──────────────────────────────────────────────────
            const _SectionLabel('Notes (optional)'),
            _FormTextField(
              controller: _notesCtrl,
              hint: 'Any additional notes…',
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // ── Save button ────────────────────────────────────────────
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A7A3C),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Register Animal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF555555),
          ),
        ),
      );
}

class _TagField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onScan;
  final bool required;

  const _TagField({
    required this.controller,
    required this.onScan,
    this.required = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.characters,
      style: const TextStyle(
        fontFamily: 'monospace',
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        fontSize: 15,
        color: Color(0xFF1A1A1A),
      ),
      decoration: InputDecoration(
        hintText: 'IE141123456789',
        hintStyle: const TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: Color(0xFFAAAAAA),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF1A7A3C), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.qr_code_scanner_rounded,
              color: Color(0xFF1A7A3C)),
          onPressed: onScan,
          tooltip: 'Scan tag',
        ),
      ),
      validator: required
          ? (String? v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              final String clean =
                  v.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
              final bool valid =
                  RegExp(r'^\d{15}$').hasMatch(clean) ||
                      RegExp(r'^IE\d{12}$').hasMatch(clean) ||
                      RegExp(r'^UK\d{12}$').hasMatch(clean);
              if (!valid) {
                return 'Use IE/UK + 12 digits or 15-digit ISO';
              }
              return null;
            }
          : null,
    );
  }
}

class _TappableField extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _TappableField({
    required this.label,
    required this.icon,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1A7A3C), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: subtitle != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ],
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFCCCCCC), size: 20),
          ],
        ),
      ),
    );
  }
}

class _FormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final String? Function(String?)? validator;

  const _FormTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF1A1A1A),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF1A7A3C), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
