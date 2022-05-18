import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
//Provider
import './Auth.dart';

//Translation
import '../translations/locale_keys.g.dart';

//Model
import '../model/dropItems.dart';

class Facilities {
  int id;
  String name;
  String first;
  String last;
  int duration;
  String belong;
  String fac;
  int cap;
  String imageUrl;
  double voteAvg;
  int voteCoun;

  Facilities(
    this.id,
    this.name,
    this.first,
    this.last,
    this.duration,
    this.belong,
    this.cap,
    this.fac,
    this.imageUrl,
    this.voteAvg,
    this.voteCoun,
  );
}

class FacilitiesProvider with ChangeNotifier {
  List<Facilities> _facilities = [];
  final List<DropItems> _categories = [
    DropItems(LocaleKeys.indoor.tr(), false),
    DropItems(LocaleKeys.outdoor.tr(), false)
  ];
  final List<DropItems> _capacity = [
    DropItems(LocaleKeys.MoreThan20.tr(), false),
    DropItems(LocaleKeys.between10To20.tr(), false),
    DropItems(LocaleKeys.lessThan10.tr(), false),
  ];
  final List<DropItems> _faculty = [
    DropItems(LocaleKeys.fcit.tr(), false),
    DropItems(LocaleKeys.deanshipOfStudent.tr(), false),
    DropItems(LocaleKeys.engineering.tr(), false),
    DropItems(LocaleKeys.medical.tr(), false),
    DropItems(LocaleKeys.tourism.tr(), false),
  ];
  List<DropItems> _totalFilter = [];

  List<DropItems> get categories => _categories;
  List<DropItems> get capacity => _capacity;
  List<DropItems> get faculty => _faculty;

  ///The time for test
  ///get it from data base from each facilities
  final TimeOfDay _firstTime = const TimeOfDay(hour: 17, minute: 00);
  final TimeOfDay _lastTime = const TimeOfDay(hour: 20, minute: 00);
  late Auth auth;

  List<Facilities> get facilities => _facilities;

  Facilities getFacility(int id) {
    return _facilities.firstWhere((element) => element.id == id);
  }

  Future<void> getFacilitiesFromDB() async {
    var url = Uri.parse(
        'https://senior-project-booking-default-rtdb.firebaseio.com/facilities.json?auth=${auth.token}');
    try {
      final response = await http.get(url);
      //print('${json.decode(response.body)} this is the response');
      final extractedData = json.decode(response.body);
      //print('$extractedData this is extracted');
      // extractedData.forEach(
      //     (value) => value.forEach((key, value) => print('$key: $value')));

      //Loop to get the data from db
      _facilities = [];
      var length = extractedData.length;
      for (int i = 0; i < length; i++) {
        String belong = extractedData[i]['belong'];
        int cap = extractedData[i]['cap'];
        int duration = extractedData[i]['duration'];
        String fac = extractedData[i]['fac'];
        String first = extractedData[i]['first'];
        int id = extractedData[i]['id'];
        String img = extractedData[i]['img_url'];
        String last = extractedData[i]['last'];
        String name = extractedData[i]['name'];
        double voteAvg = extractedData[i]['vote_avg'];
        int voteCount = extractedData[i]['vote_coun'];
        // print(
        //     '$belong $cap $duration $fac $first $id $img $last $name $voteAvg $voteCount');
        //Make the object of the data
        Facilities data = Facilities(id, name, first, last, duration, belong,
            cap, fac, img, voteAvg, voteCount);
        _facilities.add(data);
      }
      notifyListeners();
    } catch (error) {
      // ignore: use_rethrow_when_possible
      throw error;
    }
  }

  int getDuration(String belong) {
    int duration = 0;
    duration =
        _facilities.firstWhere((element) => element.belong == belong).duration;
    return duration;
  }

  String getBelongArabic(String belong) {
    String englishBelong = '';
    //print(belong);
    switch (belong) {
      case 'قاعة اجتماعات':
        //print('meeting');
        englishBelong = 'meeting rooms';
        break;
      case 'قاعات':
        //print('labs');
        englishBelong = 'labs';
        break;
      case 'مسارح':
        //print('theater');
        englishBelong = 'theater';
        break;

      case 'ملاعب':
        //print('sports');
        englishBelong = 'sports';
    }
    return englishBelong;
  }

