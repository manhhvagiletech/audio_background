import 'package:audio_background/domain/entity/audio_model.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer' as developer;

class AudioProvider {
  final String tableAudio = "audio";
  final String columnId = "_id";
  final String columnTitle = "title";
  final String columnDescription = "description";
  final String columnFile = "file";
  late Database db;

  Future open(String path) async {
    try {
      db = await openDatabase(path, version: 1, onCreate: (db, version) async {
        await db.execute('''
        create table $tableAudio (
          $columnId integer primary key autoincrement,
          $columnTitle text not null,
          $columnDescription text,
          $columnFile text,
        ''');
      });
    } catch (error) {
      developer.log("openDBLog $error");
    }
  }

  Future<AudioModel> insertAudio(AudioModel audio) async {
    audio.id = await db.insert(tableAudio, audio.toMap());
    return audio;
  }

  Future<AudioModel?> getAudio(int id) async {
    final List<Map> maps = await db.query(
      tableAudio,
      columns: [
        columnId,
        columnTitle,
        columnDescription,
        columnFile,
      ],
      where: "$columnId = ?",
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return AudioModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    return await db.delete(
      tableAudio,
      where: "$columnId = ?",
      whereArgs: [id],
    );
  }

  Future<int> update(AudioModel audio) async {
    return await db.update(
      tableAudio,
      audio.toMap(),
      where: "$columnId = ?",
      whereArgs: [audio.id],
    );
  }
}
