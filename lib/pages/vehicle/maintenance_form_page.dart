// ✅ MaintenanceFormPage with internationalization support

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../database/database_helper.dart';
import '../../localization/app_localizations.dart';
/// A page that allows users to create or edit a vehicle maintenance record.
///
/// This page uses a form with input fields for vehicle name, type, service
/// details, mileage, and cost. When editing an existing record, the fields are
/// pre-filled. User inputs are validated and saved to a local database and shared preferences.
class MaintenanceFormPage extends StatefulWidget {
  /// Optional maintenance record to edit; if null, a new record will be created.
  final Map<String, dynamic>? record;

  /// Creates a [MaintenanceFormPage] widget.
  const MaintenanceFormPage({Key? key, this.record}) : super(key: key);

  @override
  State<MaintenanceFormPage> createState() => _MaintenanceFormPageState();
}

class _MaintenanceFormPageState extends State<MaintenanceFormPage> {
  /// Key used to validate the form.
  final _formKey = GlobalKey<FormState>();

  /// Controller for the vehicle name input field.
  final _vehicleNameController = TextEditingController();

  /// Controller for the vehicle type input field.
  final _vehicleTypeController = TextEditingController();

  /// Controller for the service type input field.
  final _serviceTypeController = TextEditingController();

  /// Controller for the service date input field.
  final _serviceDateController = TextEditingController();

  /// Controller for the mileage input field.
  final _mileageController = TextEditingController();

  /// Controller for the cost input field.
  final _costController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _populateFields(widget.record!);
    } else {
      _loadFromPreferences();
    }
  }

  /// Fills form fields with data from an existing maintenance record.
  void _populateFields(Map<String, dynamic> record) {
    _vehicleNameController.text = record['vehicle_name'] ?? '';
    _vehicleTypeController.text = record['vehicle_type'] ?? '';
    _serviceTypeController.text = record['service_type'] ?? '';
    _serviceDateController.text = record['service_date'] ?? '';
    _mileageController.text = record['mileage'].toString();
    _costController.text = record['cost'].toString();
  }

  /// Loads default field values from shared preferences.
  Future<void> _loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _vehicleNameController.text = prefs.getString('last_vehicle_name') ?? '';
    _vehicleTypeController.text = prefs.getString('last_vehicle_type') ?? '';
    _serviceTypeController.text = prefs.getString('last_service_type') ?? '';
    _serviceDateController.text = prefs.getString('last_service_date') ?? '';
    _mileageController.text = prefs.getString('last_mileage') ?? '';
    _costController.text = prefs.getString('last_cost') ?? '';
  }

  /// Saves current field values to shared preferences for reuse.
  Future<void> _saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_vehicle_name', _vehicleNameController.text);
    await prefs.setString('last_vehicle_type', _vehicleTypeController.text);
    await prefs.setString('last_service_type', _serviceTypeController.text);
    await prefs.setString('last_service_date', _serviceDateController.text);
    await prefs.setString('last_mileage', _mileageController.text);
    await prefs.setString('last_cost', _costController.text);
  }

  /// Validates and saves the maintenance record to the database.
  ///
  /// If editing, it updates the record. If creating new, it inserts it.
  Future<void> _saveRecord() async {
    if (_formKey.currentState!.validate()) {
      final record = {
        'vehicle_name': _vehicleNameController.text,
        'vehicle_type': _vehicleTypeController.text,
        'service_type': _serviceTypeController.text,
        'service_date': _serviceDateController.text,
        'mileage': int.tryParse(_mileageController.text) ?? 0,
        'cost': double.tryParse(_costController.text) ?? 0.0,
      };

      if (widget.record == null) {
        await DatabaseHelper.instance.insert('maintenance', record);
        await _saveToPreferences();
      } else {
        await DatabaseHelper.instance.update('maintenance', record, widget.record!['id']);
      }

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  /// Deletes the current maintenance record from the database.
  Future<void> _deleteRecord() async {
    if (widget.record != null) {
      await DatabaseHelper.instance.delete('maintenance', widget.record!['id']);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.record != null;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? loc.translate('editMaintenance') : loc.translate('addMaintenance')),
        actions: isEditing
            ? [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteRecord,
          ),
        ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _vehicleNameController,
                decoration: InputDecoration(labelText: loc.translate('vehicleName')),
                validator: (value) =>
                value == null || value.isEmpty ? loc.translate('required') : null,
              ),
              TextFormField(
                controller: _vehicleTypeController,
                decoration: InputDecoration(labelText: loc.translate('vehicleType')),
                validator: (value) =>
                value == null || value.isEmpty ? loc.translate('required') : null,
              ),
              TextFormField(
                controller: _serviceTypeController,
                decoration: InputDecoration(labelText: loc.translate('serviceType')),
                validator: (value) =>
                value == null || value.isEmpty ? loc.translate('required') : null,
              ),
              TextFormField(
                controller: _serviceDateController,
                decoration: InputDecoration(
                  labelText: loc.translate('serviceDate'),
                  hintText: 'YYYY-MM-DD',
                ),
                validator: (value) =>
                value == null || value.isEmpty ? loc.translate('required') : null,
              ),
              TextFormField(
                controller: _mileageController,
                decoration: InputDecoration(labelText: loc.translate('mileage')),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value == null || value.isEmpty ? loc.translate('required') : null,
              ),
              TextFormField(
                controller: _costController,
                decoration: InputDecoration(labelText: loc.translate('cost')),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value == null || value.isEmpty ? loc.translate('required') : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveRecord,
                child: Text(isEditing ? loc.translate('update') : loc.translate('save')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