  Future<List<Facilities>> getFacilities(
      BuildContext context, String belong) async {
    List<Facilities> _tempFacilities = [];
    //First filter from python
    // List<dynamic> ids = await filterFacilities();

    // ids.forEach((id) {
    //   Facilities facilityToAdd =
    //       _facilities.firstWhere((element) => element.id == id);
    //   _tempFacilities.add(facilityToAdd);
    //   // print(facilityToAdd.name);
    // });

    //To match with the database
    String lowerBelong = belong.toLowerCase();

    //Second filter category
    if (context.locale.toString() == 'ar') {
      String check = getBelongArabic(belong);
      //print(check);
      _tempFacilities =
          _facilities.where((element) => element.belong == check).toList();
    } else {
      _tempFacilities = _facilities
          .where((element) => element.belong == lowerBelong)
          .toList();
    }

    //Third filter the user filter
    _totalFilter = getTotalFilter();
    if (_totalFilter.isNotEmpty) {
      _faculty.forEach((element) {
        if (!element.isSelected) {
          //Check which filter is this
          var title = element.title.toLowerCase();
          //Remove the facility
          _tempFacilities.removeWhere((element) {
            var lowerFac = element.fac.toLowerCase();
            return lowerFac == title;
          });
        }
      });
      //When there is filter that will calls
      _capacity.forEach((element) {
        if (!element.isSelected) {
          //Check which filter is this
          var title = element.title.toLowerCase();

          //Remove the cap
          _tempFacilities.removeWhere((element) {
            print(element.cap);
            var size = getSize(title);
            //print(size);
            return false;
            // if (size == 21) {
            //   return element.cap < 20;
            // } else if (size == 11) {
            //   return element.cap > 20 && element.cap < 10;
            // } else {
            //   return element.cap > 10;
            // }
          });
        }
      });
      _categories.forEach((element) {
        if (!element.isSelected) {
          //Check which filter is this
          var title = element.title.toLowerCase();

          //Remove the cap
          _tempFacilities.removeWhere((element) {
            //print(element.cap);
            var size = getSize(title);
            //print(size);
            return false;
            // if (size == 21) {
            //   return element.cap < 20;
            // } else if (size == 11) {
            //   return element.cap > 20 && element.cap < 10;
            // } else {
            //   return element.cap > 10;
            // }
          });
        }
      });
    }

    return _tempFacilities;
  }

  int getSize(String title) {
    int size = 0;
    switch (title) {
      case 'more than 20':
        size = 21;
        break;
      case 'between 10 and 20':
        size = 11;
        break;
      case 'less than 10':
        size = 9;
        break;
      case 'أكثر من ٢٠':
        size = 21;
        break;
      case 'بين ١٠ - ٢٠':
        size = 11;
        break;
      case 'أقل من ١٠':
        size = 9;
        break;
    }
    return size;
  }

  void deleteAllFilters() {
    categories.forEach((element) {
      element.isSelected = false;
    });

    capacity.forEach((element) {
      element.isSelected = false;
    });

    faculty.forEach((element) {
      element.isSelected = false;
    });
    notifyListeners();
  }

  List<DropItems> getTotalFilter() {
    List<DropItems> _temp = [];

    categories.forEach((element) {
      if (element.isSelected) {
        _temp.add(element);
      }
    });
    capacity.forEach((element) {
      if (element.isSelected) {
        _temp.add(element);
      }
    });
    faculty.forEach((element) {
      if (element.isSelected) {
        _temp.add(element);
      }
    });

    return _temp;
  }

  List<TimeOfDay> avaliableTime() {
    List<TimeOfDay> _avaliableTime = [];
    //Adding first time
    _avaliableTime.add(_firstTime);

    ///Get how many time will add times avaliable
    var loopTime = _lastTime.hour - _firstTime.hour;
    for (int i = 1; i <= loopTime; i++) {
      _avaliableTime.add(TimeOfDay(hour: (_firstTime.hour + i), minute: 00));
    }
    return _avaliableTime;
  }

  Future<List<dynamic>> filterFacilities() async {
    final url = Uri.parse('http://127.0.0.1:5000/${auth.token}');
    try {
      final response = await http.get(url);
      //remove slashes
      final extractedData = json.decode(response.body);
      //convert string to Json
      final data = jsonDecode(extractedData) as Map<String, dynamic>;
      // ignore: avoid_print
      print('$data this is the filters from python');
      return data['data'];
    } catch (error) {
      // ignore: use_rethrow_when_possible
      throw error;
    }
  }
}
