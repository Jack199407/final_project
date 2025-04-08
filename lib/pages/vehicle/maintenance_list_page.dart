// ✅ MaintenanceListPage with internationalization

import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import 'maintenance_form_page.dart';
import '../../localization/app_localizations.dart';

/// A page that displays a list of vehicle maintenance records.
///
/// Users can tap on a record to edit it or press the "+" button to add a new one.
/// Records are retrieved from a local SQLite database and can be deleted individually.
class MaintenanceListPage extends StatefulWidget {
  /// Creates a [MaintenanceListPage] widget.
  const MaintenanceListPage({Key? key}) : super(key: key);

  @override
  _MaintenanceListPageState createState() => _MaintenanceListPageState();
}

class _MaintenanceListPageState extends State<MaintenanceListPage> {
  /// A list holding all maintenance records fetched from the database.
  List<Map<String, dynamic>> _maintenanceRecords = [];

  @override
  void initState() {
    super.initState();
    _loadMaintenanceRecords();
  }

  /// Loads all maintenance records from the database into [_maintenanceRecords].
  Future<void> _loadMaintenanceRecords() async {
    final records = await DatabaseHelper.instance.queryAll('maintenance');
    setState(() {
      _maintenanceRecords = records;
    });
  }

  /// Deletes a maintenance record by its [id] and refreshes the list.
  Future<void> _deleteMaintenanceRecord(int id) async {
    await DatabaseHelper.instance.delete('maintenance', id);
    _loadMaintenanceRecords();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('vehicleMaintenanceRecords'))),
      body: _maintenanceRecords.isEmpty
          ? Center(
        child: Text(loc.translate('noRecordsTapToAdd')),
      )
          : ListView.builder(
        itemCount: _maintenanceRecords.length,
        itemBuilder: (context, index) {
          final record = _maintenanceRecords[index];
          return ListTile(
            title: Text(record['vehicle_name'] ?? ''),
            subtitle: Text("${record['service_type']} - ${record['service_date']}"),
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
