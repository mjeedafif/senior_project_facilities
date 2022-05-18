import 'package:flutter/material.dart';

//Provider
import '../provider/facilities.dart';

//Colors
import '../constants/colors.dart';

class RaitingPage extends StatefulWidget {
  static const routeName = '/RaitingPage';
  const RaitingPage({Key? key}) : super(key: key);

  @override
  State<RaitingPage> createState() => _RaitingPageState();
}

class _RaitingPageState extends State<RaitingPage> {
  final _formKey = GlobalKey<FormState>();
  late String _raiting;
  String? _feedBack;

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments as Facilities;
    print('$data');
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        title: const Text('Raiting page'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Improve our system',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                sizedBox(20),
                textField(
                  'Raiting',
                  'Out of 10',
                  TextInputAction.next,
                  TextInputType.number,
                  1,
                  validateRaiting,
                  saveRaiting,
                ),
                sizedBox(20),
                textField(
                  'Feedback',
                  'It\'s amazing facility',
                  TextInputAction.done,
                  TextInputType.text,
                  3,
                  validateFeedBack,
                  saveFeedBack,
                ),
                sizedBox(30),
                ElevatedButton(
                  onPressed: () => submit(),
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SizedBox sizedBox(double height) => SizedBox(height: height);

  //Form functionality

  void submit() {
    print('Submited');
    _formKey.currentState!.validate();
    _formKey.currentState!.save();
  }

  String? validateRaiting(String val) {
    if (val.isEmpty) {
      return 'Required';
    }
    if (int.parse(val) > 10 || int.parse(val) < 0) {
      return 'It should be between 0 and 10';
    }
    return null;
  }

  String? validateFeedBack(String val) {
    return null;
  }

  void saveRaiting(String val) {
    _raiting = val;
  }

  void saveFeedBack(String val) {
    _feedBack = val;
  }

  TextFormField textField(
      String label,
      String hint,
      TextInputAction action,
      TextInputType type,
      int lines,
      Function(String val) validator,
      Function(String) variable) {
    return TextFormField(
      textInputAction: action,
      keyboardType: type,
      maxLines: lines,
      decoration: InputDecoration(
        label: Text(label),
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            width: 1,
            color: ConstColors.primaryColor,
          ),
        ),
      ),
      validator: (val) => validator(val!),
      onSaved: (val) => variable(val!),
    );
  }
}
