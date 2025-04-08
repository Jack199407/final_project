import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// A singleton class that manages the app's SQLite database.
class DatabaseHelper {
  /// The single instance of [DatabaseHelper].
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  /// Private constructor for singleton pattern.
  DatabaseHelper._init();

  /// Provides access to the database, initializes it if not already.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_data.db');
    return _database!;
  }

  /// Initializes the database with tables for events, customers, expenses, and maintenance.
  ///
  /// [filePath] is the name of the database file.
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create the 'events' table.
        await db.execute('''
          CREATE TABLE events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            date TEXT NOT NULL,
            time TEXT NOT NULL,
            location TEXT NOT NULL,
            description TEXT NOT NULL
          );
        ''');

        // Create the 'customers' table.
        await db.execute('''
          CREATE TABLE customers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            first_name TEXT NOT NULL,
            last_name TEXT NOT NULL,
            address TEXT NOT NULL,
            birthday TEXT NOT NULL
          );
        ''');

        // Create the 'expenses' table.
        await db.execute('''
          CREATE TABLE expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            payment_method TEXT NOT NULL
          );
        ''');

        // Create the 'maintenance' table.
        await db.execute('''
          CREATE TABLE maintenance (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            vehicle_name TEXT NOT NULL,
            vehicle_type TEXT NOT NULL,
            service_type TEXT NOT NULL,
            service_date TEXT NOT NULL,
            mileage INTEGER NOT NULL,
            cost REAL NOT NULL
          );
        ''');
      },
    );
  }

  /// Inserts a row into the specified [table].
  ///
  /// Returns the ID of the inserted row.
  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(table, row);
  }

  /// Queries all rows from the specified [table].
  ///
  /// Returns a list of maps containing the rows.
  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await instance.database;
    return await db.query(table);
  }

  /// Updates a row in the specified [table] based on [id].
  ///
  /// Returns the number of rows affected.
  Future<int> update(String table, Map<String, dynamic> row, int id) async {
    final db = await instance.database;
    return await db.update(table, row, where: 'id = ?', whereArgs: [id]);
  }

  /// Deletes a row from the specified [table] based on [id].
  ///
  /// Returns the number of rows deleted.
  Future<int> delete(String table, int id) async {
    final db = await instance.database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}

