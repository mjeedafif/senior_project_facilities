// ignore_for_file: file_names

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:restart_app/restart_app.dart';
//import 'package:senior_project_facilities_app/translations/locale_keys.g.dart';

import '../widgets/appBar-homeScreen.dart';

//Translation
import '../translations/locale_keys.g.dart';

//provider
import '../provider/User.dart';
import '../provider/Auth.dart';
import '../provider/language.dart';
import '../provider/facilities.dart';

//Color
import '../constants/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final items = ['العربية', 'English'];
  String value = 'English';
  var locale = 'en';
  var _isvisited = true;

  @override
  void didChangeDependencies() {
    if (_isvisited) {
      var lan = context.locale.toString();
      switch (lan) {
        case 'en':
          value = 'English';
          break;
        default:
          value = 'العربية';
      }
    }
    setState(() {
      _isvisited = false;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            children: [
              AppBarHomeScreen(user.fName, false, user.email, user.uId),
              //! later to edit profile
              // Padding(
              //   padding: const EdgeInsets.only(top: 60.0, right: 20),
              //   child: SizedBox(
              //     child: IconButton(
              //       alignment: Alignment.centerRight,
              //       onPressed: () {
              //         //Edit the profile
              //         print('Edit the profile');
              //       },
              //       icon: const Icon(Icons.edit),
              //     ),
              //     width: double.infinity,
              //   ),
              // ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.49,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 25),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              LocaleKeys.language.tr(),
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        dropDownLonguage(),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    children: [
                      profileButtons(ConstColors.helpColor,
                          LocaleKeys.help_line.tr(), () {}),
                      const SizedBox(
                        height: 20,
                      ),
                      profileButtons(ConstColors.logoutColor,
                          LocaleKeys.logout.tr(), auth.logout),
                      const SizedBox(
                        height: 30,
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  ElevatedButton profileButtons(Color color, String text, Function function) {
    return ElevatedButton(
      onPressed: () => function(),
      child: Text(text,
          style: const TextStyle(
            fontSize: 20,
          )),
      style: ElevatedButton.styleFrom(
        primary: color,
        minimumSize: const Size(300, 50),
      ),
    );
  }

  Widget dropDownLonguage() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: ConstColors.borderSelectColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(11),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 45),
      padding: const EdgeInsets.all(10),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            hint: const Text(
              'Language',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 23,
              ),
            ),
            // items
            //     .map((item) =>
            //         builderMenuItem(item, ConstColors.textButtonColor))
            //     .toList(),

            items: [
              DropdownMenuItem(
                value: 'العربية',
                child: Text(
                  'العربية',
                  style: TextStyle(
                    color:
                        value == 'العربية' ? ConstColors.textButtonColor : null,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 'English',
                child: Text(
                  'English',
                  style: TextStyle(
                    color:
                        value == 'English' ? ConstColors.textButtonColor : null,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
            onChanged: (value) async {
              switch (value) {
                case 'English':
                  locale = 'en';
                  break;
                default:
                  locale = 'ar';
              }
              await context.setLocale(
                Locale(locale),
              );
              Provider.of<FacilitiesProvider>(context, listen: false)
                  .deleteAllFilters();
              Platform.isIOS
                  ? showCupertinoDialog<void>(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: const Text('Please restart the app'),
                        actions: <CupertinoDialogAction>[
                          CupertinoDialogAction(
                            child: const Text('Ok'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    )
                  : showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                          title: const Text('Please restart the app'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Restart.restartApp();
                              },
                              child: const Text('Ok'),
                            )
                          ]),
                    );
              setState(() {
                this.value = value!;
                Provider.of<Language>(context, listen: false)
                    .changeLanguage(this.value, context);
              });
            }),
      ),
    );
  }
}

DropdownMenuItem<String> builderMenuItem(String item, Color style) =>
    DropdownMenuItem(
      value: item,
      child: Text(
        item,
        style: TextStyle(
          color: item == 'English' ? null : style,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
