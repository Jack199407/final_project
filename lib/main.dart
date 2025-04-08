import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'localization/app_localizations.dart';
import 'pages/event/event_list_page.dart';
import 'pages/customer/customer_list_page.dart';
import 'pages/expense/expense_list_page.dart';
import 'pages/vehicle/maintenance_list_page.dart';
import 'widgets/app_ui.dart';

/// Global locale controller for switching app language dynamically.
final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('en'));

/// Entry point of the application.
void main() {
  // Initialize SQLite for desktop platforms.
  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

/// Root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  /// Builds the MaterialApp with localization and theme support.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, _) {
        return MaterialApp(
          title: 'Group Project App',
          theme: AppUI.theme(),
          debugShowCheckedModeBanner: false,
          home: const MainPage(),
          locale: locale,
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale?.languageCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
        );
      },
    );
  }
}

/// Main dashboard page providing access to the different modules.
class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  /// Builds the UI for the main navigation page.
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('mainPage')),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (value) {
              if (value == 'en') {
                localeNotifier.value = const Locale('en');
              } else if (value == 'zh') {
                localeNotifier.value = const Locale('zh');
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'en', child: Text('English')),
              PopupMenuItem(value: 'zh', child: Text('中文')),
            ],
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppUI.buildButton(
                label: loc.translate('eventPlanner'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EventListPage()),
                  );
                },
              ),
              const SizedBox(height: 16),

              AppUI.buildButton(
                label: loc.translate('customerList'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CustomerListPage()),
                  );
                },
              ),
              const SizedBox(height: 16),

              AppUI.buildButton(
                label: loc.translate('expenseTracker'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ExpenseListPage()),
                  );
                },
              ),
              const SizedBox(height: 16),

              AppUI.buildButton(
                label: loc.translate('vehicleMaintenance'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MaintenanceListPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}








