import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import 'customer_form_page.dart';
import '../../localization/app_localizations.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({Key? key}) : super(key: key);

  @override
  _CustomerListPageState createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  List<Map<String, dynamic>> _customers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final customers = await DatabaseHelper.instance.queryAll('customers');
    setState(() {
      _customers = customers;
    });
  }

  Future<void> _deleteCustomer(int id) async {
    await DatabaseHelper.instance.delete('customers', id);
    _loadCustomers();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('customers'))),
      body: _customers.isEmpty
          ? Center(child: Text(loc.translate('noCustomersTapToAdd')))
          : ListView.builder(
        itemCount: _customers.length,
        itemBuilder: (context, index) {
          final customer = _customers[index];
          return ListTile(
            title: Text("${customer['first_name']} ${customer['last_name']}"),
            subtitle: Text("${loc.translate('birthday')}: ${customer['birthday']}"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomerFormPage(customer: customer),
                ),
              ).then((_) => _loadCustomers());
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteCustomer(customer['id']),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CustomerFormPage()),
          ).then((_) => _loadCustomers());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}