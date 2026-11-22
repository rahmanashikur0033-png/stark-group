import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/api_service.dart';

class VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicle; // null = register, not null = edit
  const VehicleFormScreen({super.key, this.vehicle});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  static const List<String> _types = ['Car', 'Truck', 'Van', 'Bus', 'Motorcycle'];
  static const List<String> _statuses = ['Active', 'Maintenance', 'Inactive'];

  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();

  late final TextEditingController _number;
  late final TextEditingController _brand;
  late final TextEditingController _model;
  late final TextEditingController _year;
  late String _type;
  late String _status;

  bool _saving = false;
  String? _numberError; // duplicate error coming from the server

  bool get _isEdit => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _number = TextEditingController(text: v?.vehicleNumber ?? '');
    _brand = TextEditingController(text: v?.brand ?? '');
    _model = TextEditingController(text: v?.model ?? '');
    _year = TextEditingController(text: v?.year.toString() ?? '');
    _type = v?.type ?? _types.first;
    _status = v?.status ?? _statuses.first;
  }

  @override
  void dispose() {
    _number.dispose();
    _brand.dispose();
    _model.dispose();
    _year.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  String? _validateYear(String? value) {
    final year = int.tryParse((value ?? '').trim());
    if (year == null) return 'Enter a valid year';
    final max = DateTime.now().year + 1;
    if (year < 1950 || year > max) return 'Year must be between 1950 and $max';
    return null;
  }

  Future<void> _save() async {
    setState(() => _numberError = null);
    if (!_formKey.currentState!.validate()) return;

    final vehicle = Vehicle(
      id: widget.vehicle?.id,
      vehicleNumber: _number.text.trim().toUpperCase(),
      type: _type,
      brand: _brand.text.trim(),
      model: _model.text.trim(),
      year: int.parse(_year.text.trim()),
      status: _status,
    );

    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await _api.updateVehicle(vehicle);
      } else {
        await _api.addVehicle(vehicle);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      if (e.statusCode == 409) {
        setState(() => _numberError = e.message);
        _formKey.currentState!.validate();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit vehicle' : 'Register vehicle'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _number,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: 'Vehicle number',
                      errorText: _numberError,
                      errorMaxLines: 2,
                    ),
                    onChanged: (_) {
                      if (_numberError != null) {
                        setState(() => _numberError = null);
                      }
                    },
                    validator: (v) => _required(v, 'Vehicle number'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Type'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _types
                        .map((t) => ChoiceChip(
                              label: Text(t),
                              selected: _type == t,
                              onSelected: (_) => setState(() => _type = t),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _brand,
                    decoration: const InputDecoration(labelText: 'Brand'),
                    validator: (v) => _required(v, 'Brand'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _model,
                    decoration: const InputDecoration(labelText: 'Model'),
                    validator: (v) => _required(v, 'Model'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _year,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Manufacture year'),
                    validator: _validateYear,
                  ),
                  const SizedBox(height: 16),
                  const Text('Status'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _statuses
                        .map((s) => ChoiceChip(
                              label: Text(s),
                              selected: _status == s,
                              onSelected: (_) => setState(() => _status = s),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      FilledButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(_isEdit ? 'Save changes' : 'Register vehicle'),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed:
                            _saving ? null : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
