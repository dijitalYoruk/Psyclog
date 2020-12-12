import 'dart:convert';

import 'package:http/http.dart';
import 'package:psyclog_app/service/WebServerService.dart';
import 'package:psyclog_app/service/util/ServiceConstants.dart';
import 'package:psyclog_app/service/util/ServiceErrorHandling.dart';
import 'package:psyclog_app/src/models/Topic.dart';
import 'package:http/http.dart' as http;

class ForumService extends WebServerService {
  static String _serverAddress;
  static ForumService _forumService;
  static String _currentAPI;

  static Future<ForumService> getForumService() async {
    // TODO USER Restrictions

    if (_serverAddress == null) {
      _serverAddress = ServiceConstants.serverAddress;
      //192.168.1.35 for Local IP
    }
    if (_currentAPI == null) {
      _currentAPI = ServiceConstants.currentAPI;
    }
    if (_forumService == null) {
      print("Empty Service for Forum Service. Creating a new one.");
      _forumService = new ForumService();
    }

    return _forumService;
  }

  Future<List<Topic>> retrieveRecentTenTopics() async {
    // Waiting for User Token to be retrieved
    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      // Waiting for Therapist List
      try {
        var response = await http.get(
          '$_serverAddress/$_currentAPI/forum/topic/newest',
          headers: {'Authorization': "Bearer " + currentUserToken},
        );

        if (response.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
          var _decodedBody = jsonDecode(response.body);

          List<Topic> topics = List<Topic>.generate(_decodedBody["data"]["newestTopics"].length,
              (index) => Topic.fromJson(_decodedBody["data"]["newestTopics"][index]));

          return topics;
        } else {
          throw ServiceErrorHandling.couldNotCreateRequestError;
        }
      } catch (e) {
        print(e);
        print(ServiceErrorHandling.serverNotRespondingError);
      }
    } else {
      print(ServiceErrorHandling.tokenEmptyError);
    }
    return null;
  }

  Future<List<Topic>> retrievePopularTenTopics() async {
    // Waiting for User Token to be retrieved
    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      // Waiting for Therapist List
      try {
        var response = await http.get(
          '$_serverAddress/$_currentAPI/forum/topic/popular',
          headers: {'Authorization': "Bearer " + currentUserToken},
        );

        if (response.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
          var _decodedBody = jsonDecode(response.body);

          List<Topic> topics = List<Topic>.generate(_decodedBody["data"]["popularTopics"].length,
              (index) => Topic.fromJson(_decodedBody["data"]["popularTopics"][index]));

          return topics;
        } else {
          throw ServiceErrorHandling.couldNotCreateRequestError;
        }
      } catch (e) {
        print(e);
        print(ServiceErrorHandling.serverNotRespondingError);
      }
    } else {
      print(ServiceErrorHandling.tokenEmptyError);
    }
    return null;
  }

  Future<Response> retrieveAllTenTopics() async {
    // Waiting for User Token to be retrieved
    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      // Waiting for Therapist List
      try {
        var response = await http.get(
          '$_serverAddress/$_currentAPI/forum/topic',
          headers: {'Authorization': "Bearer " + currentUserToken},
        );

        if (response.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
          return response;
        } else {
          throw ServiceErrorHandling.couldNotCreateRequestError;
        }
      } catch (e) {
        print(e);
        print(ServiceErrorHandling.serverNotRespondingError);
      }
    } else {
      print(ServiceErrorHandling.tokenEmptyError);
    }
    return null;
  }

  Future<Response> getTopicsByPage(int page) async {
    // Waiting for User Token to be retrieved
    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      // Waiting for Therapist List
      try {
        var response = await http.get(
          '$_serverAddress/$_currentAPI/forum/topic?page=' + page.toString(),
          headers: {'Authorization': "Bearer " + currentUserToken},
        );

        if (response.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
          return response;
        } else {
          throw ServiceErrorHandling.couldNotCreateRequestError;
        }
      } catch (e) {
        print(e);
        print(ServiceErrorHandling.serverNotRespondingError);
      }
    } else {
      print(ServiceErrorHandling.tokenEmptyError);
    }
    return null;
  }
}
