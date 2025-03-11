import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _nameController.text = widget.expense!['name'];
      _categoryController.text = widget.expense!['category'];
      _amountController.text = widget.expense!['amount'].toString();
      _dateController.text = widget.expense!['date'];
      _paymentController.text = widget.expense!['payment_method'];
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? "Add Expense" : "Edit Expense"),
        actions: widget.expense != null
            ? [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteExpense(),
          ),
        ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Expense Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter an expense name";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: "Category"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a category";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter an amount";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: "Date"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a date";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _paymentController,
                decoration: const InputDecoration(labelText: "Payment Method"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a payment method";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveExpense,
                child: Text(widget.expense == null ? "Add Expense" : "Update Expense"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
