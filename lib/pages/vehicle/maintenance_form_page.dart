import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../database/database_helper.dart';

class MaintenanceFormPage extends StatefulWidget {
  final Map<String, dynamic>? record;
  const MaintenanceFormPage({Key? key, this.record}) : super(key: key);

  @override
  _MaintenanceFormPageState createState() => _MaintenanceFormPageState();
}

class _MaintenanceFormPageState extends State<MaintenanceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNameController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _serviceTypeController = TextEditingController();
  final _serviceDateController = TextEditingController();
  final _mileageController = TextEditingController();
  final _costController = TextEditingController();

  final _storage = const FlutterSecureStorage(); // 用于保存上次记录

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _vehicleNameController.text = widget.record!['vehicle_name'];
      _vehicleTypeController.text = widget.record!['vehicle_type'];
      _serviceTypeController.text = widget.record!['service_type'];
      _serviceDateController.text = widget.record!['service_date'];
      _mileageController.text = widget.record!['mileage'].toString();
      _costController.text = widget.record!['cost'].toString();
    }
  }

  Future<void> _saveMaintenanceRecord() async {
    if (_formKey.currentState!.validate()) {
      final record = {
        'vehicle_name': _vehicleNameController.text,
        'vehicle_type': _vehicleTypeController.text,
        'service_type': _serviceTypeController.text,
        'service_date': _serviceDateController.text,
        'mileage': int.parse(_mileageController.text),
        'cost': double.parse(_costController.text),
      };

      // Save to DB
      if (widget.record == null) {
        await DatabaseHelper.instance.insert('maintenance', record);
      } else {
        await DatabaseHelper.instance.update('maintenance', record, widget.record!['id']);
      }

      // Save to EncryptedSharedPreferences
      for (var entry in record.entries) {
        await _storage.write(key: entry.key, value: entry.value.toString());
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Record saved successfully!")),
      );

      Navigator.pop(context);
    }
  }

  Future<void> _loadLastRecord() async {
    _vehicleNameController.text = await _storage.read(key: 'vehicle_name') ?? '';
    _vehicleTypeController.text = await _storage.read(key: 'vehicle_type') ?? '';
    _serviceTypeController.text = await _storage.read(key: 'service_type') ?? '';
    _serviceDateController.text = await _storage.read(key: 'service_date') ?? '';
    _mileageController.text = await _storage.read(key: 'mileage') ?? '';
    _costController.text = await _storage.read(key: 'cost') ?? '';

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Last record loaded.")),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Help / Instructions"),
        content: const Text(
            "• Fill out all fields before saving.\n"
                "• Press 'Copy Last' to reuse your last maintenance record.\n"
                "• Click 'Save' to submit, or return to the previous screen to cancel."),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maintenance Record Form"),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              TextFormField(
                controller: _vehicleNameController,
                decoration: const InputDecoration(labelText: "Vehicle Name"),
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _vehicleTypeController,
                decoration: const InputDecoration(labelText: "Vehicle Type"),
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _serviceTypeController,
                decoration: const InputDecoration(labelText: "Service Type"),
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _serviceDateController,
                decoration: const InputDecoration(labelText: "Service Date"),
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(labelText: "Mileage"),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(labelText: "Cost"),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveMaintenanceRecord,
                      child: const Text("Save"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _loadLastRecord,
                    child: const Text("Copy Last"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
