import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'vehicle_form_screen.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final ApiService _api = ApiService();
  List<Vehicle> _vehicles = [];
  bool _loading = true;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.getVehicles();
      if (!mounted) return;
      setState(() {
        _vehicles = data;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _openForm([Vehicle? vehicle]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => VehicleFormScreen(vehicle: vehicle)),
    );
    if (saved == true) {
      _load();
      if (!mounted) return;
      _toast(vehicle == null ? 'Vehicle registered.' : 'Vehicle updated.');
    }
  }

  Future<void> _delete(Vehicle vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete vehicle?'),
        content: Text('${vehicle.vehicleNumber} will be removed permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _api.deleteVehicle(vehicle.id!);
      if (!mounted) return;
      _toast('Vehicle deleted.');
      _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      _toast(e.message);
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  List<Vehicle> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _vehicles;
    return _vehicles.where((v) {
      return v.vehicleNumber.toLowerCase().contains(q) ||
          v.brand.toLowerCase().contains(q) ||
          v.model.toLowerCase().contains(q) ||
          v.type.toLowerCase().contains(q) ||
          v.status.toLowerCase().contains(q);
    }).toList();
  }

  MaterialColor _statusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Maintenance':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'Truck':
        return Icons.local_shipping;
      case 'Van':
        return Icons.airport_shuttle;
      case 'Bus':
        return Icons.directions_bus;
      case 'Motorcycle':
        return Icons.two_wheeler;
      default:
        return Icons.directions_car;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stark Group Vehicles'),
        actions: [
          IconButton(
            tooltip: 'Reload',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            ),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Register vehicle'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search by number, brand, model, type or status',
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: 12),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: const Text('Try again')),
          ],
        ),
      );
    }
    final items = _filtered;
    if (items.isEmpty) {
      return Center(
        child: Text(_vehicles.isEmpty
            ? 'No vehicles yet. Choose Register vehicle to add one.'
            : 'No vehicles match your search.'),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        itemCount: items.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == items.length) return const SizedBox(height: 72);
          return _buildRow(items[index]);
        },
      ),
    );
  }

  Widget _buildRow(Vehicle v) {
    final color = _statusColor(v.status);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(_typeIcon(v.type), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v.vehicleNumber,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text('${v.brand} ${v.model}, ${v.year}, ${v.type}'),
                ],
              ),
            ),
            Chip(
              label: Text(v.status),
              backgroundColor: color.shade100,
              side: BorderSide.none,
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              tooltip: 'Edit',
              onPressed: () => _openForm(v),
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Delete',
              onPressed: () => _delete(v),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}
