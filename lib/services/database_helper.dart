import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'hall_videos.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE hall_videos(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        videoUrl TEXT NOT NULL,
        hallNumber TEXT NOT NULL,
        floor TEXT NOT NULL,
        locationDescription TEXT,
        uploadedAt TEXT NOT NULL,
        status TEXT NOT NULL,
        isPublic INTEGER NOT NULL
      )
    ''');
  }

  Future<void> saveVideo(Map<String, dynamic> video) async {
    final db = await database;
    await db.insert(
      'hall_videos',
      video,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getVideos() async {
    final db = await database;
    return await db.query('hall_videos', where: 'status = ?', whereArgs: ['active']);
  }

  Future<void> deleteVideo(String id) async {
    final db = await database;
    await db.update(
      'hall_videos',
      {'status': 'deleted'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 