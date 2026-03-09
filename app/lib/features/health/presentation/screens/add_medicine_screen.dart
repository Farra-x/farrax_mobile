import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database.dart';
import '../../data/medicine_repository.dart';
import '../providers/health_provider.dart';

class AddMedicineScreen extends ConsumerStatefulWidget {
  final String? initialAnimalTag;
  const AddMedicineScreen({super.key, this.initialAnimalTag});

  @override
  ConsumerState<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends ConsumerState<AddMedicineScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _tagController;
  final TextEditingController _drugNameController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _batchController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _meatDaysController = TextEditingController();
  final TextEditingController _milkDaysController = TextEditingController();
  final TextEditingController _vetNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _eventDate = DateTime.now();
  String _doseUnit = 'ml';
  String _route = 'Injection';
  String _treatedBy = 'Farmer';
  bool _isSaving = false;

  DateTime? get _meatClear => _meatDays != null
      ? _eventDate.add(Duration(days: _meatDays!))
      : null;
  DateTime? get _milkClear => _milkDays != null
      ? _eventDate.add(Duration(days: _milkDays!))
      : null;
  int? get _meatDays => int.tryParse(_meatDaysController.text);
  int? get _milkDays => int.tryParse(_milkDaysController.text);

  @override
  void initState() {
    super.initState();
    _tagController = TextEditingController(text: widget.initialAnimalTag ?? '');
  }

  @override
  void dispose() {
    _tagController.dispose();
    _drugNameController.dispose();
    _diagnosisController.dispose();
    _batchController.dispose();
    _doseController.dispose();
    _meatDaysController.dispose();
    _milkDaysController.dispose();
    _vetNameController.dispose();
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

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final MedicineEventsCompanion event = MedicineEventsCompanion(
      id: Value(const Uuid().v4()),
      animalId: Value(_tagController.text.trim().toUpperCase()),
      drugName: Value(_drugNameController.text.trim()),
      diagnosis: Value(_diagnosisController.text.trim().isEmpty
          ? null
          : _diagnosisController.text.trim()),
      eventDate: Value(_eventDate),
      batchNumber: Value(_batchController.text.trim().isEmpty
          ? null
          : _batchController.text.trim()),
      doseGiven: Value(double.tryParse(_doseController.text)),
      doseUnit: Value(_doseUnit),
      route: Value(_route),
      withdrawalMeatDays: Value(_meatDays),
      withdrawalMilkDays: Value(_milkDays),
      meatClearDate: Value(_meatClear),
      milkClearDate: Value(_milkClear),
      treatedBy: Value(_treatedBy),
      vetName: Value(_treatedBy == 'Vet' && _vetNameController.text.trim().isNotEmpty
          ? _vetNameController.text.trim()
          : null),
    );

    await ref.read(medicineRepositoryProvider).addTreatment(event);

    // Schedule withdrawal notifications
    if (_meatClear != null) {
      await ref.read(notificationRepositoryProvider).addNotification(
            NotificationsCompanion(
              id: Value(const Uuid().v4()),
              type: const Value('withdrawal'),
              title: Value(
                  'Meat withdrawal ending — ${_tagController.text.trim().toUpperCase()}'),
              body: Value(
                  '${_drugNameController.text.trim()} meat withdrawal clears on ${_fmtDate(_meatClear!)}'),
              dueDate: Value(_meatClear!),
            ),
          );
    }
    if (_milkClear != null) {
      await ref.read(notificationRepositoryProvider).addNotification(
            NotificationsCompanion(
              id: Value(const Uuid().v4()),
              type: const Value('withdrawal'),
              title: Value(
                  'Milk withdrawal ending — ${_tagController.text.trim().toUpperCase()}'),
              body: Value(
                  '${_drugNameController.text.trim()} milk withdrawal clears on ${_fmtDate(_milkClear!)}'),
              dueDate: Value(_milkClear!),
            ),
          );
    }

    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Treatment recorded')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> drugNames = MedicineRepository.preloadedDrugNames();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text('Record Treatment'),
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
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue val) {
                  if (val.text.isEmpty) return drugNames;
                  return drugNames.where((String n) =>
                      n.toLowerCase().contains(val.text.toLowerCase()));
                },
                onSelected: (String s) => _drugNameController.text = s,
                fieldViewBuilder: (_, TextEditingController c, FocusNode f, __) {
                  if (_drugNameController.text.isNotEmpty &&
                      c.text != _drugNameController.text) {
                    c.text = _drugNameController.text;
                  }
                  return TextFormField(
                    controller: c,
                    focusNode: f,
                    decoration: const InputDecoration(
                      labelText: 'Drug Name *',
                      prefixIcon: Icon(Icons.medication_rounded),
                    ),
                    onChanged: (String v) => _drugNameController.text = v,
                    validator: (String? v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  );
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _diagnosisController,
                decoration: const InputDecoration(
                  labelText: 'Diagnosis / Reason',
                  prefixIcon: Icon(Icons.description_rounded),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            _card([
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_rounded,
                    color: Color(0xFF1A7A3C)),
                title: const Text('Treatment Date'),
                subtitle: Text(_fmtDate(_eventDate)),
                trailing: TextButton(
                  onPressed: _pickDate,
                  child: const Text('Change'),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            _card([
              TextFormField(
                controller: _batchController,
                decoration: const InputDecoration(
                  labelText: 'Batch Number (optional)',
                  prefixIcon: Icon(Icons.numbers_rounded),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _doseController,
                      decoration: const InputDecoration(labelText: 'Dose'),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Wrap(
                    spacing: 6,
                    children: ['ml', 'mg', 'g'].map((String u) {
                      final bool selected = _doseUnit == u;
                      return ChoiceChip(
                        label: Text(u),
                        selected: selected,
                        onSelected: (_) => setState(() => _doseUnit = u),
                        selectedColor: const Color(0xFF1A7A3C),
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : null,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['Injection', 'Oral', 'Topical'].map((String r) {
                  final bool selected = _route == r;
                  return ChoiceChip(
                    label: Text(r),
                    selected: selected,
                    onSelected: (_) => setState(() => _route = r),
                    selectedColor: const Color(0xFF1A7A3C),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : null,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
            ]),
            const SizedBox(height: 12),
            _card([
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _meatDaysController,
                      decoration: const InputDecoration(
                          labelText: 'Meat WD Days'),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _milkDaysController,
                      decoration: const InputDecoration(
                          labelText: 'Milk WD Days'),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              if (_meatClear != null || _milkClear != null) ...[
                const SizedBox(height: 8),
                if (_meatClear != null)
                  Text('Meat clear: ${_fmtDate(_meatClear!)}',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF1A7A3C))),
                if (_milkClear != null)
                  Text('Milk clear: ${_fmtDate(_milkClear!)}',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF0D6EAF))),
              ],
            ]),
            const SizedBox(height: 12),
            _card([
              const Text('Treated By',
                  style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF888888),
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                children: ['Farmer', 'Vet'].map((String t) {
                  final bool selected = _treatedBy == t;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _treatedBy = t),
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF1A7A3C)
                                : const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              t,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: selected
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
              if (_treatedBy == 'Vet') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _vetNameController,
                  decoration: const InputDecoration(
                    labelText: 'Vet Name',
                    prefixIcon: Icon(Icons.person_rounded),
                  ),
                ),
              ],
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
                    : const Text('Save Treatment',
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
        margin: const EdgeInsets.only(bottom: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );
}
