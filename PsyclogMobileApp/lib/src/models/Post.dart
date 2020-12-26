import 'package:psyclog_app/src/models/Author.dart';

class Post {
  final List<String> _imageURLs;
  final String _postID;
  final String _content;
  final Author _author;
  final String _topicID;
  final bool _isAuthorAnonymous;
  final String _createdAt;
  final String _updatedAt;

  get getImageURLs => _imageURLs;
  get getPostID => _postID;
  get getContent => _content;
  get getAuthor => _author;
  get getTopicID => _topicID;
  get isAuthorAnonymous => _isAuthorAnonymous;
  get getCreatedAt => _createdAt;
  get getUpdatedAt => _updatedAt;

  Post.fromJson(Map<String, dynamic> json)
      : _imageURLs = List<String>.generate(json["images"].length, (index) => json["images"][index]),
        _postID = json["_id"] as String,
        _content = json["content"] as String,
        _author = Author.fromJson(json["author"]),
        _topicID = json["topic"] as String,
        _isAuthorAnonymous = json["isAuthorAnonymous"] as bool,
        _createdAt = json["createdAt"] as String,
        _updatedAt = json["updatedAt"] as String;
}
