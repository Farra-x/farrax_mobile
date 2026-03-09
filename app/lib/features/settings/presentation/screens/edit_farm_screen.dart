import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/database.dart';
import '../../../farms/presentation/providers/farm_provider.dart';

class EditFarmScreen extends ConsumerStatefulWidget {
  const EditFarmScreen({super.key});

  @override
  ConsumerState<EditFarmScreen> createState() => _EditFarmScreenState();
}

class _EditFarmScreenState extends ConsumerState<EditFarmScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _herdController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _country = 'IE';
  bool _loaded = false;
  bool _isSaving = false;
  Farm? _farm;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _loadFarm();
    }
  }

  Future<void> _loadFarm() async {
    final Farm? farm = await ref.read(farmRepositoryProvider).getActiveFarm();
    if (farm != null && mounted) {
      setState(() {
        _farm = farm;
        _nameController.text = farm.name;
        _herdController.text = farm.herdNumber;
        _addressController.text = farm.address ?? '';
        _country = farm.country;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _farm == null) return;
    setState(() => _isSaving = true);

    await ref.read(farmRepositoryProvider).updateFarm(
          FarmsCompanion(
            id: Value(_farm!.id),
            name: Value(_nameController.text.trim()),
            herdNumber:
                Value(_herdController.text.trim().toUpperCase()),
            country: Value(_country),
            address: Value(_addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim()),
          ),
        );

    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Farm updated')),
      );
      context.pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _herdController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text('Edit Farm'),
        backgroundColor: const Color(0xFF1A7A3C),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Farm Name *',
                      prefixIcon: Icon(Icons.home_rounded),
                    ),
                    validator: (String? v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Required'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _herdController,
                    decoration: const InputDecoration(
                      labelText: 'Herd Number *',
                      prefixIcon: Icon(Icons.tag_rounded),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (String? v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Required'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: ['IE', 'UK'].map((String c) {
                      final bool sel = _country == c;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _country = c),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                              decoration: BoxDecoration(
                                color: sel
                                    ? const Color(0xFF1A7A3C)
                                    : const Color(0xFFEEEEEE),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  c,
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
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address (optional)',
                      prefixIcon: Icon(Icons.location_on_rounded),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
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
                    : const Text('Save Changes',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
