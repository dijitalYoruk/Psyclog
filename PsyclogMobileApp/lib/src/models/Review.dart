import 'package:psyclog_app/views/util/DateParser.dart';

class Review {
  final String _reviewID;
  final String _title;
  final String _content;
  final int _rating;
  final String _authorID;
  final String _psychologistID;
  final DateTime _createdAt;
  final DateTime _updatedAt;

  get getReviewID => _reviewID;
  get getTitle => _title;
  get getContent => _content;
  get getRating => _rating;
  get getAuthorID => _authorID;
  get getPsychologistID => _psychologistID;
  get getCreationDate => _createdAt;
  get getUpdateDate => _updatedAt;

  Review.fromJson(Map<String, dynamic> json)
      : _reviewID = json["_id"] as String,
        _title = json["title"] as String,
        _content = json["content"] as String,
        _rating = json["rating"] as int,
        _authorID = json["author"] as String,
        _psychologistID = json["psychologist"] as String,
        _createdAt = DateParser.jsonToDateTime(json["createdAt"]),
        _updatedAt = DateParser.jsonToDateTime(json["updatedAt"]);
}
