import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import 'maintenance_form_page.dart';

class MaintenanceListPage extends StatefulWidget {
  const MaintenanceListPage({Key? key}) : super(key: key);

  @override
  _MaintenanceListPageState createState() => _MaintenanceListPageState();
}

class _MaintenanceListPageState extends State<MaintenanceListPage> {
  List<Map<String, dynamic>> _maintenanceRecords = [];

  @override
  void initState() {
    super.initState();
    _loadMaintenanceRecords();
  }

  Future<void> _loadMaintenanceRecords() async {
    final records = await DatabaseHelper.instance.queryAll('maintenance');
    setState(() {
      _maintenanceRecords = records;
    });
  }

  Future<void> _deleteMaintenanceRecord(int id) async {
    await DatabaseHelper.instance.delete('maintenance', id);
    _loadMaintenanceRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vehicle Maintenance Records")),
      body: ListView.builder(
        itemCount: _maintenanceRecords.length,
        itemBuilder: (context, index) {
          final record = _maintenanceRecords[index];
          return ListTile(
            title: Text(record['vehicle_name']),
            subtitle: Text("Service: ${record['service_type']} - ${record['service_date']}"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MaintenanceFormPage(record: record),
                ),
              ).then((_) => _loadMaintenanceRecords());
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteMaintenanceRecord(record['id']),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MaintenanceFormPage()),
          ).then((_) => _loadMaintenanceRecords());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
