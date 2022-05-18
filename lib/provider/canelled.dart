import 'dart:convert';

import 'package:facilities_app/provider/facilities.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './booking.dart';
import './Auth.dart';

class CancelledProvider with ChangeNotifier {
  Auth? auth;
  var _cancelled = [];
  List get cancelled => _cancelled;
  List<Booking> _tempCancelled = [];
  List<Booking> get tempCancelled => _tempCancelled;

  void clearTemp() {
    _tempCancelled = [];
  }

  Future<List<dynamic>> getCancelled(String userId) async {
    final url = Uri.parse(
        'https://senior-project-booking-default-rtdb.firebaseio.com/cancelled/$userId.json?auth=${auth!.token}');
    final response = await http.get(url);
    final extractedDate = json.decode(response.body) as Map<String, dynamic>;
    _cancelled = [];
    extractedDate.forEach((key, value) {
      //Add the map of the data from db
      _cancelled.insertAll(0, [value]);
    });
    notifyListeners();
    return _cancelled;
  }

  void addTempCancelled(Facilities facility, String date, String time) {
    String newTime = time.replaceAll(':', ' ');
    int hour = int.parse(newTime.split(' ')[0]);
    int min = int.parse(newTime.split(' ')[1]);
    TimeOfDay finalTime = TimeOfDay(hour: hour, minute: min);
    Map<String, dynamic> isSelected = {date: false};
    final Booking booking = Booking(
        item: facility, date: date, time: finalTime, isSelected: isSelected);
    _tempCancelled.add(booking);
    print(_tempCancelled);
    notifyListeners();
  }

  Future addCancelled(Booking data, String userId) async {
    //Functionality of db
    final url = Uri.parse(
        'https://senior-project-booking-default-rtdb.firebaseio.com/cancelled/$userId.json?auth=${auth!.token}');
    await http.post(
      url,
      body: json.encode(
        {
          'id': data.item.id,
          'date': data.date,
          'time':
              '${data.time.hour}:${data.time.minute == 0 ? '00' : data.time.minute.toString()}',
        },
      ),
    );
    //functionality of the application
    // _cancelled.add(data);
    // notifyListeners();
  }
}
