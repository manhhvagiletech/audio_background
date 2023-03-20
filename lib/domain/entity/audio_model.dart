class AudioModel {
  int? id;
  String? title;
  String? description;
  String? file;

  AudioModel({this.id, this.title, this.description, this.file});

  AudioModel.fromMap(Map map) {
    id = map["_id"] as int;
    title = map["title"] as String?;
    description = map["description"] as String?;
    file = map["file"] as String?;
  }

  Map<String, Object?> toMap() {
    final map = <String, Object?>{
      "title": title,
      "description": description,
      "file": file,
    };
    if (id != null) {
      map["_id"] = id;
    }
    return map;
  }
}
