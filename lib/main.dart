import 'package:flutter/material.dart';
import 'pages/event/event_list_page.dart';
import 'pages/customer/customer_list_page.dart';
import '/pages/expense/expense_list_page.dart';
import 'pages/vehicle/maintenance_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Group Project App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Main Page")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EventListPage()));
              },
              child: const Text("Event Planner"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerListPage()));
              },
              child: const Text("Customer List"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ExpenseListPage()));
              },
              child: const Text("Expense Tracker"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MaintenanceListPage()));
              },
              child: const Text("Vehicle Maintenance"),
            ),
          ],
        ),
      ),
    );
  }
}
