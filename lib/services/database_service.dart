import 'package:sqflite/sqflite.dart';
import '../models/weight_record.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // If the database is null, initialize it
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    // Get the database path
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'weight_tracker.db');

    // Open or create the database
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Create the database table for weight records
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE weight_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        weight REAL
      )
    ''');
  }

  // Insert a new weight record into the database
  Future<void> insertWeight(WeightRecord record) async {
    final db = await database;
    await db.insert(
      'weight_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Replace if the record exists
    );
  }

  // Update an existing weight record by its id
  Future<void> updateWeight(WeightRecord record) async {
    final db = await database;
    await db.update(
      'weight_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // Delete a weight record by its id
  Future<void> deleteWeight(int id) async {
    final db = await database;
    await db.delete(
      'weight_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Fetch all weight records from the database
  Future<List<WeightRecord>> getAllWeights() async {
    final db = await database;

    // Query the database for all weight records
    final List<Map<String, dynamic>> result = await db.query('weight_records');

    // Convert the List<Map<String, dynamic>> to List<WeightRecord>
    return List.generate(result.length, (i) {
      return WeightRecord(
        id: result[i]['id'],
        date: result[i]['date'],
        weight: result[i]['weight'],
      );
    });
  }
}
