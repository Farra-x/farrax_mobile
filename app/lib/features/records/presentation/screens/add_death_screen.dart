import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database.dart';
import '../providers/records_provider.dart';

class AddDeathScreen extends ConsumerStatefulWidget {
  final String? initialAnimalTag;
  const AddDeathScreen({super.key, this.initialAnimalTag});

  @override
  ConsumerState<AddDeathScreen> createState() => _AddDeathScreenState();
}

class _AddDeathScreenState extends ConsumerState<AddDeathScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _tagController;
  final TextEditingController _slaughterWeightController =
      TextEditingController();
  final TextEditingController _estimatedValueController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _eventDate = DateTime.now();
  String? _causeOfDeath;
  String? _disposalMethod;
  bool _tagReturned = false;
  bool _vetConfirmed = false;
  bool _authoritiesNotified = false;
  bool _isSaving = false;

  static const List<String> _causes = [
    'Disease',
    'Injury',
    'Calving Difficulty',
    'Perinatal',
    'Unknown',
    'Other',
  ];

  static const List<String> _disposals = [
    'Knackery',
    'Slaughter',
    'Fallen Stock Collector',
    'Buried on Farm',
  ];

  @override
  void initState() {
    super.initState();
    _tagController = TextEditingController(text: widget.initialAnimalTag ?? '');
  }

  @override
  void dispose() {
    _tagController.dispose();
    _slaughterWeightController.dispose();
    _estimatedValueController.dispose();
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

    final DeathEventsCompanion event = DeathEventsCompanion(
      id: Value(const Uuid().v4()),
      animalId: Value(tag),
      eventDate: Value(_eventDate),
      causeOfDeath: Value(_causeOfDeath),
      disposalMethod: Value(_disposalMethod),
      slaughterWeight:
          Value(double.tryParse(_slaughterWeightController.text)),
      tagReturned: Value(_tagReturned),
      vetConfirmed: Value(_vetConfirmed),
      authoritiesNotified: Value(_authoritiesNotified),
      estimatedValue:
          Value(double.tryParse(_estimatedValueController.text)),
      notes: Value(_notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim()),
    );

    await ref.read(deathRepositoryProvider).addDeathEvent(event);

    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Death event recorded')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text('Record Death'),
        backgroundColor: const Color(0xFF1A7A3C),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _card(children: [
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
            ]),
            const SizedBox(height: 12),
            _card(children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_rounded,
                    color: Color(0xFF1A7A3C)),
                title: const Text('Date of Death'),
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
            ]),
            const SizedBox(height: 12),
            _card(children: [
              DropdownButtonFormField<String>(
                initialValue: _causeOfDeath,
                decoration: const InputDecoration(
                  labelText: 'Cause of Death',
                  prefixIcon: Icon(Icons.report_rounded),
                ),
                items: _causes
                    .map((String c) => DropdownMenuItem<String>(
                          value: c,
                          child: Text(c),
                        ))
                    .toList(),
                onChanged: (String? v) => setState(() => _causeOfDeath = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _disposalMethod,
                decoration: const InputDecoration(
                  labelText: 'Disposal Method',
                  prefixIcon: Icon(Icons.delete_rounded),
                ),
                items: _disposals
                    .map((String d) => DropdownMenuItem<String>(
                          value: d,
                          child: Text(d),
                        ))
                    .toList(),
                onChanged: (String? v) => setState(() => _disposalMethod = v),
              ),
            ]),
            const SizedBox(height: 12),
            _card(children: [
              TextFormField(
                controller: _slaughterWeightController,
                decoration: const InputDecoration(
                  labelText: 'Slaughter Weight (optional)',
                  suffixText: 'kg',
                  prefixIcon: Icon(Icons.monitor_weight_rounded),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _estimatedValueController,
                decoration: const InputDecoration(
                  labelText: 'Estimated Value (optional)',
                  prefixText: '€ ',
                  prefixIcon: Icon(Icons.euro_rounded),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ]),
            const SizedBox(height: 12),
            _card(children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tag Returned'),
                value: _tagReturned,
                onChanged: (bool v) => setState(() => _tagReturned = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Vet Confirmed'),
                value: _vetConfirmed,
                onChanged: (bool v) => setState(() => _vetConfirmed = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Authorities Notified'),
                value: _authoritiesNotified,
                onChanged: (bool v) =>
                    setState(() => _authoritiesNotified = v),
              ),
            ]),
            const SizedBox(height: 12),
            _card(children: [
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
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Death Record',
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

  Widget _card({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
