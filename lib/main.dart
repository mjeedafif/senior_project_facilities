//import 'dart:io';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

//screens
import './screens/auth-screen.dart';
import './screens/rateing-screen.dart';
import './screens/reservations-screen.dart';
import './screens/myApp.dart';
import './screens/categories-screen.dart';

//Provider
import './provider/Auth.dart';
import './provider/User.dart';
import './provider/facilities.dart';
import './provider/booking.dart';
import './provider/canelled.dart';
import './provider/language.dart';

//Translations
import './translations/codegen_loader.g.dart';

//colors
import './constants/colors.dart';

void main() async {
  HttpOverrides.global = new MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(
    EasyLocalization(
      child: const MyApp(),
      path: 'assets/translations',
      assetLoader: const CodegenLoader(),
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, FacilitiesProvider>(
          create: (ctx) => FacilitiesProvider(),
          update: (ctx, auth, prev) => prev!..auth = auth,
        ),
        ChangeNotifierProxyProvider<Auth, UserProvider>(
          update: (ctx, auth, prev) => prev!..auth = auth,
          create: (ctx) => UserProvider(),
        ),
        ChangeNotifierProxyProvider<Auth, BookingProvider>(
          update: (ctx, auth, prev) => prev!..auth = auth,
          create: (ctx) => BookingProvider(),
        ),
        ChangeNotifierProxyProvider<Auth, CancelledProvider>(
          update: (ctx, auth, prev) => prev!..auth = auth,
          create: (ctx) => CancelledProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Language(),
        ),
        // ChangeNotifierProxyProvider<FacilitiesProvider, CancelledProvider>(
        //   create: (ctx) => CancelledProvider(),
        //   update: (ctx, getFacilities, prev) =>
        //       prev!..facility = getFacilities.facilities,
        // ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) {
          return MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            title: 'KAU Facilities',
            debugShowCheckedModeBanner: false,
            home: auth.isAuth() ? const FacilityApp() : const AuthScreen(),
            //home: const FacilityApp(),
            theme: ThemeData(
              fontFamily: 'Poppins',
              colorScheme: ColorScheme.fromSwatch(
                //prev color 0xffBBD57C
                //light color 0xffBEE5B0
                primarySwatch: ConstColors.buildMaterialColor(
                  const Color(0xffBBD57C),
                ),
                accentColor: const Color(0xffBEE5B0),
              ),
            ),
            routes: {
              CategoryScreen.routeName: (ctx) => CategoryScreen(),
              ReservationScreen.routeName: (ctx) => const ReservationScreen(),
              RaitingPage.routeName: (ctx) => const RaitingPage(),
              //ConformationScreen.routeName: (ctx) => const ConformationScreen(),
            },
          );
        },
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  // HttpClient test(SecurityContext context) {
  //   return super.createHttpClient(context)
  //     ..badCertificateCallback = (cert, host, port) => true;
  // }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}
