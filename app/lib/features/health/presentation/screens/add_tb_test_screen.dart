import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database.dart';
import '../providers/health_provider.dart';

class AddTbTestScreen extends ConsumerStatefulWidget {
  final String? initialAnimalTag;
  const AddTbTestScreen({super.key, this.initialAnimalTag});

  @override
  ConsumerState<AddTbTestScreen> createState() => _AddTbTestScreenState();
}

class _AddTbTestScreenState extends ConsumerState<AddTbTestScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _tagController;
  final TextEditingController _vetNameController = TextEditingController();
  final TextEditingController _vetNumberController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _testDate = DateTime.now();
  DateTime? _nextTestDueDate;
  String _testType = 'individual';
  String _result = 'clear';
  bool _isRestricted = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tagController = TextEditingController(text: widget.initialAnimalTag ?? '');
  }

  @override
  void dispose() {
    _tagController.dispose();
    _vetNameController.dispose();
    _vetNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isNext) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isNext
          ? (_nextTestDueDate ?? DateTime.now().add(const Duration(days: 365)))
          : _testDate,
      firstDate: isNext ? DateTime.now() : DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isNext) {
          _nextTestDueDate = picked;
        } else {
          _testDate = picked;
        }
      });
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final TbTestEventsCompanion event = TbTestEventsCompanion(
      id: Value(const Uuid().v4()),
      animalId: Value(_tagController.text.trim().toUpperCase()),
      testDate: Value(_testDate),
      vetName: Value(_vetNameController.text.trim().isEmpty
          ? null
          : _vetNameController.text.trim()),
      vetNumber: Value(_vetNumberController.text.trim().isEmpty
          ? null
          : _vetNumberController.text.trim()),
      testType: Value(_testType),
      result: Value(_result),
      nextTestDueDate: Value(_nextTestDueDate),
      isRestricted: Value(_isRestricted),
      notes: Value(_notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim()),
    );

    await ref.read(healthRepositoryProvider).addTbTest(event);

    // Schedule notifications
    if (_nextTestDueDate != null) {
      final String farmName = _tagController.text.trim().toUpperCase();
      await ref.read(notificationRepositoryProvider).addNotification(
            NotificationsCompanion(
              id: Value(const Uuid().v4()),
              type: const Value('tb_due'),
              title: const Value('TB Test Due in 30 days'),
              body: Value('TB test for $farmName due on ${_fmtDate(_nextTestDueDate!)}'),
              dueDate: Value(_nextTestDueDate!.subtract(const Duration(days: 30))),
            ),
          );
      await ref.read(notificationRepositoryProvider).addNotification(
            NotificationsCompanion(
              id: Value(const Uuid().v4()),
              type: const Value('tb_due'),
              title: const Value('TB Test Due Today'),
              body: Value('TB test for $farmName is due today'),
              dueDate: Value(_nextTestDueDate!),
            ),
          );
    }

    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('TB test recorded')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text('Add TB Test'),
        backgroundColor: const Color(0xFF1A7A3C),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _card([
              TextFormField(
                controller: _tagController,
                decoration: const InputDecoration(
                  labelText: 'Animal Tag *',
                  prefixIcon: Icon(Icons.tag_rounded),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (String? v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ]),
            const SizedBox(height: 12),
            _card([
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_rounded,
                    color: Color(0xFF1A7A3C)),
                title: const Text('Test Date'),
                subtitle: Text(_fmtDate(_testDate)),
                trailing: TextButton(
                  onPressed: () => _pickDate(false),
                  child: const Text('Change'),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            _card([
              TextFormField(
                controller: _vetNameController,
                decoration: const InputDecoration(
                  labelText: 'Vet Name',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _vetNumberController,
                decoration: const InputDecoration(
                  labelText: 'Vet Number',
                  prefixIcon: Icon(Icons.badge_rounded),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            _card([
              const Text('Test Type',
                  style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF888888),
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                children: ['individual', 'herd'].map((String t) {
                  final bool sel = _testType == t;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _testType = t),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: sel
                                ? const Color(0xFF1A7A3C)
                                : const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              t == 'individual' ? 'Individual' : 'Herd',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: sel
                                    ? Colors.white
                                    : const Color(0xFF555555),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ]),
            const SizedBox(height: 12),
            _card([
              const Text('Result',
                  style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF888888),
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _ResultBtn(
                    label: 'Clear',
                    color: const Color(0xFF1A7A3C),
                    isSelected: _result == 'clear',
                    onTap: () => setState(() => _result = 'clear'),
                  ),
                  const SizedBox(width: 8),
                  _ResultBtn(
                    label: 'Reactor',
                    color: Colors.red,
                    isSelected: _result == 'reactor',
                    onTap: () => setState(() => _result = 'reactor'),
                  ),
                  const SizedBox(width: 8),
                  _ResultBtn(
                    label: 'Inconclusive',
                    color: const Color(0xFFF0A500),
                    isSelected: _result == 'inconclusive',
                    onTap: () => setState(() => _result = 'inconclusive'),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 12),
            _card([
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_rounded,
                    color: Color(0xFF1A7A3C)),
                title: const Text('Next Test Due Date'),
                subtitle: Text(_nextTestDueDate != null
                    ? _fmtDate(_nextTestDueDate!)
                    : 'Not set'),
                trailing: TextButton(
                  onPressed: () => _pickDate(true),
                  child: const Text('Set'),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Herd Restricted'),
                value: _isRestricted,
                onChanged: (bool v) => setState(() => _isRestricted = v),
              ),
            ]),
            const SizedBox(height: 12),
            _card([
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
                maxLines: 3,
              ),
            ]),
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
                    : const Text('Save TB Test',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );
}

class _ResultBtn extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  const _ResultBtn({
    required this.label,
    required this.color,
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
            color: isSelected ? color : const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF555555),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
