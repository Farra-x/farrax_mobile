import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database.dart';
import '../providers/health_provider.dart';

class AddHealthEventScreen extends ConsumerStatefulWidget {
  final String? initialAnimalTag;
  const AddHealthEventScreen({super.key, this.initialAnimalTag});

  @override
  ConsumerState<AddHealthEventScreen> createState() =>
      _AddHealthEventScreenState();
}

class _AddHealthEventScreenState extends ConsumerState<AddHealthEventScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _tagController;
  final TextEditingController _vetNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _vaccineNameController = TextEditingController();
  final TextEditingController _batchController = TextEditingController();
  final TextEditingController _daysInCalfController = TextEditingController();
  final TextEditingController _bullSireController = TextEditingController();

  String _eventType = 'BVD Test';
  DateTime _eventDate = DateTime.now();
  String? _bvdResult;
  int _bcsScore = 3;
  String? _pregnancyResult;
  String _serviceType = 'Natural';
  bool _isSaving = false;

  static const List<String> _eventTypes = [
    'BVD Test',
    'Vaccination',
    'Body Condition Score',
    'Weight',
    'Pregnancy',
    'Fertility',
  ];

  @override
  void initState() {
    super.initState();
    _tagController = TextEditingController(text: widget.initialAnimalTag ?? '');
  }

  @override
  void dispose() {
    _tagController.dispose();
    _vetNameController.dispose();
    _notesController.dispose();
    _resultController.dispose();
    _valueController.dispose();
    _vaccineNameController.dispose();
    _batchController.dispose();
    _daysInCalfController.dispose();
    _bullSireController.dispose();
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

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String? _buildResult() {
    switch (_eventType) {
      case 'BVD Test':
        return _bvdResult;
      case 'Vaccination':
        return _vaccineNameController.text.trim().isEmpty
            ? null
            : _vaccineNameController.text.trim();
      case 'Body Condition Score':
        return '$_bcsScore / 5';
      case 'Pregnancy':
        return _pregnancyResult;
      default:
        return _resultController.text.trim().isEmpty
            ? null
            : _resultController.text.trim();
    }
  }

  double? _buildValue() {
    switch (_eventType) {
      case 'Weight':
        return double.tryParse(_valueController.text);
      case 'Body Condition Score':
        return _bcsScore.toDouble();
      case 'Pregnancy':
        return double.tryParse(_daysInCalfController.text);
      default:
        return null;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final HealthEventsCompanion event = HealthEventsCompanion(
      id: Value(const Uuid().v4()),
      animalId: Value(_tagController.text.trim().toUpperCase()),
      eventType: Value(_eventType),
      eventDate: Value(_eventDate),
      result: Value(_buildResult()),
      value: Value(_buildValue()),
      vetName: Value(_vetNameController.text.trim().isEmpty
          ? null
          : _vetNameController.text.trim()),
      notes: Value(_notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim()),
    );

    await ref.read(healthRepositoryProvider).addHealthEvent(event);

    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Health event recorded')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text('Health Event'),
        backgroundColor: const Color(0xFF1A7A3C),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Event type chips
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _eventTypes.map((String t) {
                  final bool sel = _eventType == t;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(t),
                      selected: sel,
                      onSelected: (_) => setState(() => _eventType = t),
                      selectedColor: const Color(0xFF1A7A3C),
                      labelStyle: TextStyle(
                        color: sel ? Colors.white : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

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
                title: const Text('Event Date'),
                subtitle: Text(_fmtDate(_eventDate)),
                trailing: TextButton(
                  onPressed: _pickDate,
                  child: const Text('Change'),
                ),
              ),
            ]),
            const SizedBox(height: 12),

            // Type-specific fields
            _buildTypeSpecificFields(),

            _card([
              TextFormField(
                controller: _vetNameController,
                decoration: const InputDecoration(
                  labelText: 'Vet Name (optional)',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
              ),
              const SizedBox(height: 12),
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
                    : const Text('Save Event',
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

  Widget _buildTypeSpecificFields() {
    switch (_eventType) {
      case 'BVD Test':
        return _card([
          const Text('Result',
              style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Positive', 'Negative'].map((String r) {
              final bool sel = _bvdResult == r;
              return ChoiceChip(
                label: Text(r),
                selected: sel,
                onSelected: (_) => setState(() => _bvdResult = r),
                selectedColor:
                    r == 'Positive' ? Colors.red : const Color(0xFF1A7A3C),
                labelStyle: TextStyle(
                  color: sel ? Colors.white : null,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        ]);

      case 'Vaccination':
        return _card([
          TextFormField(
            controller: _vaccineNameController,
            decoration: const InputDecoration(
              labelText: 'Vaccine Name',
              prefixIcon: Icon(Icons.vaccines_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _batchController,
            decoration: const InputDecoration(
              labelText: 'Batch Number (optional)',
              prefixIcon: Icon(Icons.numbers_rounded),
            ),
          ),
        ]);

      case 'Body Condition Score':
        return _card([
          const Text('BCS Score (1–5)',
              style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (int i) {
              final int val = i + 1;
              final bool sel = _bcsScore == val;
              return GestureDetector(
                onTap: () => setState(() => _bcsScore = val),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: sel
                        ? const Color(0xFF1A7A3C)
                        : const Color(0xFFEEEEEE),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$val',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color:
                            sel ? Colors.white : const Color(0xFF555555),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ]);

      case 'Weight':
        return _card([
          TextFormField(
            controller: _valueController,
            decoration: const InputDecoration(
              labelText: 'Weight',
              suffixText: 'kg',
              prefixIcon: Icon(Icons.monitor_weight_rounded),
            ),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
        ]);

      case 'Pregnancy':
        return _card([
          const Text('Result',
              style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Pregnant', 'Empty', 'Repeat'].map((String r) {
              final bool sel = _pregnancyResult == r;
              return ChoiceChip(
                label: Text(r),
                selected: sel,
                onSelected: (_) => setState(() => _pregnancyResult = r),
                selectedColor: const Color(0xFF1A7A3C),
                labelStyle: TextStyle(
                  color: sel ? Colors.white : null,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _daysInCalfController,
            decoration: const InputDecoration(
              labelText: 'Days in Calf (optional)',
              prefixIcon: Icon(Icons.child_care_rounded),
            ),
            keyboardType: TextInputType.number,
          ),
        ]);

      case 'Fertility':
        return _card([
          const Text('Service Type',
              style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: ['Natural', 'AI'].map((String t) {
              final bool sel = _serviceType == t;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _serviceType = t),
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
                          t,
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
          const SizedBox(height: 12),
          TextFormField(
            controller: _bullSireController,
            decoration: InputDecoration(
              labelText: _serviceType == 'AI' ? 'AI Sire' : 'Bull Tag',
              prefixIcon: const Icon(Icons.male_rounded),
            ),
          ),
        ]);

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _card(List<Widget> children) => Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );
}
