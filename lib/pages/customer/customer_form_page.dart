import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class CustomerFormPage extends StatefulWidget {
  final Map<String, dynamic>? customer;
  const CustomerFormPage({Key? key, this.customer}) : super(key: key);

  @override
  _CustomerFormPageState createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthdayController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _firstNameController.text = widget.customer!['first_name'];
      _lastNameController.text = widget.customer!['last_name'];
      _addressController.text = widget.customer!['address'];
      _birthdayController.text = widget.customer!['birthday'];
    }
  }

  Future<void> _saveCustomer() async {
    if (_formKey.currentState!.validate()) {
      final customer = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'address': _addressController.text,
        'birthday': _birthdayController.text,
      };

      if (widget.customer == null) {
        await DatabaseHelper.instance.insert('customers', customer);
      } else {
        await DatabaseHelper.instance.update('customers', customer, widget.customer!['id']);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Customer Form")),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(controller: _firstNameController, decoration: const InputDecoration(labelText: "First Name")),
            TextFormField(controller: _lastNameController, decoration: const InputDecoration(labelText: "Last Name")),
            TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: "Address")),
            TextFormField(controller: _birthdayController, decoration: const InputDecoration(labelText: "Birthday")),
            ElevatedButton(onPressed: _saveCustomer, child: const Text("Save"))
          ],
        ),
      ),
    );
  }
}
