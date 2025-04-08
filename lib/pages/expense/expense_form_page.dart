import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../database/database_helper.dart';
import '../../localization/app_localizations.dart';

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

    final loc = AppLocalizations.of(context);

    final shouldLoad = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate("copyPreviousEvent")),
        content: Text(loc.translate("copyPreviousEventQuestion")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(loc.translate("no"))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(loc.translate("yes"))),
        ],
      ),
    );

    if (shouldLoad == true) {
      setState(() {
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
    final loc = AppLocalizations.of(context);
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
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? loc.translate("editEvent") : loc.translate("addExpense")),
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
                decoration: InputDecoration(labelText: loc.translate("eventName")),
                validator: (value) =>
                value == null || value.isEmpty ? loc.translate("nameRequired") : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: loc.translate("category")),
                validator: (value) =>
                value == null || value.isEmpty ? loc.translate("required") : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: loc.translate("amount")),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value == null || value.isEmpty ? loc.translate("required") : null,
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: loc.translate("date"),
                  hintText: "YYYY-MM-DD HH:mm",
                ),
                validator: (value) =>
                value == null || value.isEmpty ? loc.translate("required") : null,
              ),
              TextFormField(
                controller: _paymentController,
                decoration: InputDecoration(labelText: loc.translate("paymentMethod")),
                validator: (value) =>
                value == null || value.isEmpty ? loc.translate("required") : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveExpense,
                child: Text(isEditing ? loc.translate("update") : loc.translate("addExpense")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
