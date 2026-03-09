import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database.dart';
import '../providers/movement_provider.dart';

class AddMovementScreen extends ConsumerStatefulWidget {
  final String? initialTag;
  const AddMovementScreen({super.key, this.initialTag});

  @override
  ConsumerState<AddMovementScreen> createState() => _AddMovementScreenState();
}

class _AddMovementScreenState extends ConsumerState<AddMovementScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isBatch = false;
  bool _isSaving = false;

  // Single mode
  late TextEditingController _tagController;

  // Batch mode
  final List<String> _batchTags = [];
  final TextEditingController _batchTagInputController =
      TextEditingController();

  // Shared fields
  String _movementType = 'in';
  DateTime _eventDate = DateTime.now();
  final TextEditingController _originFarmController = TextEditingController();
  final TextEditingController _destFarmController = TextEditingController();
  final TextEditingController _destHerdController = TextEditingController();
  final TextEditingController _transportController = TextEditingController();
  final TextEditingController _vehicleRegController = TextEditingController();
  final TextEditingController _docNumberController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tagController = TextEditingController(text: widget.initialTag ?? '');
  }

  @override
  void dispose() {
    _tagController.dispose();
    _batchTagInputController.dispose();
    _originFarmController.dispose();
    _destFarmController.dispose();
    _destHerdController.dispose();
    _transportController.dispose();
    _vehicleRegController.dispose();
    _docNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  MovementEventsCompanion _buildTemplate() {
    return MovementEventsCompanion(
      id: Value(const Uuid().v4()),
      animalId: const Value(''),
      movementType: Value(_movementType),
      eventDate: Value(_eventDate),
      originFarmName: Value(_originFarmController.text.trim().isEmpty
          ? null
          : _originFarmController.text.trim()),
      destinationFarmName: Value(_destFarmController.text.trim().isEmpty
          ? null
          : _destFarmController.text.trim()),
      destinationHerdNumber: Value(_destHerdController.text.trim().isEmpty
          ? null
          : _destHerdController.text.trim().toUpperCase()),
      transportCompany: Value(_transportController.text.trim().isEmpty
          ? null
          : _transportController.text.trim()),
      vehicleRegistration: Value(_vehicleRegController.text.trim().isEmpty
          ? null
          : _vehicleRegController.text.trim().toUpperCase()),
      movementDocNumber: Value(_docNumberController.text.trim().isEmpty
          ? null
          : _docNumberController.text.trim()),
      notes: Value(_notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim()),
    );
  }

  Future<void> _saveSingle() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final String tag = _tagController.text.trim().toUpperCase();
    final MovementEventsCompanion event =
        _buildTemplate().copyWith(animalId: Value(tag));

    await ref
        .read(movementRepositoryFeatureProvider)
        .addMovementEvent(event);

    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movement recorded')),
      );
      context.pop();
    }
  }

  Future<void> _saveBatch() async {
    if (_batchTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one animal tag')),
      );
      return;
    }
    setState(() => _isSaving = true);

    await ref
        .read(movementRepositoryFeatureProvider)
        .addBatchMovement(_batchTags, _buildTemplate());

    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${_batchTags.length} movements recorded')),
      );
      context.pop();
    }
  }

  void _addBatchTag() {
    final String tag = _batchTagInputController.text.trim().toUpperCase();
    if (tag.isNotEmpty && !_batchTags.contains(tag)) {
      setState(() => _batchTags.add(tag));
      _batchTagInputController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text('Record Movement'),
        backgroundColor: const Color(0xFF1A7A3C),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Single / Batch toggle
            _card(children: [
              Row(
                children: [
                  Expanded(
                    child: _ToggleBtn(
                      label: 'Single',
                      isSelected: !_isBatch,
                      onTap: () => setState(() => _isBatch = false),
                      color: const Color(0xFF1A7A3C),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ToggleBtn(
                      label: 'Batch',
                      isSelected: _isBatch,
                      onTap: () => setState(() => _isBatch = true),
                      color: const Color(0xFF0D6EAF),
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 12),

            // Tag input
            if (!_isBatch)
              _card(children: [
                TextFormField(
                  controller: _tagController,
                  decoration: const InputDecoration(
                    labelText: 'Animal Tag *',
                    hintText: 'IE141123456789',
                    prefixIcon: Icon(Icons.tag_rounded),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (String? v) => (v == null || v.trim().isEmpty)
                      ? 'Tag is required'
                      : null,
                ),
              ])
            else
              _card(children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _batchTagInputController,
                        decoration: const InputDecoration(
                          labelText: 'Add Tag',
                          hintText: 'IE141123456789',
                        ),
                        textCapitalization: TextCapitalization.characters,
                        onFieldSubmitted: (_) => _addBatchTag(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _addBatchTag,
                      icon: const Icon(Icons.add_circle_rounded,
                          color: Color(0xFF1A7A3C)),
                    ),
                  ],
                ),
                if (_batchTags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _batchTags
                        .map((String t) => Chip(
                              label: Text(t,
                                  style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12)),
                              onDeleted: () =>
                                  setState(() => _batchTags.remove(t)),
                              backgroundColor:
                                  const Color(0xFF1A7A3C).withValues(alpha: 0.1),
                            ))
                        .toList(),
                  ),
                  Text(
                    '${_batchTags.length} animal${_batchTags.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF888888)),
                  ),
                ],
              ]),
            const SizedBox(height: 12),

            // IN / OUT toggle
            _card(children: [
              const Text(
                'Movement Direction',
                style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF888888),
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ToggleBtn(
                      label: 'IN',
                      isSelected: _movementType == 'in',
                      onTap: () => setState(() => _movementType = 'in'),
                      color: const Color(0xFF1A7A3C),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ToggleBtn(
                      label: 'OUT',
                      isSelected: _movementType == 'out',
                      onTap: () => setState(() => _movementType = 'out'),
                      color: const Color(0xFFF0A500),
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 12),

            // Date
            _card(children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_rounded,
                    color: Color(0xFF1A7A3C)),
                title: const Text('Movement Date'),
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

            // Farm details
            _card(children: [
              TextFormField(
                controller: _originFarmController,
                decoration: const InputDecoration(
                  labelText: 'Origin Farm Name',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _destFarmController,
                decoration: const InputDecoration(
                  labelText: 'Destination Farm Name',
                  prefixIcon: Icon(Icons.home_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _destHerdController,
                decoration: const InputDecoration(
                  labelText: 'Destination Herd Number',
                  prefixIcon: Icon(Icons.tag_rounded),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
            ]),
            const SizedBox(height: 12),

            // Transport
            _card(children: [
              TextFormField(
                controller: _transportController,
                decoration: const InputDecoration(
                  labelText: 'Transport Company (optional)',
                  prefixIcon: Icon(Icons.local_shipping_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _vehicleRegController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Registration (optional)',
                  prefixIcon: Icon(Icons.directions_car_rounded),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _docNumberController,
                decoration: const InputDecoration(
                  labelText: 'Movement Doc Number (optional)',
                  prefixIcon: Icon(Icons.description_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
                maxLines: 2,
              ),
            ]),
            const SizedBox(height: 24),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed:
                    _isSaving ? null : (_isBatch ? _saveBatch : _saveSingle),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A7A3C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isBatch
                            ? 'Save ${_batchTags.length} Movements'
                            : 'Save Movement',
                        style: const TextStyle(
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

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;
  const _ToggleBtn({
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
