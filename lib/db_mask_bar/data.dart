import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'db_mask_bar_entity.dart';

class MaskBarDatabase {
  static final MaskBarDatabase _instance = MaskBarDatabase._internal();
  static Database? _database;

  factory MaskBarDatabase() => _instance;

  MaskBarDatabase._internal();

  static const String _databaseName = 'mask_bar.db';

  static const int _databaseVersion = 1;

  static const String tableMaskBar = 'mask_bar';

  static const String tableEditHistory = 'edit_history';

  Future<MaskBarDatabase> init() async {
    await database;
    return this;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {

    await db.execute('''
      CREATE TABLE mask_bar (
        id TEXT PRIMARY KEY,
        color TEXT NOT NULL,
        opacity INTEGER NOT NULL,
        style TEXT NOT NULL,
        create_time INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableEditHistory (
        id TEXT PRIMARY KEY,
        file_name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        thumbnail TEXT NOT NULL,
        function_type TEXT NOT NULL,
        create_time INTEGER NOT NULL,
        file_size INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_function_type_create_time
      ON $tableEditHistory(function_type, create_time DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_create_time
      ON $tableEditHistory(create_time DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_file_name
      ON $tableEditHistory(file_name)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {

  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  Future<int> insertHistory(EditHistoryEntity history) async {
    final db = await database;
    return await db.insert(
      tableEditHistory,
      history.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertHistoryBatch(List<EditHistoryEntity> historyList) async {
    final db = await database;
    final batch = db.batch();
    for (var history in historyList) {
      batch.insert(
        tableEditHistory,
        history.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<EditHistoryEntity?> getHistoryById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableEditHistory,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return EditHistoryEntity.fromMap(maps.first);
  }

  Future<List<EditHistoryEntity>> getHistoryList({
    String? functionType,
    int? startTime,
    int? endTime,
    String orderBy = 'time_desc',
    String? searchKeyword,
  }) async {
    final db = await database;
    final where = _buildWhereClause(
      functionType,
      startTime,
      endTime,
      searchKeyword,
    );

    final maps = await db.query(
      tableEditHistory,
      where: where['clause'],
      whereArgs: where['args'],
      orderBy: _buildOrderBy(orderBy),
    );

    return maps.map((map) => EditHistoryEntity.fromMap(map)).toList();
  }

  Map<String, dynamic> _buildWhereClause(
    String? functionType,
    int? startTime,
    int? endTime,
    String? searchKeyword,
  ) {
    final conditions = <String>[];
    final args = <dynamic>[];

    if (functionType != null &&
        functionType != 'all' &&
        functionType.isNotEmpty) {
      conditions.add('function_type = ?');
      args.add(functionType);
    }

    if (startTime != null) {
      conditions.add('create_time >= ?');
      args.add(startTime);
    }

    if (endTime != null) {
      conditions.add('create_time <= ?');
      args.add(endTime);
    }

    if (searchKeyword != null && searchKeyword.isNotEmpty) {
      conditions.add('file_name LIKE ?');
      args.add('%$searchKeyword%');
    }

    return {
      'clause': conditions.isEmpty ? null : conditions.join(' AND '),
      'args': args.isEmpty ? null : args,
    };
  }

  String _buildOrderBy(String orderBy) {
    switch (orderBy) {
      case 'time_asc':
        return 'create_time ASC';
      case 'name':
        return 'file_name ASC';
      default:
        return 'create_time DESC';
    }
  }

  Future<int> updateHistory(EditHistoryEntity history) async {
    final db = await database;
    return await db.update(
      tableEditHistory,
      history.toMap(),
      where: 'id = ?',
      whereArgs: [history.id],
    );
  }

  Future<int> deleteHistoryById(String id) async {
    final db = await database;
    return await db.delete(tableEditHistory, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteHistoryByIds(List<String> ids) async {
    if (ids.isEmpty) return 0;

    final db = await database;
    final placeholders = List.filled(ids.length, '?').join(',');
    return await db.delete(
      tableEditHistory,
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }

  Future<int> clearAllHistory() async {
    final db = await database;
    return await db.delete(tableEditHistory);
  }

  Future<int> getHistoryCount({
    String? functionType,
    int? startTime,
    int? endTime,
  }) async {
    final db = await database;
    final where = _buildWhereClause(functionType, startTime, endTime, null);

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableEditHistory${where['clause'] != null ? ' WHERE ${where['clause']}' : ''}',
      where['args'],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<bool> isFileNameExists(String fileName) async {
    final db = await database;
    final result = await db.query(
      tableEditHistory,
      where: 'file_name = ?',
      whereArgs: [fileName],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<int> getNextUnnamedNumber() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT file_name FROM $tableEditHistory WHERE file_name LIKE 'Untitled%' ORDER BY create_time DESC LIMIT 1",
    );

    if (result.isEmpty) return 1;

    final lastName = result.first['file_name'] as String;
    final match = RegExp(r'\((\d+)\)').firstMatch(lastName);
    if (match != null) {
      final num = int.tryParse(match.group(1) ?? '1') ?? 1;
      return num + 1;
    }

    return 1;
  }

  Future<int> insertMaskBar(MaskBarEntity maskBar) async {
    final db = await database;
    return await db.insert(
      tableMaskBar,
      maskBar.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertMaskBarBatch(List<MaskBarEntity> maskBarList) async {
    final db = await database;
    final batch = db.batch();
    for (var maskBar in maskBarList) {
      batch.insert(
        tableMaskBar,
        maskBar.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<MaskBarEntity?> getMaskBarById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableMaskBar,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return MaskBarEntity.fromMap(maps.first);
  }

  Future<List<MaskBarEntity>> getMaskBarList({
    String? style,
    String orderBy = 'time_desc',
  }) async {
    final db = await database;
    final where = style != null && style.isNotEmpty ? 'style = ?' : null;
    final whereArgs = style != null && style.isNotEmpty ? [style] : null;

    String orderByClause;
    switch (orderBy) {
      case 'time_asc':
        orderByClause = 'create_time ASC';
        break;
      default:
        orderByClause = 'create_time DESC';
    }

    final maps = await db.query(
      tableMaskBar,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderByClause,
    );

    return maps.map((map) => MaskBarEntity.fromMap(map)).toList();
  }

  Future<int> updateMaskBar(MaskBarEntity maskBar) async {
    final db = await database;
    return await db.update(
      tableMaskBar,
      maskBar.toMap(),
      where: 'id = ?',
      whereArgs: [maskBar.id],
    );
  }

  Future<int> deleteMaskBarById(String id) async {
    final db = await database;
    return await db.delete(tableMaskBar, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteMaskBarByIds(List<String> ids) async {
    if (ids.isEmpty) return 0;

    final db = await database;
    final placeholders = List.filled(ids.length, '?').join(',');
    return await db.delete(
      tableMaskBar,
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }

  Future<int> clearAllMaskBar() async {
    final db = await database;
    return await db.delete(tableMaskBar);
  }

  Future<int> getMaskBarCount({String? style}) async {
    final db = await database;
    final where = style != null && style.isNotEmpty ? 'style = ?' : null;
    final whereArgs = style != null && style.isNotEmpty ? [style] : null;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableMaskBar${where != null ? ' WHERE $where' : ''}',
      whereArgs,
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }
}