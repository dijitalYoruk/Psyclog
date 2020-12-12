import 'package:psyclog_app/views/util/CapExtension.dart';

class Author {
  final String _id;
  final String _username;
  final String _firstName;
  final String _lastName;
  final String _profileImageURL;

  Author.fromJson(Map<String, dynamic> json)
      : _id = json['_id'] as String,
        _username = json['username'] as String,
        _firstName = json['name'] as String,
        _lastName = json['surname'] as String,
        _profileImageURL = json['profileImage'] as String;

  String get getAuthorId => _id;
  String get getUsername => _username;
  String get getFirstName => _firstName;
  String get getLastName => _lastName;
  String get getProfileImageURL => _profileImageURL != null ? _profileImageURL : null;

  String getFullName() {
    return _firstName.toString().inCaps + " " + _lastName.toString().inCaps;
  }
}
