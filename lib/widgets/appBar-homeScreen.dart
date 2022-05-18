// ignore_for_file: file_names

import 'package:easy_localization/easy_localization.dart';

//Translation
import '../translations/locale_keys.g.dart';

import 'package:flutter/material.dart';

class AppBarHomeScreen extends StatelessWidget {
  final String fName;
  final bool isHome;
  late String? email;
  late String? uId;

  AppBarHomeScreen(this.fName, this.isHome, [this.email, this.uId]);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Container(
      height: isHome
          ? height >= 880
              ? MediaQuery.of(context).size.height * 0.32
              : MediaQuery.of(context).size.height * 0.40
          : height > 880
              ? MediaQuery.of(context).size.height * 0.4
              : MediaQuery.of(context).size.height * 0.5,
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 60,
        left: 50,
        right: 50,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisAlignment: isHome
            ? MainAxisAlignment.spaceAround
            : MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: const CircleAvatar(
              maxRadius: 45,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/images/person.png'),
            ),
          ),
          displayContent(context, isHome),
        ],
      ),
    );
  }

  Widget displayContent(BuildContext context, bool isHome) {
    final height = MediaQuery.of(context).size.height;
    return SizedBox(
      height: isHome
          ? height > 880
              ? MediaQuery.of(context).size.height * 0.1
              : MediaQuery.of(context).size.height * 0.15
          : height > 880
              ? MediaQuery.of(context).size.height * 0.2
              : MediaQuery.of(context).size.height * 0.25,
      width: isHome ? 190 : double.infinity,
      child: isHome
          ? Text(
              '${LocaleKeys.welcome_mssg.tr()} $fName',
              softWrap: true,
              style: const TextStyle(
                fontSize: 34,
              ),
            )
          : Column(
              children: [
                Text(
                  fName,
                  style: const TextStyle(
                    fontSize: 34,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  email as String,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  uId as String,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.grey,
                  ),
                )
              ],
            ),
    );
  }
}
