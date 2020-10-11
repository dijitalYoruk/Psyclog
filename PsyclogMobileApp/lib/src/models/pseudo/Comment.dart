import 'package:flutter/foundation.dart';
import 'package:psyclog_app/src/models/User.dart';
import 'package:psyclog_app/src/models/pseudo/Like.dart';

class Comment {
  String text;
  final User user;
  final DateTime commentedAt;
  List<Like> likes;

  bool isLikedBy(User user) {
    return likes.any((like) => like.user.userFirstName == user.userFirstName);
  }

  void toggleLikeFor(User user) {
    if (isLikedBy(user)) {
      likes.removeWhere((like) => like.user.userFirstName == user.userFirstName);
    } else {
      likes.add(Like(user: user));
    }
  }

  Comment({
    @required this.text,
    @required this.user,
    @required this.commentedAt,
    @required this.likes,
  });
}
