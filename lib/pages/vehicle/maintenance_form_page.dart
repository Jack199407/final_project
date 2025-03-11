import 'package:flutter/material.dart';
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

      if (widget.record == null) {
        await DatabaseHelper.instance.insert('maintenance', record);
      } else {
        await DatabaseHelper.instance.update('maintenance', record, widget.record!['id']);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Maintenance Record Form")),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(controller: _vehicleNameController, decoration: const InputDecoration(labelText: "Vehicle Name")),
              TextFormField(controller: _vehicleTypeController, decoration: const InputDecoration(labelText: "Vehicle Type")),
              TextFormField(controller: _serviceTypeController, decoration: const InputDecoration(labelText: "Service Type")),
              TextFormField(controller: _serviceDateController, decoration: const InputDecoration(labelText: "Service Date")),
              TextFormField(controller: _mileageController, decoration: const InputDecoration(labelText: "Mileage")),
              TextFormField(controller: _costController, decoration: const InputDecoration(labelText: "Cost")),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _saveMaintenanceRecord, child: const Text("Save"))
            ],
          ),
        ),
      ),
    );
  }
}
