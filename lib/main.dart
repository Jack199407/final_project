import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'pages/event/event_list_page.dart';
import 'pages/customer/customer_list_page.dart';
import 'pages/expense/expense_list_page.dart';
import 'pages/vehicle/maintenance_list_page.dart';

void main() {

  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Event Planner
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EventListPage()),
                  );
                },
                child: const Text("Event Planner"),
              ),

              // 2. Customer List
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CustomerListPage()),
                  );
                },
                child: const Text("Customer List"),
              ),

              // 3. Expense Tracker
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ExpenseListPage()),
                  );
                },
                child: const Text("Expense Tracker"),
              ),

              // 4. Vehicle Maintenance
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MaintenanceListPage()),
                  );
                },
                child: const Text("Vehicle Maintenance"),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

