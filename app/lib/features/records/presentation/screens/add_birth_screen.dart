import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database.dart';
import '../providers/records_provider.dart';

class AddBirthScreen extends ConsumerStatefulWidget {
  final String? initialAnimalTag;
  const AddBirthScreen({super.key, this.initialAnimalTag});

  @override
  ConsumerState<AddBirthScreen> createState() => _AddBirthScreenState();
}

class _AddBirthScreenState extends ConsumerState<AddBirthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _tagController;
  final TextEditingController _damTagController = TextEditingController();
  final TextEditingController _sireTagController = TextEditingController();
  final TextEditingController _birthWeightController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _eventDate = DateTime.now();
  int _calvingDifficulty = 1;
  bool _isAssisted = false;
  bool _isStillborn = false;
  bool _isTwin = false;
  bool _vetAttended = false;
  bool _colostrumFed = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tagController = TextEditingController(text: widget.initialAnimalTag ?? '');
  }

  @override
  void dispose() {
    _tagController.dispose();
    _damTagController.dispose();
    _sireTagController.dispose();
    _birthWeightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final String tag = _tagController.text.trim().toUpperCase();

    final BirthEventsCompanion event = BirthEventsCompanion(
      id: Value(const Uuid().v4()),
      animalId: Value(tag),
      eventDate: Value(_eventDate),
      calvingDifficulty: Value(_calvingDifficulty),
      birthWeight: Value(double.tryParse(_birthWeightController.text)),
      isAssisted: Value(_isAssisted),
      isStillborn: Value(_isStillborn),
      isTwin: Value(_isTwin),
      vetAttended: Value(_vetAttended),
      colostrumFed: Value(_colostrumFed),
      damTagNumber: Value(_damTagController.text.trim().isEmpty
          ? null
          : _damTagController.text.trim().toUpperCase()),
      sireTagNumber: Value(_sireTagController.text.trim().isEmpty
          ? null
          : _sireTagController.text.trim().toUpperCase()),
      notes: Value(_notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim()),
    );

    await ref.read(birthRepositoryProvider).addBirthEvent(event);

    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Birth event recorded')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text('Record Birth'),
        backgroundColor: const Color(0xFF1A7A3C),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionCard(
              children: [
                TextFormField(
                  controller: _tagController,
                  decoration: const InputDecoration(
                    labelText: 'Animal Tag *',
                    hintText: 'IE141123456789',
                    prefixIcon: Icon(Icons.tag_rounded),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (String? v) =>
                      (v == null || v.trim().isEmpty) ? 'Tag is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _damTagController,
                  decoration: const InputDecoration(
                    labelText: 'Dam Tag (optional)',
                    prefixIcon: Icon(Icons.female_rounded),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _sireTagController,
                  decoration: const InputDecoration(
                    labelText: 'Sire Tag (optional)',
                    prefixIcon: Icon(Icons.male_rounded),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_rounded,
                      color: Color(0xFF1A7A3C)),
                  title: const Text('Event Date'),
                  subtitle: Text(
                    '${_eventDate.day.toString().padLeft(2, '0')}/'
                    '${_eventDate.month.toString().padLeft(2, '0')}/'
                    '${_eventDate.year}',
                  ),
                  trailing: TextButton(
                    onPressed: _pickDate,
                    child: const Text('Change'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Calving Difficulty',
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (int i) {
                    final int val = i + 1;
                    final bool selected = _calvingDifficulty == val;
                    return GestureDetector(
                      onTap: () => setState(() => _calvingDifficulty = val),
                      child: Column(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFF1A7A3C)
                                  : const Color(0xFFEEEEEE),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$val',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: selected
                                      ? Colors.white
                                      : const Color(0xFF555555),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ['Easy', 'Slight', 'Mod.', 'Hard', 'Surgery'][i],
                            style: const TextStyle(
                                fontSize: 10, color: Color(0xFF888888)),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              children: [
                TextFormField(
                  controller: _birthWeightController,
                  decoration: const InputDecoration(
                    labelText: 'Birth Weight (optional)',
                    suffixText: 'kg',
                    prefixIcon: Icon(Icons.monitor_weight_rounded),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Delivery',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _ToggleButton(
                        label: 'Assisted',
                        isSelected: _isAssisted,
                        onTap: () => setState(() => _isAssisted = true),
                        color: const Color(0xFFF0A500),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ToggleButton(
                        label: 'Natural',
                        isSelected: !_isAssisted,
                        onTap: () => setState(() => _isAssisted = false),
                        color: const Color(0xFF1A7A3C),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Stillborn'),
                  value: _isStillborn,
                  onChanged: (bool v) => setState(() => _isStillborn = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Twin Birth'),
                  value: _isTwin,
                  onChanged: (bool v) => setState(() => _isTwin = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Vet Attended'),
                  value: _vetAttended,
                  onChanged: (bool v) => setState(() => _vetAttended = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Colostrum Fed'),
                  value: _colostrumFed,
                  onChanged: (bool v) => setState(() => _colostrumFed = v),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              children: [
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A7A3C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Birth Event',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  const _SectionCard({this.title, required this.children});

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
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF555555),
              ),
            ),
            const SizedBox(height: 12),
          ],
          ...children,
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;
  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color : const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: isSelected ? Colors.white : const Color(0xFF555555),
            ),
          ),
        ),
      ),
    );
  }
}
