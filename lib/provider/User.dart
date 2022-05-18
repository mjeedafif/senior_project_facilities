// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

//provider
import './Auth.dart';

// class User {
//   String fName;
//   String id;
//   String email;

//   User({
//     required this.fName,
//     required this.id,
//     required this.email,
//   });
// }

class UserProvider with ChangeNotifier {
  String _fName = '';
  late String _uId;
  late String _email;
  late Auth auth;

  String get fName => _fName;
  String get uId => _uId;
  String get email => _email;

  Future<void> addUser(fName, uId, email) async {
    var url = Uri.parse(
        'https://senior-project-booking-default-rtdb.firebaseio.com/users.json?auth=${auth.token}');
    try {
      await http.post(
        url,
        body: json.encode({
          'fName': fName,
          'id': uId,
          'email': email,
          'userId': auth.userId,
        }),
      );
    } catch (error) {
      // ignore: use_rethrow_when_possible
      throw error;
    }
  }

  Future<void> getUser(userId) async {
    var url = Uri.parse(
        'https://senior-project-booking-default-rtdb.firebaseio.com/users.json?auth=${auth.token}');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      extractedData.forEach((id, userData) {
        if (userData['userId'] == userId) {
          _email = userData['email'];
          _fName = userData['fName'];
          _uId = userData['id'];
        }
      });
      notifyListeners();
    } catch (error) {
      throw 'Sorry error occure';
    }
  }
}
