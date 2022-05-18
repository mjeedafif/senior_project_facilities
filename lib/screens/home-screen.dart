// ignore_for_file: file_names
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//Model
import '../model/dropItems.dart';

//Colors
import '../constants/colors.dart';

//providers
import '../provider/Auth.dart';
import '../provider/facilities.dart';
import '../provider/User.dart';
import '../provider/booking.dart';
import '../provider/language.dart';

//Translations
import '../translations/locale_keys.g.dart';

//widgets
import '../widgets/appBar-homeScreen.dart';
import '../widgets/categoryWidget-home.dart';

class HomeScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> globalKey;
  const HomeScreen({required this.globalKey, Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<DropItems> categories;
  late List<DropItems> capacity;
  late List<DropItems> faculty;

  List<DropItems> totalFilter = [];

  late PersistentBottomSheetController controller;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      String lan = EasyLocalization.of(context)!.currentLocale.toString();
      print(lan);
      categories = Provider.of<FacilitiesProvider>(context, listen: false)
          .categories(lan);
      capacity =
          Provider.of<FacilitiesProvider>(context, listen: false).capacity(lan);
      faculty =
          Provider.of<FacilitiesProvider>(context, listen: false).faculty(lan);
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    totalFilter = Provider.of<FacilitiesProvider>(context, listen: false)
        .getTotalFilter();
    super.didChangeDependencies();
  }

  void showFacilities(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;

    controller = widget.globalKey.currentState!.showBottomSheet(
      (context) => FractionallySizedBox(
        heightFactor: mediaQuery.height < 880 ? 0.96 : 0.9,
        child: Consumer<FacilitiesProvider>(
          builder: (ctx, item, _) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              children: [
                Text(
                  LocaleKeys.filterFacilities.tr(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                filter(
                  'Categories',
                  categories.map((items) => option(items)).toList(),
                ),
                const SizedBox(
                  height: 20,
                ),
                filter(
                  'Capacity',
                  capacity.map((item) => option(item)).toList(),
                ),
                const SizedBox(
                  height: 20,
                ),
                filter(
                  'Faculty',
                  faculty.map((item) => option(item)).toList(),
                ),
                SizedBox(
                  height: mediaQuery.height > 880 ? 20 : 5,
                ),
                item.getTotalFilter().isNotEmpty
                    ? removeFilters()
                    : Container(),
                const Spacer(),
                confirm(context)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget removeFilters() {
    return ElevatedButton.icon(
      onPressed: () => Provider.of<FacilitiesProvider>(context, listen: false)
          .deleteAllFilters(),
      icon: const Icon(Icons.highlight_remove_outlined),
      label: Text(LocaleKeys.deleteAllFilters.tr()),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget confirm(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    return SizedBox(
      height: mediaQuery.height > 880 ? 70 : 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          ///Save the filtering
          totalFilter = Provider.of<FacilitiesProvider>(context, listen: false)
              .getTotalFilter();
          setState(() {});
          Navigator.of(context).pop();
        },
        child: Text(
          LocaleKeys.save.tr(),
          style: const TextStyle(
            fontSize: 24,
            fontFamily: 'Poppins',
          ),
        ),
        style: ElevatedButton.styleFrom(
          primary: ConstColors.widgetColor,
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: ConstColors.borderCategory,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget filter(String title, List<Widget> options) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Wrap(
            children: options,
          )
        ],
      ),
    );
  }

  Widget option(DropItems item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: FilterChip(
        labelPadding: const EdgeInsets.symmetric(horizontal: 9),
        selectedColor: ConstColors.textButtonColor,
        checkmarkColor: Colors.white,
        label: Text(item.title),
        onSelected: (isSelected) {
          item.isSelected = isSelected;
          controller.setState!(() {});
        },
        selected: item.isSelected,
        showCheckmark: true,
      ),
    );
  }

  void _errorMessage(String message) {
    //return an error message from loging and signUp
    Platform.isAndroid
        ? showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Try again'),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Ok'))
              ],
            ),
          )
        : showCupertinoDialog<void>(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Try again'),
              content: Text(message),
              actions: <CupertinoDialogAction>[
                CupertinoDialogAction(
                  child: const Text('Ok'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
  }

  Future<void> _future() async {
    final userId = Provider.of<Auth>(context, listen: false).userId;
    // final token = Provider.of<Auth>(context, listen: false).token;
    // print(token);
    await Provider.of<UserProvider>(context, listen: false)
        .getUser(userId)
        .catchError((error) => _errorMessage(error.toString()));
    await Provider.of<FacilitiesProvider>(context, listen: false)
        .getFacilitiesFromDB();
    await Provider.of<BookingProvider>(context, listen: false)
        .getSharedBookedTime(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false);
    // ignore: avoid_print
    print('rebuild');
    return SingleChildScrollView(
        child: FutureBuilder(
      future: _future(),
      builder: (ctx, snapshoot) =>
          snapshoot.connectionState == ConnectionState.waiting
              ? SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: const Center(child: CircularProgressIndicator()),
                )
              : Column(
                  children: [
                    //AppBar of the home page
                    AppBarHomeScreen(user.fName, true),
                    Expanded(
                      flex: 0,
                      child: Column(
                        children: [
                          filterFacilities(() => showFacilities(context)),
                          CategoryWidget(
                            label: LocaleKeys.meeting_rooms.tr(),
                            icon: FontAwesomeIcons.briefcase,
                          ),
                          CategoryWidget(
                            label: LocaleKeys.labs.tr(),
                            icon: FontAwesomeIcons.laptop,
                          ),
                          CategoryWidget(
                            label: LocaleKeys.theater.tr(),
                            icon: FontAwesomeIcons.gem,
                          ),
                          CategoryWidget(
                            label: LocaleKeys.sports.tr(),
                            icon: FontAwesomeIcons.volleyballBall,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
    ));
  }

  Widget filterFacilities(Function showFilter) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ElevatedButton(
        onPressed: () => showFilter(),
        child: SizedBox(
          width: 100,
          child: FittedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (totalFilter.isNotEmpty)
                  Text(
                    '${totalFilter.length} |',
                    style: TextStyle(
                      color: totalFilter.isEmpty ? Colors.black : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Icon(
                  Icons.filter_alt_outlined,
                  color: totalFilter.isEmpty ? Colors.black : Colors.white,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  LocaleKeys.filter.tr(),
                  style: TextStyle(
                    color: totalFilter.isEmpty ? Colors.black : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        style: ElevatedButton.styleFrom(
          primary:
              totalFilter.isEmpty ? Colors.white : ConstColors.textButtonColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: totalFilter.isEmpty
                  ? ConstColors.borderCategory
                  : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
