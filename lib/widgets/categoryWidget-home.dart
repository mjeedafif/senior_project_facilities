// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//Model
import '../model/dropItems.dart';

//colors
import '../constants/colors.dart';

//Screens
import '../screens/categories-screen.dart';

class CategoryWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  const CategoryWidget({
    required this.label,
    required this.icon,
    Key? key,
  }) : super(key: key);

  void showFacilities(BuildContext context) {
    Navigator.of(context).pushNamed(CategoryScreen.routeName, arguments: label);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showFacilities(context),
      child: Container(
        height: 90,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        child: Card(
          color: ConstColors.widgetColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: ConstColors.borderColor, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FaIcon(
                  icon,
                  size: 30,
                ),
                const SizedBox(
                  width: 30,
                ),
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


///Date and time
// Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 15.0),
//                 child: DateTimePicker(
//                   type: DateTimePickerType.date,
//                   dateMask: 'd MMM, yyyy',
//                   initialValue: DateTime.now().toString(),
//                   firstDate: DateTime(2000),
//                   lastDate: DateTime(2100),
//                   icon: const Icon(Icons.event),
//                   dateLabelText: 'Date',
//                   timeLabelText: "Hour",
//                   selectableDayPredicate: (date) {
//                     // Disable weekend days to select from the calendar
//                     if (date.weekday == 5 || date.weekday == 6) {
//                       return false;
//                     }

//                     return true;
//                   },
//                   onChanged: (val) => print(val),
//                   validator: (val) {
//                     print(val);
//                     return null;
//                   },
//                   onSaved: (val) => print(val),
//                 ),
//               ),
//               Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 15),
//                 height: 300,
//                 width: double.infinity,
//                 child: GridView.builder(
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemBuilder: (ctx, i) => Container(
//                     height: 20,
//                     width: 60,
//                     //margin: const EdgeInsets.all(20),
//                     child: Card(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         side: const BorderSide(
//                           color: Colors.grey,
//                           width: 1,
//                         ),
//                       ),
//                       child: Center(
//                         child: Text(
//                           '${avaliableTime[i].hour.toString()}:${avaliableTime[i].minute.toString()}0',
//                         ),
//                       ),
//                     ),
//                   ),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     mainAxisSpacing: 5,
//                     crossAxisSpacing: 20,
//                     childAspectRatio: 3 / 3,
//                     //mainAxisExtent: 50,
//                   ),
//                   itemCount: avaliableTime.length,
//                   padding: EdgeInsets.all(8),

//                   //shrinkWrap: true,
//                 ),
//               ),
