import 'package:psyclog_app/views/util/CapExtension.dart';

class User {
  final String _id;
  final String _username;
  final String _firstName;
  final String _lastName;
  final String _email;
  final String _role;
  final String _createdAt;
  final String _updatedAt;
  final String _profileImageURL;
  final String _phoneNumber;

  get userFirstName => _firstName;
  get userSurname => _lastName;
  get userEmail => _email;
  get userRole => _role;
  get userCreationDate => _createdAt;
  get userUpdateDate => _updatedAt;
  get userID => _id;
  get userUsername => _username;
  get profileImageURL => _profileImageURL;
  get phoneNumber => _phoneNumber;

  User.fromJson(Map<String, dynamic> json)
      : _id = json['data']['user']['_id'] as String,
        _firstName = json['data']['user']['name'] as String,
        _lastName = json['data']['user']['surname'] as String,
        _email = json['data']['user']['email'] as String,
        _role = json['data']['user']['role'] as String,
        _profileImageURL = json['data']['user']['profileImage'] as String,
        _createdAt = json['data']['user']['createdAt'] as String,
        _updatedAt = json['data']['user']['updatedAt'] as String,
        _phoneNumber = json['data']['user']['phone'] as String,
        _username = json['data']['user']['username'] as String;

  User.fromJsonForList(Map<String, dynamic> json)
      : _id = json['_id'] as String,
        _firstName = json['name'] as String,
        _lastName = json['surname'] as String,
        _email = json['email'] as String,
        _role = json['role'] as String,
        _profileImageURL = json['profileImage'] as String,
        _createdAt = json['createdAt'] as String,
        _updatedAt = json['updatedAt'] as String,
        _phoneNumber = json['phone'] as String,
        _username = json['username'] as String;

  User.fromJsonForToken(Map<String, dynamic> json)
      : _id = json["data"]["profile"]['_id'] as String,
        _firstName = json["data"]["profile"]['name'] as String,
        _lastName = json["data"]["profile"]['surname'] as String,
        _email = json["data"]["profile"]['email'] as String,
        _role = json["data"]["profile"]['role'] as String,
        _profileImageURL = json['data']['profile']['profileImage'] as String,
        _createdAt = json["data"]["profile"]['createdAt'] as String,
        _updatedAt = json["data"]["profile"]['updatedAt'] as String,
        _phoneNumber = json['data']['profile']['phone'] as String,
        _username = json["data"]["profile"]['username'] as String;

  User.fromJsonForAppointment(Map<String, dynamic> json)
      : _id = json['_id'] as String,
        _firstName = json['name'] as String,
        _lastName = json['surname'] as String,
        _email = json['email'] as String,
        _username = json['username'] as String,
        _profileImageURL = json['profileImage'] as String,
        _phoneNumber = null,
        _role = null,
        _createdAt = null,
        _updatedAt = null;

  String getFullName() {
    return userFirstName.toString().inCaps + " " + userSurname.toString().inCaps;
  }
}
