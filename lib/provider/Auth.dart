// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../model/HttpException.dart';

class Auth extends ChangeNotifier {
  String? _token;
  DateTime? _expireDate;
  String? _userId;

  String get token => _token!;
  String get userId => _userId!;

  bool isAuth() {
    if (_expireDate == null) {
      return false;
    }
    if (_expireDate!.isAfter(DateTime.now()) &&
        _token != null &&
        _expireDate != null) {
      return true;
    }
    return false;
  }

  Future<void> _authenticateUser(
      String email, String password, String method) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$method?key=AIzaSyBEfeMHC-tmH7aUOo03ssy9aPq_UtAF00E');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        //print(responseData['error']['message'].runtimeType);
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expireDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      notifyListeners();
    } catch (e) {
      // ignore: use_rethrow_when_possible
      throw e;
    }
  }

  Future<void> signUp(email, password) async {
    return _authenticateUser(email, password, 'signUp');
  }

  Future<void> logIn(email, password) async {
    return _authenticateUser(email, password, 'signInWithPassword');
  }

  void logout() {
    _token = null;
    _userId = null;
    _expireDate = null;
    notifyListeners();
  }
}
