import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/product.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // ValueNotifier agar perubahan Wishlist langsung reaktif di semua halaman
  final ValueNotifier<List<Product>> wishlistNotifier = ValueNotifier<List<Product>>([]);

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('shopping_hub.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // 1. Tabel Users untuk Autentikasi Login (Local Database)
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    // 2. Tabel Wishlist untuk Menyimpan Produk Wishlist (Local Database)
    await db.execute('''
      CREATE TABLE wishlist (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT,
        price REAL,
        discountPercentage REAL,
        rating REAL,
        stock INTEGER,
        brand TEXT,
        thumbnail TEXT,
        images TEXT
      )
    ''');
  }

  // ==========================================================================
  // OPERASI USER (LOGIN & REGISTER)
  // ==========================================================================

  Future<int> register(User user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> login(String username, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      columns: ['id', 'username', 'password'],
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<bool> checkUserExists(String username) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return maps.isNotEmpty;
  }

  // ==========================================================================
  // OPERASI WISHLIST (LOCAL DATABASE)
  // ==========================================================================

  Future<void> loadWishlist() async {
    final db = await instance.database;
    final maps = await db.query('wishlist', orderBy: 'id DESC');
    final list = maps.map((map) => Product.fromMap(map)).toList();
    wishlistNotifier.value = list;
  }

  Future<List<Product>> getWishlist() async {
    final db = await instance.database;
    final maps = await db.query('wishlist', orderBy: 'id DESC');
    final list = maps.map((map) => Product.fromMap(map)).toList();
    wishlistNotifier.value = list;
    return list;
  }

  Future<bool> isWishlist(int productId) async {
    final db = await instance.database;
    final maps = await db.query(
      'wishlist',
      where: 'id = ?',
      whereArgs: [productId],
    );
    return maps.isNotEmpty;
  }

  Future<bool> toggleWishlist(Product product) async {
    final exists = await isWishlist(product.id);
    if (exists) {
      await removeFromWishlist(product.id);
      return false; // Dihapus dari wishlist
    } else {
      await addToWishlist(product);
      return true; // Ditambahkan ke wishlist
    }
  }

  Future<int> addToWishlist(Product product) async {
    final db = await instance.database;
    final result = await db.insert(
      'wishlist',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await loadWishlist();
    return result;
  }

  Future<int> removeFromWishlist(int productId) async {
    final db = await instance.database;
    final result = await db.delete(
      'wishlist',
      where: 'id = ?',
      whereArgs: [productId],
    );
    await loadWishlist();
    return result;
  }
}
