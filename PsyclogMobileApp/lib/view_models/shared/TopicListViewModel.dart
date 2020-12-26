import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:psyclog_app/service/ForumService.dart';
import 'package:psyclog_app/service/util/ServiceErrorHandling.dart';
import 'package:psyclog_app/src/models/Topic.dart';
import 'package:psyclog_app/views/util/ViewErrorHandling.dart';

class TopicListViewModel extends ChangeNotifier {
  ForumService _forumService;

  List<Topic> _allTopicList;

  int _currentPage;
  int _totalPage;

  TopicListViewModel() {
    _currentPage = 1;
    _totalPage = 1;
    _allTopicList = List<Topic>();
  }

  Future<void> initializeService(ForumService forumService) async {
    this._forumService = forumService;
    _allTopicList = List<Topic>();
    initializeModel();
  }

  Topic getTopicByElement(int index) {
    return _allTopicList[index];
  }

  int getCurrentListLength() {
    if (_allTopicList.isNotEmpty)
      return _allTopicList.length;
    else
      return 0;
  }

  Future<void> initializeModel() async {
    try {
      Response response = await _forumService.retrieveAllTenTopics();

      if (response != null) {
        var _decodedBody = jsonDecode(response.body);

        _totalPage = _decodedBody["data"]["topics"]["totalPages"];

        List<Topic> topics = List<Topic>.generate(_decodedBody["data"]["topics"]["docs"].length,
            (index) => Topic.fromJson(_decodedBody["data"]["topics"]["docs"][index]));

        _allTopicList.addAll(topics);

        notifyListeners();
      }
    } catch (error) {
      print(error);
      print(ServiceErrorHandling.serverNotRespondingError);
    }
  }

  Future<List<Topic>> getTopicsByPageFromService(int page) async {
    try {
      var response = await _forumService.getTopicsByPage(page);

      if (response != null) {
        List<Topic> topics = List<Topic>();

        var _decodedBody = jsonDecode(response.body);
        try {
          topics = List<Topic>.generate(_decodedBody["data"]["topics"]["docs"].length,
              (index) => Topic.fromJson(_decodedBody["data"]["topics"]["docs"][index]));
        } catch (e) {
          print(e);
        }
        return topics;
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

        List<Topic> _newTopics = await getTopicsByPageFromService(_currentPage);

        try {
          _allTopicList.addAll(_newTopics);
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

  Future<bool> deleteTopic(String topicID) async {
    bool isDeleted = await _forumService.deleteTopic(topicID);

    if (isDeleted) {
      _allTopicList.removeWhere((element) => element.getID == topicID);
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }
}
