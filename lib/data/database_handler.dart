import 'dart:nativewrappers/_internal/vm/lib/ffi_native_type_patch.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHandler {
  static final DatabaseHandler _instance = DatabaseHandler._internal();
  Database? _database;

  DatabaseHandler._internal();

  factory DatabaseHandler() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDb();
    return _database!;
  }

  Future<Database> initDb() async {
    String path = await getDatabasesPath();
    String databasePath = join(path, 'my_restaurants.db');

    return await openDatabase(
      databasePath,
      version: 1,
      onCreate: (Database db, int version) async {
        await createTables(db);
      },
    );
  }

  Future<void> createTables(Database db) async {
    const String createRestaurantTable = '''
      CREATE TABLE restaurant(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        phone TEXT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        img_url TEXT,
        stars INTEGER
      )
    ''';
    await db.execute(createRestaurantTable);
  }

  Future<int> createRestaurant(
    String name,
    String address,
    String phone,
    double? latitude,
    double? longitude,
    String? img_url,
  ) async {
    final db = await database;

    var restaurant = {
      'name': name,
      'address': address,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'img_url': img_url,
      'stars': 0,
    };

    return await db.insert('restaurant', restaurant);
  }
}
