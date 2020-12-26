import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:psyclog_app/service/ForumService.dart';
import 'package:psyclog_app/service/util/ServiceErrorHandling.dart';
import 'package:psyclog_app/src/models/Post.dart';
import 'package:psyclog_app/src/models/Topic.dart';
import 'package:psyclog_app/src/models/User.dart';
import 'package:psyclog_app/views/util/ViewErrorHandling.dart';

class PostListViewModel extends ChangeNotifier {
  final Topic _currentTopic;

  ForumService _forumService;

  List<Post> _allPostList;

  int _currentPage;
  int _totalPage;

  PostListViewModel(this._currentTopic) {
    _currentPage = 1;
    _totalPage = 1;
    _allPostList = List<Post>();
    initializeService();
  }

  Future<void> initializeService() async {
    _forumService = await ForumService.getForumService();
    _allPostList = List<Post>();
    initializeModel();
  }

  String getCurrentUserID() {
    return (_forumService.currentUser as User).userID;
  }

  Post getPostByElement(int index) {
    return _allPostList[index];
  }

  int getCurrentListLength() {
    if (_allPostList.isNotEmpty)
      return _allPostList.length;
    else
      return 0;
  }

  Future<void> initializeModel() async {
    try {
      Response response = await _forumService.retrievePostsByPage(1, _currentTopic.getID);

      if (response != null) {
        var _decodedBody = jsonDecode(response.body);

        print(_decodedBody);

        _totalPage = _decodedBody["data"]["posts"]["totalPages"];

        List<Post> posts = List<Post>.generate(_decodedBody["data"]["posts"]["docs"].length,
            (index) => Post.fromJson(_decodedBody["data"]["posts"]["docs"][index]));

        _allPostList.addAll(posts);

        notifyListeners();
      }
    } catch (error) {
      print(error);
      print(ServiceErrorHandling.serverNotRespondingError);
    }
  }

  Future<List<Post>> getPostsByPageFromService(int page) async {
    try {
      var response = await _forumService.retrievePostsByPage(page, _currentTopic.getID);

      if (response != null) {
        List<Post> posts = List<Post>();

        var _decodedBody = jsonDecode(response.body);
        try {
          posts = List<Post>.generate(_decodedBody["data"]["posts"]["docs"].length,
              (index) => Post.fromJson(_decodedBody["data"]["posts"]["docs"][index]));
        } catch (e) {
          print(e);
        }
        return posts;
      }
    } catch (error) {
      print(error);
      print(ServiceErrorHandling.serverNotRespondingError);
    }
    return null;
  }

  Future<void> handleItemCreated(int index) async {
    if (_forumService != null) {
      var itemPosition = index + 1;
      var requestMoreData = itemPosition % 10 == 0 && itemPosition != 0;
      var pageToRequest = 1 + (itemPosition ~/ 10);

      if (requestMoreData && pageToRequest > _currentPage && _currentPage < _totalPage) {
        print('handleItemCreated | pageToRequest: $pageToRequest');
        _currentPage = pageToRequest;

        List<Post> _newPosts = await getPostsByPageFromService(_currentPage);

        try {
          _allPostList.addAll(_newPosts);
          notifyListeners();
        } catch (e) {
          _currentPage -= 1;
          print(e);
          print(ViewErrorHandling.pageIsNotLoaded);
        }
      }
    } else {
      initializeModel();
    }
  }

  Future<void> updatePosts() async {
    try {
      var response = await _forumService.retrievePostsByPage(_currentPage, _currentTopic.getID);

      if (response != null) {
        List<Post> posts = List<Post>();

        var _decodedBody = jsonDecode(response.body);
        try {
          posts = List<Post>.generate(_decodedBody["data"]["posts"]["docs"].length,
              (index) => Post.fromJson(_decodedBody["data"]["posts"]["docs"][index]));

          for (Post post in posts) {
            if (_allPostList.any((element) => element.getPostID == post.getPostID))
              continue;
            else {
              _allPostList.add(post);
            }
          }
          notifyListeners();
        } catch (e) {
          print(e);
        }
      }
    } catch (error) {
      print(error);
      print(ServiceErrorHandling.serverNotRespondingError);
    }
    return null;
  }

  Future<bool> deletePost(String postID) async {
    bool isDeleted = await _forumService.deletePost(postID);

    if (isDeleted) {
      _allPostList.removeWhere((element) => element.getPostID == postID);
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }
}
