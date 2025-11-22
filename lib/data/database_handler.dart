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

  Future<List<Map<String, dynamic>>> getRestaurants() async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query('restaurant');

    return result;
  }

  Future<Map<String, dynamic>?> getRestaurantById(int id) async {
    final db = await database;

    final List<Map<String, dynamic>> results = await db.query(
      'restaurant',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    //se não encontrar vai null
    return null;
  }

  Future<int> deleteRestaurant(int id) async {
    final db = await database;
    return await db.delete('restaurant', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateRestaurant(
    int id,
    String name,
    String address,
    String phone,
    double? latitude,
    double? longitude,
    String? img_url,
    int? stars,
  ) async {
    final db = await database;

    var restaurant = {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'img_url': img_url,
      'stars': stars,
    };

    return await db.update('restaurant', restaurant);
  }

  Future<int> updateRestaurantRating(int id, int rating) async {
    final db = await database;

    var updatedRaiting = {'stars': rating};

    return await db.update(
      'restaurant',
      where: 'id = ?',
      whereArgs: [id],
      updatedRaiting,
    );
  }
}
