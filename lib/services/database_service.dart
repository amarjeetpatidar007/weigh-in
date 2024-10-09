import 'package:path/path.dart';
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
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'weight_tracker.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE weight_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        weight REAL,
        missed INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE weight_records ADD COLUMN missed INTEGER NOT NULL DEFAULT 0');
    }
  }

  Future<bool> recordExistsForToday(String date) async {
    final db = await database;
    final result = await db.query(
      'weight_records',
      where: 'date = ?',
      whereArgs: [date],
    );
    return result.isNotEmpty;
  }

  Future<void> insertWeight(WeightRecord record) async {
    final db = await database;

    try {
      await db.insert(
        'weight_records',
        record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error inserting weight: $e');
      // If the insert fails, try updating instead
      await db.update(
        'weight_records',
        record.toMap(),
        where: 'date = ?',
        whereArgs: [record.date],
      );
    }
  }

  Future<void> updateWeight(WeightRecord record) async {
    final db = await database;
    await db.update(
      'weight_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteWeight(int id) async {
    final db = await database;
    await db.delete(
      'weight_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<WeightRecord>> getAllWeights() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'weight_records',
      orderBy: 'date DESC',  // Order by date, most recent first
    );

    return List.generate(result.length, (i) {
      return WeightRecord(
        id: result[i]['id'],
        date: result[i]['date'],
        weight: result[i]['weight'],
        missed: result[i]['missed'] == 1,
      );
    });
  }

  Future<WeightRecord?> getWeightRecordByDate(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'weight_records',
      where: 'date = ?',
      whereArgs: [date],
    );

    if (result.isEmpty) {
      return null;
    }

    return WeightRecord.fromMap(result.first);
  }
}