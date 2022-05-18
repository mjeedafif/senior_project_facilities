// ignore_for_file: file_names
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/cupertino.dart';
//import 'package:easy_localization/easy_localization.dart';

//Translations
//import '../translations/locale_keys.g.dart';

//providers
import '../provider/User.dart';
import '../provider/Auth.dart';
import '../provider/facilities.dart';

//screen
import '../screens/home-screen.dart';
import '../screens/profile-scree.dart';
import '../screens/reservations-screen.dart';

//widget
import '../widgets/bottomNavBar-widget.dart';
import '../widgets/categoryFacilityWidget.dart';

class FacilityApp extends StatefulWidget {
  // ! Could remove this is for test
  //final bool useFaceId;
  const FacilityApp({Key? key}) : super(key: key);
  @override
  _FacilityAppState createState() => _FacilityAppState();
}

class _FacilityAppState extends State<FacilityApp> {
  final LocalAuthentication auth = LocalAuthentication();
  late List<Widget> tabs;
  var globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    tabs = [
      const ReservationScreen(),
      HomeScreen(globalKey: globalKey),
      const ProfileScreen(),
    ];
    super.initState();
  }

  //Create secure storage to store userId and password
  //final storage = const FlutterSecureStorage();
  int index = 1;

  void changePage(int value) {
    setState(() {
      index = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      body: tabs[index],
      //facilitiesApp(),
      //body: const CategoryFacility(),
      bottomNavigationBar: BottomNavBar(
        index: index,
        changePage: changePage,
      ),
    );
  }
}
