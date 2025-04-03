import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../database/database_helper.dart';
import '../../localization/app_localizations.dart';

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
      _populateFields(widget.customer!);
    } else {
      _promptLoadLast();
    }
  }

  void _populateFields(Map<String, dynamic> data) {
    _firstNameController.text = data['first_name'] ?? '';
    _lastNameController.text = data['last_name'] ?? '';
    _addressController.text = data['address'] ?? '';
    _birthdayController.text = data['birthday'] ?? '';
  }

  Future<void> _promptLoadLast() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('last_first_name')) return;

    final loc = AppLocalizations.of(context);
    final shouldLoad = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('copyLastCustomerTitle')),
        content: Text(loc.translate('copyLastCustomerPrompt')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(loc.translate('no'))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(loc.translate('yes'))),
        ],
      ),
    );

    if (shouldLoad == true) {
      setState(() {
        _firstNameController.text = prefs.getString('last_first_name') ?? '';
        _lastNameController.text = prefs.getString('last_last_name') ?? '';
        _addressController.text = prefs.getString('last_address') ?? '';
        _birthdayController.text = prefs.getString('last_birthday') ?? '';
      });
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_first_name', _firstNameController.text);
    await prefs.setString('last_last_name', _lastNameController.text);
    await prefs.setString('last_address', _addressController.text);
    await prefs.setString('last_birthday', _birthdayController.text);
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
        await _saveToPrefs();
      } else {
        await DatabaseHelper.instance.update('customers', customer, widget.customer!['id']);
      }

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.customer != null;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? loc.translate('editCustomer') : loc.translate('addCustomer'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: loc.translate('firstName')),
                validator: (v) => v == null || v.isEmpty ? loc.translate('required') : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: loc.translate('lastName')),
                validator: (v) => v == null || v.isEmpty ? loc.translate('required') : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: loc.translate('address')),
                validator: (v) => v == null || v.isEmpty ? loc.translate('required') : null,
              ),
              TextFormField(
                controller: _birthdayController,
                decoration: InputDecoration(labelText: loc.translate('birthday')),
                validator: (v) => v == null || v.isEmpty ? loc.translate('required') : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCustomer,
                child: Text(isEditing ? loc.translate('update') : loc.translate('save')),
              )
            ],
          ),
        ),
      ),
    );
  }
}