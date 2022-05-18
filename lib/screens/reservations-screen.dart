// ignore_for_file: file_names
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';

//Translations
import '../translations/locale_keys.g.dart';

//Provider
import '../provider/facilities.dart';
import '../provider/booking.dart';
import '../provider/canelled.dart';
import '../provider/Auth.dart';

//Color
import '../constants/colors.dart';

//Screen
import './rateing-screen.dart';

class ReservationScreen extends StatefulWidget {
  static const routeName = '/reservation-page';
  const ReservationScreen({Key? key}) : super(key: key);

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  List<bool> isSelected = [true, false];
  int index = 0;
  late Map<String, dynamic> test;
  List<Booking> reservations = [];
  var cancelled = [];
  var cancelledFromDB = [];
  late PersistentBottomSheetController controller;
  final globalKey = GlobalKey<ScaffoldState>();

  Future<void> _future() async {
    final userId = Provider.of<Auth>(context, listen: false).userId;
    await Provider.of<BookingProvider>(context, listen: false)
        .getBookedTime(userId);
    test = Provider.of<BookingProvider>(context, listen: false).bookedTime();
    reservations = [];
    test.forEach((key, value) {
      reservations.addAll(value);
    });
  }

  Future<void> _futureCancell() async {
    final userId = Provider.of<Auth>(context, listen: false).userId;
    final List<dynamic> dataCancelled =
        await Provider.of<CancelledProvider>(context, listen: false)
            .getCancelled(userId);
    //Clear the temp to new Initalize
    Provider.of<CancelledProvider>(context, listen: false).clearTemp();
    dataCancelled.forEach((element) {
      //Each value as map
      final Map<String, dynamic> mapOfData = element;
      //Get the facility from facility provider
      Facilities facility =
          Provider.of<FacilitiesProvider>(context, listen: false)
              .getFacility(mapOfData['id']);
      //extract the data
      String date = mapOfData['date'];
      String time = mapOfData['time'];
      //Add the booking object in _cancelled
      Provider.of<CancelledProvider>(context, listen: false)
          .addTempCancelled(facility, date, time);
    });
    cancelled =
        Provider.of<CancelledProvider>(context, listen: false).tempCancelled;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    return Scaffold(
      key: globalKey,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
        child: Column(
          children: [
            title(),
            toggleButton(mediaQuery),
            sizedBox(20.0, 0),

            ///Add list widget the length is the list up
            ///Inside the list put this condition
            ///Now make it static
            if (isSelected[0]) //Text(reservations.toString()),
              // reservationWidget(
              //   true,
              //   reservations[0].item.imageUrl,
              //   reservations[0].item.name,
              //   reservations[0].date,
              //   reservations[0].time.toString(),
              // ),
              FutureBuilder(
                future: _future(),
                builder: (ctx, snapshoot) => snapshoot.connectionState ==
                        ConnectionState.waiting
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Expanded(
                        child: reservations.isEmpty
                            ? const Center(
                                child: Text(
                                  'No records',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: reservations.length,
                                itemBuilder: (ctx, i) =>
                                    reservationWidget(true, reservations[i]),
                              ),

                        //   child: Column(
                        //     children: reservations
                        //         .map(
                        //           (element) => reservationWidget(
                        //             true,
                        //             element.item.imageUrl,
                        //             element.item.name,
                        //             element.date,
                        //             element.time.toString(),
                        //           ),
                        //         )
                        //         .toList(),
                        //   ),
                        // ),
                        //if (isSelected[1]) reservationWidget(false),
                      ),
              ),
            if (isSelected[1])
              FutureBuilder(
                future: _futureCancell(),
                builder: (ctx, snapshoot) =>
                    snapshoot.connectionState == ConnectionState.waiting
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Expanded(
                            child: cancelled.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No records',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: cancelled.length,
                                    itemBuilder: (ctx, i) =>
                                        reservationWidget(false, cancelled[i]),
                                  ),
                          ),
              ),
          ],
        ),
      ),
    );
  }

  String getStatus(String date, TimeOfDay time) {
    date = date.replaceAll('-', ' ');
    int month = int.parse(date.split(' ')[1]);
    int day = int.parse(date.split(' ')[2]);
    int year = DateTime.now().year;
    DateTime checkDate = DateTime(year, month, day);
    TimeOfDay checkTime =
        TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute);
    if ((checkDate.isAfter(DateTime.now()) ||
        (checkDate.day == DateTime.now().day &&
            checkDate.month == DateTime.now().month &&
            checkTime.hour < time.hour))) {
      return 'Up comming';
    } else {
      return 'Completed';
    }
  }

  void showReservationDetails(Booking data, bool status, String titleStatus) {
    int hour = data.time.hour;
    String min = '${data.time.minute}';
    String nextDigitOfMin = '${data.time.minute == 0 ? 0 : ''}';
    int nextHour = (data.time.hour + data.item.duration);
    String labelOfNextHour = '$nextHour:$min$nextDigitOfMin';
    final size = MediaQuery.of(context).size;
    controller = globalKey.currentState!.showBottomSheet(
      (context) => FractionallySizedBox(
        heightFactor: size.height > 800 ? 0.75 : 0.9,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              child: Image.network(
                data.item.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: ConstColors.borderCategory,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.item.name,
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    data.date,
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    '$hour:$min$nextDigitOfMin - $labelOfNextHour',
                    style: const TextStyle(fontSize: 18),
                  )
                ],
              ),
            ),
            status
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: titleStatus == 'Completed'
                        ? Column(
                            children: [
                              const Text(
                                'Completed',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: ConstColors.primaryColor),
                              ),
                              const SizedBox(height: 15),
                              ElevatedButton(
                                onPressed: () {
                                  //Show alert to rate
                                  Navigator.of(context).popAndPushNamed(
                                    RaitingPage.routeName,
                                    arguments: data.item,
                                  );
                                },
                                child: const Text('Rate the facility'),
                              ),
                            ],
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              final String userId =
                                  Provider.of<Auth>(context, listen: false)
                                      .userId;
                              //Here it should make the conformation deletion
                              CoolAlert.show(
                                context: context,
                                type: CoolAlertType.warning,
                                animType: CoolAlertAnimType.slideInDown,
                                showCancelBtn: true,
                                title: 'Are you sure?',
                                text: 'Do you want to delete',
                                confirmBtnText: 'Yes',
                                cancelBtnText: 'No',
                                barrierDismissible: false,
                                confirmBtnColor: ConstColors.logoutColor,
                                onCancelBtnTap: () {
                                  Navigator.of(context).pop();
                                },
                                onConfirmBtnTap: () async {
                                  await Provider.of<BookingProvider>(context,
                                          listen: false)
                                      .deleteFromDb(data, userId)
                                      .catchError(
                                        (err) => _errorMessage(err),
                                      );
                                  Provider.of<BookingProvider>(context,
                                          listen: false)
                                      .deleteReservation(data);
                                  await Provider.of<CancelledProvider>(context,
                                          listen: false)
                                      .addCancelled(data, userId);
                                  reservations.removeWhere((element) =>
                                      element.item.id == data.item.id &&
                                      element.time == data.time &&
                                      element.date == data.date);

                                  //One for the alert
                                  Navigator.of(context).pop();
                                  //THe other one for the model bottom sheet
                                  Navigator.of(context).pop();
                                  setState(() {});
                                },
                              );
                            },
                            child: const Text('Delete the reservation'),
                            style: ElevatedButton.styleFrom(
                              primary: ConstColors.logoutColor,
                            ),
                          ),
                  )
                : const SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Cancelled',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
          ],
        ),
      ),
      backgroundColor: ConstColors.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
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

  Future confirmDeletion(Booking data) async {
    final String userId = Provider.of<Auth>(context, listen: false).userId;
    //Here it should make the conformation deletion
    await CoolAlert.show(
      context: context,
      type: CoolAlertType.warning,
      animType: CoolAlertAnimType.slideInDown,
      showCancelBtn: true,
      title: 'Are you sure?',
      text: 'Do you want to delete',
      confirmBtnText: 'Yes',
      cancelBtnText: 'No',
      barrierDismissible: false,
      confirmBtnColor: ConstColors.logoutColor,
      onCancelBtnTap: () {
        Navigator.of(context).pop();
      },
      onConfirmBtnTap: () async {
        await Provider.of<BookingProvider>(context, listen: false)
            .deleteFromDb(data, userId)
            .catchError(
              (err) => _errorMessage(err),
            );
        Provider.of<BookingProvider>(context, listen: false)
            .deleteReservation(data);

        //One for the alert
        Navigator.of(context).pop();
        //THe other one for the model bottom sheet
        Navigator.of(context).pop();
        setState(() {});
      },
    );
  }

  Widget reservationWidget(bool status, Booking receiveData) {
    //var date = receiveData.date;
    var hour = receiveData.time.hour.toString();
    var titleStatus = getStatus(receiveData.date, receiveData.time);
    var min = receiveData.time.minute;
    return InkWell(
      onTap: () => showReservationDetails(receiveData, status, titleStatus),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: ConstColors.textFieldsColor,
              //color: Colors.greenAccent,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(receiveData.item.imageUrl),
                ),
                sizedBox(0, 20.0),
                Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(receiveData.item.name),
                      sizedBox(10.0, 0),
                      Text(
                          '${receiveData.date} -  $hour:${min != 0 ? min.toStringAsPrecision(2) : min.toString()}0'),
                      Text(
                        status ? titleStatus : 'Cancelled',
                        //textAlign: TextAlign.start,
                        style: TextStyle(
                          color: status ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          sizedBox(20, 0),
        ],
      ),
    );
  }

  SizedBox sizedBox(double heightValue, double widthValue) {
    return SizedBox(
      height: heightValue,
      width: widthValue,
    );
  }

  Widget title() {
    return const SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: Text(
          'Reservation Record',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget toggleButton(Size mediaQuery) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      child: ToggleButtons(
        fillColor: ConstColors.textFieldsColor,
        color: Colors.black,
        selectedColor: ConstColors.selectedColor,
        renderBorder: false,
        borderRadius: BorderRadius.circular(50),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: mediaQuery.height >= 880
                  ? (mediaQuery.width / 7.0)
                  : (mediaQuery.width / 9.0),
            ),
            child: Text('Reservations'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: mediaQuery.height >= 880
                  ? (mediaQuery.width / 7.2)
                  : (mediaQuery.width / 9),
            ),
            child: Text('Cancelled'),
          ),
        ],
        onPressed: (int newIndex) {
          setState(() {
            for (int index = 0; index < isSelected.length; index++) {
              if (newIndex == index) {
                isSelected[index] = true;
              } else {
                isSelected[index] = false;
              }
            }
            index = newIndex;
          });
        },
        isSelected: isSelected,
      ),
    );
  }
}
