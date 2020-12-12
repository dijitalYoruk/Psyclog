import 'package:psyclog_app/src/models/Author.dart';

class Topic {
  final String _id;
  final String _title;
  final String _description;
  final String _createdAt;
  final String _updatedAt;
  final Author _author;

  Topic(this._id, this._title, this._description, this._createdAt, this._updatedAt, this._author);

  get getID => _id;
  get getTitle => _title;
  get getDescription => _description;
  get getCreatedAt => _createdAt;
  get getUpdatedAt => _updatedAt;
  get getAuthor => _author;

  Topic.fromJson(Map<String, dynamic> json)
      : _id = json['_id'] as String,
        _title = json['title'] as String,
        _description = json['description'] as String,
        _createdAt = json['createdAt'] as String,
        _updatedAt = json['updatedAt'] as String,
        _author = Author.fromJson(json['author']);
}
