// ✅ Updated: expense_form_page.dart with fixed date format and input hint

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../database/database_helper.dart';

class ExpenseFormPage extends StatefulWidget {
  final Map<String, dynamic>? expense;
  const ExpenseFormPage({Key? key, this.expense}) : super(key: key);

  @override
  _ExpenseFormPageState createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends State<ExpenseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _paymentController = TextEditingController();
  bool _loadedFromPrevious = false;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _populateFields(widget.expense!);
    } else {
      _promptLoadFromPrevious();
    }
  }

  Future<void> _promptLoadFromPrevious() async {
    final prefs = await SharedPreferences.getInstance();
    final hasData = prefs.containsKey('last_expense_name');
    if (!hasData) return;

    final shouldLoad = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Copy Previous Expense?"),
        content: const Text("Would you like to copy data from your last added expense?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
        ],
      ),
    );

    if (shouldLoad == true) {
      setState(() {
        _loadedFromPrevious = true;
        _nameController.text = prefs.getString('last_expense_name') ?? '';
        _categoryController.text = prefs.getString('last_expense_category') ?? '';
        _amountController.text = prefs.getString('last_expense_amount') ?? '';
        _dateController.text = prefs.getString('last_expense_date') ?? '';
        _paymentController.text = prefs.getString('last_expense_payment') ?? '';
      });
    }
  }

  Future<void> _saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_expense_name', _nameController.text);
    await prefs.setString('last_expense_category', _categoryController.text);
    await prefs.setString('last_expense_amount', _amountController.text);
    await prefs.setString('last_expense_date', _dateController.text);
    await prefs.setString('last_expense_payment', _paymentController.text);
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final expense = {
        'name': _nameController.text,
        'category': _categoryController.text,
        'amount': double.parse(_amountController.text),
        'date': _dateController.text,
        'payment_method': _paymentController.text,
      };

      if (widget.expense == null) {
        await DatabaseHelper.instance.insert('expenses', expense);
        await _saveToPreferences();
      } else {
        await DatabaseHelper.instance.update('expenses', expense, widget.expense!['id']);
      }

      Navigator.pop(context);
    }
  }

  Future<void> _deleteExpense() async {
    if (widget.expense != null) {
      await DatabaseHelper.instance.delete('expenses', widget.expense!['id']);
      Navigator.pop(context);
    }
  }

  void _populateFields(Map<String, dynamic> expense) {
    _nameController.text = expense['name'];
    _categoryController.text = expense['category'];
    _amountController.text = expense['amount'].toString();
    _dateController.text = expense['date'];
    _paymentController.text = expense['payment_method'];
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expense != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Expense" : "Add Expense"),
        actions: isEditing
            ? [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteExpense,
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
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Expense Name"),
                validator: (value) => value == null || value.isEmpty ? "Please enter an expense name" : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: "Category"),
                validator: (value) => value == null || value.isEmpty ? "Please enter a category" : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? "Please enter an amount" : null,
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: "Date (YYYY-MM-DD HH:mm)",
                  hintText: "e.g. 2024-05-01 14:30",
                ),
                validator: (value) => value == null || value.isEmpty ? "Please enter a date" : null,
              ),
              TextFormField(
                controller: _paymentController,
                decoration: const InputDecoration(labelText: "Payment Method"),
                validator: (value) => value == null || value.isEmpty ? "Please enter a payment method" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveExpense,
                child: Text(isEditing ? "Update Expense" : "Add Expense"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
