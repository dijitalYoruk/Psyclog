import 'dart:convert';
import 'package:http/http.dart';
import 'package:psyclog_app/service/WebServerService.dart';
import 'package:psyclog_app/service/util/ServiceConstants.dart';
import 'package:psyclog_app/service/util/ServiceErrorHandling.dart';
import 'package:psyclog_app/src/models/Topic.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as PATH;

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

  Future<bool> createTopic(String title, String description, String postContent, bool isAuthorAnonymous,
      {List<String> imagePaths}) async {
    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      // Waiting for Therapist List
      try {
        var headers = {'Authorization': 'Bearer $currentUserToken'};

        var request = http.MultipartRequest('POST', Uri.parse('$_serverAddress/$_currentAPI/forum/topic'));
        request.fields.addAll({
          'title': '$title',
          'description': '$description',
          'isAuthorAnonymous': '$isAuthorAnonymous',
          'postContent': '$postContent'
        });

        if (imagePaths != null) {
          for (String imagePath in imagePaths) {
            request.files.add(await http.MultipartFile.fromPath('postImages', imagePath,
                contentType: new MediaType('image', PATH.extension(imagePath))));
          }
        }
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();

        if (response.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
          return true;
        } else {
          return false;
        }
      } catch (e) {
        print(e);
        throw ServiceErrorHandling.serverNotRespondingError;
      }
    } else {
      print(ServiceErrorHandling.tokenEmptyError);
      return false;
    }
  }

  Future<bool> createPost(String topicID, String postContent, bool isAuthorAnonymous,
      {List<String> imagePaths, String quotation}) async {
    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      // Waiting for Therapist List
      try {
        var headers = {'Authorization': 'Bearer $currentUserToken'};
        var request;

        if (quotation != null) {
          request = http.MultipartRequest('POST', Uri.parse('$_serverAddress/$_currentAPI/forum/post'));
          request.fields.addAll({
            'topic': '$topicID',
            'isAuthorAnonymous': '$isAuthorAnonymous',
            'postContent': '$postContent',
            'quotation': '$quotation',
          });
        } else {
          request = http.MultipartRequest('POST', Uri.parse('$_serverAddress/$_currentAPI/forum/post'));
          request.fields.addAll({
            'topic': '$topicID',
            'isAuthorAnonymous': '$isAuthorAnonymous',
            'postContent': '$postContent',
          });
        }

        if (imagePaths != null) {
          for (String imagePath in imagePaths) {
            request.files.add(await http.MultipartFile.fromPath('postImages', imagePath,
                contentType: new MediaType('image', PATH.extension(imagePath))));
          }
        }

        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();

        print(await response.stream.bytesToString());

        if (response.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
          return true;
        } else {
          return false;
        }
      } catch (e) {
        print(e);
        throw ServiceErrorHandling.serverNotRespondingError;
      }
    } else {
      print(ServiceErrorHandling.tokenEmptyError);
      return false;
    }
  }

  Future<bool> deleteTopic(String topicID) async {
    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      // Waiting for Therapist List
      try {
        var request = http.Request('DELETE', Uri.parse('$_serverAddress/$_currentAPI/forum/topic'));
        request.body = jsonEncode({"topicId": topicID});
        request.headers
            .addAll(<String, String>{'Authorization': "Bearer " + currentUserToken, 'Content-Type': 'application/json'});

        final response = await request.send();

        if (response.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
          return true;
        } else {
          return false;
        }
      } catch (e) {
        print(e);
        throw ServiceErrorHandling.serverNotRespondingError;
      }
    } else {
      print(ServiceErrorHandling.tokenEmptyError);
      return false;
    }
  }

  Future<bool> deletePost(String postID) async {
    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      // Waiting for Therapist List
      try {
        var request = http.Request('DELETE', Uri.parse('$_serverAddress/$_currentAPI/forum/post'));
        request.body = jsonEncode({"postId": postID});
        request.headers
            .addAll(<String, String>{'Authorization': "Bearer " + currentUserToken, 'Content-Type': 'application/json'});

        final response = await request.send();

        if (response.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
          return true;
        } else {
          return false;
        }
      } catch (e) {
        print(e);
        throw ServiceErrorHandling.serverNotRespondingError;
      }
    } else {
      print(ServiceErrorHandling.tokenEmptyError);
      return false;
    }
  }

  Future<Response> retrievePostsByPage(int page, String topicID) async {
    // Waiting for User Token to be retrieved
    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      // Waiting for Therapist List
      try {
        var response = await http.get(
          '$_serverAddress/$_currentAPI/forum/topic/$topicID/posts?page=' + page.toString(),
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
