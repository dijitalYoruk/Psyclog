import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:psyclog_app/service/ClientServerService.dart';
import 'package:psyclog_app/service/util/ServiceErrorHandling.dart';
import 'package:psyclog_app/src/models/Patient.dart';
import 'package:psyclog_app/src/models/Review.dart';
import 'package:psyclog_app/src/models/Therapist.dart';

class ClientReviewListViewModel extends ChangeNotifier {
  ClientServerService _serverService;
  Therapist _therapist;
  Patient _currentPatient;

  List<Review> _reviewList;

  int _currentPage;
  int _totalPage;

  ClientReviewListViewModel(Therapist therapist) {
    _currentPage = 1;
    _totalPage = 1;
    _therapist = therapist;
    print(_therapist.userID);
    _reviewList = List<Review>();
    initializeService();
  }

  Review getReviewByElement(int index) {
    return _reviewList[index];
  }

  int getCurrentListLength() {
    if (_reviewList.isNotEmpty)
      return _reviewList.length;
    else
      return 0;
  }

  String getCurrentUserID() {
    if (_currentPatient != null)
      return _currentPatient.userID;
    else
      return "";
  }

  initializeService() async {
    _serverService = await ClientServerService.getClientServerService();
    _currentPatient = await _serverService.currentPatient;

    try {
      List<Review> _initialReviews = await _serverService.retrieveReviews(_therapist.userID, 1);

      if (_initialReviews != null) {
        _reviewList = _initialReviews;

        notifyListeners();
      }
    } catch (error) {
      print(error);
      print(ServiceErrorHandling.serverNotRespondingError);
    }
    notifyListeners();
  }

  Future<bool> deleteReview(String reviewID) async {
    bool isDeleted = await _serverService.deleteReview(reviewID);

    if (isDeleted) {
      _reviewList.removeWhere((element) => element.getReviewID == reviewID);
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }
}
