import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'barcode_model.dart';

class DBHelper {
  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'barcode.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE barcodes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            partName TEXT,
            qty INTEGER,
            uom TEXT,
            date TEXT,
            inspector TEXT,
            line TEXT
          )
        ''');
      },
    );
  }

  static Future<int> insertData(BarcodeData data) async {
    final db = await _initDB();
    return await db.insert('barcodes', data.toMap());
  }

  static Future<List<BarcodeData>> getDataBetweenDates(
      String from, String to) async {
    final db = await _initDB();
    final result = await db.query(
      'barcodes',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [from, to],
    );
    return result.map((e) => BarcodeData.fromMap(e)).toList();
  }

  static Future<List<BarcodeData>> getAllData() async {
    final db = await _initDB();
    final result = await db.query('barcodes');
    return result.map((e) => BarcodeData.fromMap(e)).toList();
  }
}
