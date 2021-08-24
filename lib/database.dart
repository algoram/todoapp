import 'dart:io';
import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';
import 'package:todoapp/task.dart';

final _databaseFileName = 'tasks.db';

final tableName = "tasks";

_onCreate(Database db, int version) async {
  await db.execute(
      'CREATE TABLE $tableName (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, description TEXT);');
}

Future<Database> _getDatabase() async {
  final databasesPath = await getDatabasesPath();
  final path = join(databasesPath, _databaseFileName);

  try {
    await Directory(databasesPath).create(recursive: true);
  } catch (_) {}

  return await openDatabase(
    path,
    version: 1,
    onCreate: _onCreate,
  );
}

Future<List<Task>> getTasks() async {
  final db = await _getDatabase();

  final result =
      await db.query(tableName, columns: ["id", "name", "description"]);

  final List<Task> taskList = [];

  result.forEach((row) {
    taskList.add(
      Task(
        id: row["id"] as int,
        name: row["name"] as String,
        description: row["description"] as String?,
      ),
    );
  });

  db.close();

  return taskList;
}

Future<int> insertTask(String name, String? description) async {
  final db = await _getDatabase();

  var value;

  if (description != "") {
    value = {
      "name": name,
      "description": description,
    };
  } else {
    value = {
      "name": name,
    };
  }

  print(value);

  int id = await db.insert(tableName, value);

  db.close();

  return id;
}

Future<int> deleteTask(int id) async {
  final db = await _getDatabase();

  int rowsDeleted = await db.delete(tableName, where: 'id=?', whereArgs: [id]);

  db.close();

  return rowsDeleted;
}
