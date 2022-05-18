// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import '../translations/locale_keys.g.dart';
import 'package:local_auth/local_auth.dart';

import 'dart:io';

//providers
import '../provider/Auth.dart';
import '../provider/User.dart';

//Screen
import '../screens/myApp.dart';

//color
import '../constants/colors.dart';

enum AuthType { login, signUp }

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var authType = AuthType.login;
  // ? these two controller for confirmation
  late TextEditingController _passController;
  //late TextEditingController _confirmPass;
  final Map<String, String> _authData = {
    'userId': '',
    'fName': '',
    'email': '',
    'password': '',
  };
  //late bool useFaceId = false;
  late GlobalKey<FormState> _formState;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    // _passController = TextEditingController();
    // _confirmPass = TextEditingController();
    // _formState = GlobalKey();
    //useFaceId = false;
    //getUsingBiometric();
    // Timer(const Duration(milliseconds: 1), getUsingBiometric);
    initAsync();
    super.initState();
  }

  void initAsync() async {
    _passController = TextEditingController();
    //_confirmPass = TextEditingController();
    _formState = GlobalKey();
    //getUsingBiometric();
  }

  @override
  void dispose() {
    _passController.dispose();
    //_confirmPass.dispose();
    super.dispose();
  }

  void authenticate() async {
    final canCheck = await auth.canCheckBiometrics;

    if (canCheck) {
      List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();

      if (Platform.isIOS) {
        if (availableBiometrics.contains(BiometricType.face)) {
          // Face ID.
          final isAuthenticated = await auth.authenticate(
              localizedReason: 'Enable Face ID to sign in more easily');
          if (isAuthenticated) {
            // ! change the logic this now just let him go to home page
            Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => const FacilityApp()),
            );
          }
        } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
          // Touch ID.
        }
      }
    } else {
      print('Not supperted');
    }
  }

  // void setUsingBiometric(bool value) async {
  //   final prefs = await SharedPreferences.getInstance();

  //   await prefs.setBool('isUsingBiometric', value);
  //   setState(() {
  //     useFaceId = value;
  //   });
  // }

  // void getUsingBiometric() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     useFaceId = prefs.getBool('isUsingBiometric')!;
  //   });
  // }

  String _message(String message) {
    if (message.contains('EMAIL_EXISTS')) {
      return 'The email is already exist';
    } else if (message.contains('EMAIL_NOT_FOUND')) {
      return 'The email is not found';
    } else if (message.contains('INVALID_PASSWORD')) {
      return 'The password is invalid';
    }
    return 'Sorry can\'t authenticate you';
  }

  void _errorMessage(String message) {
    //return an error message from loging and signUp
    Platform.isAndroid
        ? showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Try again'),
              content: Text(_message(message)),
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
              content: Text(_message(message)),
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

  // ignore: todo
  // TODO: this function for form confirmation make changes
  void confirmAuth() async {
    bool isConfirmed = _formState.currentState!.validate();
    if (!isConfirmed) {
      return;
    }
    _formState.currentState!.save();

    if (authType == AuthType.login) {
      // Log user in
      await Provider.of<Auth>(context, listen: false)
          .logIn(_authData['email'], _authData['password'])
          .catchError((error) => _errorMessage(error.toString()));
    } else {
      // Sign user up
      await Provider.of<Auth>(context, listen: false)
          .signUp(_authData['email'], _authData['password']);
      await Provider.of<UserProvider>(context, listen: false)
          .addUser(_authData['fName'], _authData['userId'], _authData['email'])
          .catchError((error) => _errorMessage(error.toString()));
      //.catchError((error) => _errorMessage(error.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.only(top: 70),
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.infinity,
              alignment: Alignment.center,
              child: Image.asset(
                'assets/images/KAU.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              height: authType == AuthType.signUp
                  ? MediaQuery.of(context).size.height * 0.75
                  : MediaQuery.of(context).size.height * 0.60,
              width: double.infinity,
              color: Colors.transparent,
              margin: const EdgeInsets.symmetric(
                horizontal: 50,
              ),
              child: Form(
                key: _formState,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        //For email registeration
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onSaved: (value) {
                          _authData['email'] = value!;
                        },
                        validator: (value) {
                          if (value!.isEmpty || !value.contains('@')) {
                            return 'Invalid email!';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: LocaleKeys.email.tr(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: ConstColors.borderTextFieldsColor,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      if (authType == AuthType.signUp)
                        Column(
                          children: [
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              //For email registeration
                              keyboardType: TextInputType.emailAddress,
                              onSaved: (value) {
                                _authData['fName'] = value!;
                              },
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Cannot be empty';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: LocaleKeys.first_name.tr(),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: ConstColors.borderTextFieldsColor,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.text,
                              onSaved: (value) {
                                _authData['userId'] = value!;
                              },
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Cannot be empty';
                                } else if (value.length != 7) {
                                  return 'Id is not correct';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: LocaleKeys.user_id.tr(),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: ConstColors.borderTextFieldsColor,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        //For password
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        controller: _passController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Cannot be empty';
                          }

                          return null;
                        },
                        textInputAction: authType == AuthType.signUp
                            ? TextInputAction.next
                            : TextInputAction.done,
                        onSaved: (value) {
                          _authData['password'] = value!;
                        },
                        decoration: InputDecoration(
                          hintText: LocaleKeys.password.tr(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: ConstColors.borderTextFieldsColor,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      //Confirmation pass
                      if (authType == AuthType.signUp)
                        TextFormField(
                          //For confirm password
                          obscureText: true,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          //controller: _confirmPass,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Cannot be empty';
                            }
                            if (_passController.text != value) {
                              return 'Password not match';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: LocaleKeys.confirm_pass.tr(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: ConstColors.borderTextFieldsColor,
                                width: 1,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(
                        height: 15,
                      ),
                      ElevatedButton(
                        onPressed: confirmAuth,
                        child: Text(
                          authType == AuthType.login
                              ? LocaleKeys.login.tr()
                              : LocaleKeys.signup.tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: authType == AuthType.login
                            ? MainAxisAlignment.spaceBetween
                            : MainAxisAlignment.center,
                        children: [
                          if (authType == AuthType.login)
                            //Forgot pass
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                LocaleKeys.forget_pass.tr(),
                                style: const TextStyle(
                                  color: ConstColors.textButtonColor,
                                ),
                              ),
                            ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                authType == AuthType.login
                                    ? authType = AuthType.signUp
                                    : authType = AuthType.login;
                              });
                            },
                            child: Text(
                              authType == AuthType.login
                                  ? LocaleKeys.signup.tr()
                                  : LocaleKeys.login.tr(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: ConstColors.textButtonColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      //if (authType == AuthType.login)
                      //For using face ID
                      // useFaceId
                      //     ? GestureDetector(
                      //         onTap: authenticate,
                      //         child: Container(
                      //           padding: const EdgeInsets.all(10),
                      //           decoration: BoxDecoration(
                      //             border: Border.all(
                      //               width: 1,
                      //               color: ConstColors.borderColor,
                      //             ),
                      //             shape: BoxShape.circle,
                      //           ),
                      //           child: Image.asset(
                      //             'assets/images/face_id_icon.png',
                      //             height: 30,
                      //           ),
                      //         ),
                      //       )
                      //     : Row(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         children: [
                      //           Checkbox(
                      //             value: useFaceId,
                      //             activeColor: ConstColors.textButtonColor,
                      //             side: const BorderSide(
                      //               style: BorderStyle.solid,
                      //               width: 1,
                      //               color: ConstColors.borderColor,
                      //             ),
                      //             onChanged: (val) => setUsingBiometric(val!),
                      //             shape: const CircleBorder(),
                      //           ),
                      //           const Text(
                      //             'Use Face ID',
                      //             style: TextStyle(
                      //               color: ConstColors.textButtonColor,
                      //               fontSize: 20,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
