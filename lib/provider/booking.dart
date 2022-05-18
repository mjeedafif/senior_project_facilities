import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

//Provider
import './Auth.dart';
import './facilities.dart';

class Booking {
  Facilities item;
  String date;
  TimeOfDay time;
  Map<String, dynamic> isSelected;
  Booking({
    required this.item,
    required this.date,
    required this.time,
    required this.isSelected,
  });
}

class BookingProvider with ChangeNotifier {
  List<Booking> _avaliableTimes = [];
  Map<String, dynamic> _sharedBookedTime = {};
  Map<String, dynamic> _bookedTime = {};

  Map<String, dynamic> bookedTime() {
    return _bookedTime;
  }

  String newTime(String time, String type) {
    final editedTime = time.replaceAll(':', ' ');
    if (type == 'hour') {
      return editedTime.split(' ')[0];
    } else {
      return editedTime.split(' ')[1];
    }
  }

  Future<void> getSharedBookedTime(BuildContext context) async {
    var url = Uri.parse(
        'https://senior-project-booking-default-rtdb.firebaseio.com/booked.json?auth=${auth.token}');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      _sharedBookedTime = {};
      extractedData.forEach((key, value) {
        final mapOfEachBookingUser = value as Map<String, dynamic>;
        Facilities? facility;
        mapOfEachBookingUser.forEach((key, mapOfData) {
          Map<String, dynamic> mapOfItem = mapOfData;
          mapOfItem.forEach((key, valueOfItems) {
            if (key == 'item') {
              int id = valueOfItems['id'];
              String name = valueOfItems['name'];
              String first = valueOfItems['first'];
              String last = valueOfItems['last'];
              int duration = valueOfItems['duration'];
              String belong = valueOfItems['belong'];
              String fac = valueOfItems['fac'];
              int cap = valueOfItems['cap'];
              String image = valueOfItems['image'];
              double voteAvg = valueOfItems['vote_avg'];
              int voteCount = valueOfItems['vote_count'];
              facility = Facilities(
                id,
                name,
                first,
                last,
                duration,
                belong,
                cap,
                fac,
                image,
                voteAvg,
                voteCount,
              );
            }
          });
          final hour = int.parse(newTime(mapOfData['time'], 'hour'));
          final min = int.parse(newTime(mapOfData['time'], 'min'));

          final booking = Booking(
            date: mapOfData['date'],
            isSelected: mapOfData['isSelected'],
            time: TimeOfDay(hour: hour, minute: min),
            item: facility!,
          );
          if (_sharedBookedTime.containsKey(mapOfData['date'])) {
            List<Booking> prevBooked = _sharedBookedTime[mapOfData['date']];
            prevBooked.add(booking);
            _sharedBookedTime.update(mapOfData['date'], (value) => prevBooked);
          } else {
            List<Booking> items = [booking];
            _sharedBookedTime.putIfAbsent(mapOfData['date'], () => items);
          }
        });
      });
    } catch (error) {
      // ignore: use_rethrow_when_possible
      throw error;
    }
    notifyListeners();
  }

  Future<void> deleteFromDb(Booking data, String userId) async {
    var url = Uri.parse(
        'https://senior-project-booking-default-rtdb.firebaseio.com/booked/$userId.json?auth=${auth.token}');
    final response = await http.get(url);
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    var keyDeleted = '';
    extractedData.forEach((key, value) {
      final mapOfData = value as Map<String, dynamic>;
      //Data to be check with
      final checkDate = data.date;
      final checkTime = data.time;
      final checkId = data.item.id;
      //Create time to check with booking time
      final creationTime = mapOfData['time'].replaceAll(':', ' ');
      final hour = int.parse(creationTime.split(' ')[0]);
      final min = int.parse(creationTime.split(' ')[1]);
      final time = TimeOfDay(hour: hour, minute: min);

      //Make the check
      if (checkDate == mapOfData['date'] &&
          checkTime == time &&
          checkId == mapOfData['item']['id']) {
        //Save the key to delete it from database
        keyDeleted = key;
      }
    });

    //Now you have the key delete the item from database
    url = Uri.parse(
        'https://senior-project-booking-default-rtdb.firebaseio.com/booked/$userId/$keyDeleted.json?auth=${auth.token}');
    final newResponse = await http.delete(url);
    print(newResponse.statusCode);
    //If it success say alhamdullah
  }

  void deleteReservation(Booking data) {
    final keyDate = data.date;
    if (_sharedBookedTime[keyDate] == null || _bookedTime[keyDate] == null) {
      return;
    }
    //Save the previous list of each maps
    List<Booking> _tempShared = _sharedBookedTime[keyDate];
    List<Booking> _tempBooked = _bookedTime[keyDate];

    //Delete the item from the temp to assign it again
    _tempShared.removeWhere((element) =>
        element.item.id == data.item.id && element.time == data.time);
    _tempBooked.removeWhere((element) =>
        element.item.id == data.item.id && element.time == data.time);

    //Update the shared and booked and call notify
    _bookedTime.update(keyDate, (value) => _tempBooked);
    _sharedBookedTime.update(keyDate, (value) => _tempShared);
    notifyListeners();
  }

  Future<void> getBookedTime(String userId) async {
    //List<Booking> prevList = [];
    var url = Uri.parse(
        'https://senior-project-booking-default-rtdb.firebaseio.com/booked/$userId.json?auth=${auth.token}');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      _bookedTime = {};
      extractedData.forEach(
        (key, mapOfBookingData) {
          //The map of the booking after the id generated
          final Map<String, dynamic> dataOfBookeing = mapOfBookingData;
          //print('$mapOfBookingData this is map of booking data');
          //Create the facility object for item
          Facilities? facilityInserted;
          //forEach booking for each person
          dataOfBookeing.forEach(
            (key, valueOfBookingData) {
              if (key == 'item') {
                int id = valueOfBookingData['id'];
                String name = valueOfBookingData['name'];
                String first = valueOfBookingData['first'];
                String last = valueOfBookingData['last'];
                int duration = valueOfBookingData['duration'];
                String belong = valueOfBookingData['belong'];
                String fac = valueOfBookingData['fac'];
                int cap = valueOfBookingData['cap'];
                String image = valueOfBookingData['image'];
                double voteAvg = valueOfBookingData['vote_avg'];
                int voteCount = valueOfBookingData['vote_count'];
                //Create the object
                facilityInserted = Facilities(
                  id,
                  name,
                  first,
                  last,
                  duration,
                  belong,
                  cap,
                  fac,
                  image,
                  voteAvg,
                  voteCount,
                );
              }
            },
          );
          final hour = int.parse(newTime(mapOfBookingData['time'], 'hour'));
          final min = int.parse(newTime(mapOfBookingData['time'], 'min'));
          final booking = Booking(
            date: mapOfBookingData['date'],
            time: TimeOfDay(hour: hour, minute: min),
            item: facilityInserted!,
            isSelected: mapOfBookingData['isSelected'],
          );
          //prevList = [];
          if (_bookedTime.containsKey(mapOfBookingData['date'])) {
            List<Booking> prevList = _bookedTime[mapOfBookingData['date']];

            prevList.add(booking);
            _bookedTime.update(mapOfBookingData['date'], (value) => prevList);
          } else {
            List<Booking> items = [booking];
            _sharedBookedTime.putIfAbsent(
                mapOfBookingData['date'], () => items);
            _bookedTime.putIfAbsent(mapOfBookingData['date'], () => items);
          }
          //if (key == 'date') {
          //Now insert the data in side _bookedTime and make the key the date
          //_bookedTime.putIfAbsent(mapOfBookingData['date'], () => booking);
          //
        },
      );
    } catch (err) {
      // ignore: use_rethrow_when_possible
      throw err;
    }
    notifyListeners();
  }

  void addBookedTime(String userId, String date, Booking dataReceive) async {
    var url = Uri.parse(
        'https://senior-project-booking-default-rtdb.firebaseio.com/booked/$userId.json?auth=${auth.token}');
    String editedTime =
        '${dataReceive.time.hour}:${dataReceive.time.minute}${dataReceive.time.minute == 0 ? '0' : ''}';
    try {
      await http.post(
        url,
        body: json.encode(
          {
            //date.toString(): {
            'item': {
              'id': dataReceive.item.id,
              'name': dataReceive.item.name,
              'first': dataReceive.item.first,
              'last': dataReceive.item.last,
              'duration': dataReceive.item.duration,
              'belong': dataReceive.item.belong,
              'cap': dataReceive.item.cap,
              'fac': dataReceive.item.fac,
              'image': dataReceive.item.imageUrl,
              'vote_avg': dataReceive.item.voteAvg,
              'vote_count': dataReceive.item.voteCoun,
            },
            'date': dataReceive.date.toString(),
            'time': editedTime,
            'isSelected': dataReceive.isSelected,
            //},
          },
        ),
      );
    } catch (error) {
      // ignore: use_rethrow_when_possible
      throw error;
    }
    notifyListeners();
  }

  //Get this tow data from db
  TimeOfDay _firstTime = const TimeOfDay(hour: 17, minute: 0);
  TimeOfDay _lastTime = const TimeOfDay(hour: 20, minute: 0);
  late Auth auth;

  //Functions to get the weekend date
  DateTime weekdayOf(DateTime time, int weekday) =>
      time.add(Duration(days: weekday - time.weekday));
  DateTime fridayOf(DateTime time) => weekdayOf(time, 5);
  DateTime saturdayOf(DateTime time) => weekdayOf(time, 6);

  List<Booking> avaliableTime(String date, Facilities item) {
    //Check the weekend
    String check = date.replaceAll('-', ' ');
    int day = int.parse(check.split(' ')[2]);
    int month = int.parse(check.split(' ')[1]);
    int year = int.parse(check.split(' ')[0]);
    //Save the date of the reservation
    DateTime checkFriday = DateTime(year, month, day);
    DateTime checkSaturday = DateTime(year, month, day);
    //Get the weekend date
    final DateTime friday = fridayOf(checkFriday);
    final DateTime saturday = saturdayOf(checkSaturday);
    if (day == friday.day || day == saturday.day) {
      _avaliableTimes = [];
      notifyListeners();
      return _avaliableTimes;
    }

    ///Get how many time will add times avaliable
    ///get the first and last time
    var hourFirst = item.first.substring(0, 2);
    var minFirst = item.first.substring(3);
    var hourLast = item.last.substring(0, 2);
    var minLast = item.last.substring(3);
    _firstTime =
        TimeOfDay(hour: int.parse(hourFirst), minute: int.parse(minFirst));
    _lastTime =
        TimeOfDay(hour: int.parse(hourLast), minute: int.parse(minLast));
    var loopTime = _lastTime.hour - _firstTime.hour;
    _avaliableTimes = [];
    for (int i = 0; i <= loopTime; i += item.duration) {
      final nextTime = Booking(
        item: item,
        date: date.split(' ')[0],
        time: TimeOfDay(hour: (_firstTime.hour + i), minute: _firstTime.minute),
        isSelected: {date.split(' ')[0]: false},
      );
      _avaliableTimes.add(nextTime);
    }
    notifyListeners();
    return _avaliableTimes;
  }

  bool bookedFacilities(TimeOfDay time, String date, Facilities facility) {
    var listOfBooked = _sharedBookedTime[date.split(' ')[0]];
    // ignore: unnecessary_null_comparison
    if (listOfBooked == null || facility == null) {
      return false;
    }
    var isBooked = listOfBooked.any((element) =>
        //print('$time this is inside the check');
        element.time == time &&
        element.item.id == facility.id &&
        element.date.split(' ')[0] == date.split(' ')[0]);
    //notifyListeners();
    return isBooked;
  }
}
