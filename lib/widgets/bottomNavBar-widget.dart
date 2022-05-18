// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//Translations
import '../translations/locale_keys.g.dart';

//Colors
import '../constants/colors.dart';

// ignore: must_be_immutable
class BottomNavBar extends StatelessWidget {
  final int index;
  Function(int value) changePage;
  BottomNavBar({
    required this.index,
    required this.changePage,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      unselectedItemColor: ConstColors.borderColor,
      currentIndex: index,
      onTap: (value) => changePage(value),
      items: [
        BottomNavigationBarItem(
          icon: const FaIcon(FontAwesomeIcons.clock),
          label: LocaleKeys.reservation.tr(),
        ),
        BottomNavigationBarItem(
          icon: const FaIcon(FontAwesomeIcons.home),
          label: LocaleKeys.home.tr(),
        ),
        BottomNavigationBarItem(
          icon: const FaIcon(FontAwesomeIcons.user),
          label: LocaleKeys.profile.tr(),
        ),
      ],
    );
  }
}
