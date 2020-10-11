import 'package:flutter/foundation.dart';
import 'package:psyclog_app/src/models/User.dart';
import 'package:psyclog_app/src/models/pseudo/Comment.dart';
import 'package:psyclog_app/src/models/pseudo/Like.dart';
import 'package:timeago/timeago.dart' as timeago;

class Post {
  List<String> imageUrls;
  final User user;
  final DateTime postedAt;

  List<Like> likes;
  List<Comment> comments;
  String location;

  String timeAgo() {
    final now = DateTime.now();
    return timeago.format(now.subtract(now.difference(postedAt)));
  }

  bool isLikedBy(User currentUser) {
    return likes.any((like) => like.user.userFirstName == currentUser.userFirstName);
  }

  void addLikedBy(User currentUser) {
    if (!isLikedBy(currentUser)) {
      likes.add(Like(user: currentUser));
    }
  }

  void toggleLikeFor(User currentUser) {
    if (isLikedBy(currentUser)) {
      likes.removeWhere((like) => like.user.userFirstName == currentUser.userFirstName);
    } else {
      addLikedBy(currentUser);
    }
  }

  Post({
    @required this.imageUrls,
    @required this.user,
    @required this.postedAt,
    @required this.likes,
    @required this.comments,
    this.location,
  });
}
