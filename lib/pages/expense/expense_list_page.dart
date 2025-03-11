import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import 'expense_form_page.dart';

class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({Key? key}) : super(key: key);

  @override
  _ExpenseListPageState createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  List<Map<String, dynamic>> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final expenses = await DatabaseHelper.instance.queryAll('expenses');
    setState(() {
      _expenses = expenses;
    });
  }

  Future<void> _deleteExpense(int id) async {
    await DatabaseHelper.instance.delete('expenses', id);
    _loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expenses")),
      body: ListView.builder(
        itemCount: _expenses.length,
        itemBuilder: (context, index) {
          final expense = _expenses[index];
          return ListTile(
            title: Text(expense['name']),
            subtitle: Text("Amount: \$${expense['amount']} - Date: ${expense['date']}"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExpenseFormPage(expense: expense),
                ),
              ).then((_) => _loadExpenses());
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteExpense(expense['id']),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExpenseFormPage()),
          ).then((_) => _loadExpenses());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
