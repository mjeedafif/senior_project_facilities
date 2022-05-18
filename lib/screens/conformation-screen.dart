import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cool_alert/cool_alert.dart';

//Provider
import '../provider/booking.dart';
import '../provider/facilities.dart';
import '../provider/Auth.dart';

//Colors
import '../constants/colors.dart';

class ConformationScreen extends StatefulWidget {
  static const routeName = '/conformation-page';
  final Facilities facility;
  final Booking reservation;
  const ConformationScreen(this.facility, this.reservation, {Key? key})
      : super(key: key);

  @override
  State<ConformationScreen> createState() => _ConformationScreenState();
}

class _ConformationScreenState extends State<ConformationScreen> {
  var check = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final editedTime = widget.reservation.time;
    //final String editedDate = widget.reservation.date.split(' ')[0];
    final hour = editedTime.hour.toString();
    final min = editedTime.minute != 0
        ? editedTime.minute.toStringAsPrecision(2)
        : editedTime.minute.toString();
    return Scaffold(
      body: Container(
        height: size.height,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
        child: Column(
          children: [
            functionalityOfWidget(context, 'Confirmation'),
            imageWidgte(size),
            sizedBox(5, 0),
            titleWidget(),
            sizedBox(20, 0),
            descriptionFacility(size, hour, min),
            if (size.height > 880) sizedBox(30, 0),
            agreeWidget(),
            sizedBox(50, 0),
            confirmationButton(size),
          ],
        ),
      ),
    );
  }

  Widget confirmationButton(Size size) {
    return SizedBox(
      width: size.width * 0.6,
      height: size.height * 0.04,
      child: ElevatedButton(
        onPressed: !check
            ? null
            : () async {
                //Get the user id and save the booked for him
                final userId = Provider.of<Auth>(context, listen: false).userId;
                Provider.of<BookingProvider>(context, listen: false)
                    .addBookedTime(
                        userId, widget.reservation.date, widget.reservation);
                //Show the alert of conformation
                ///Save the filtering
                //Show the alert of conformation
                await CoolAlert.show(
                  title: 'Confirmed',
                  context: context,
                  type: CoolAlertType.success,
                  confirmBtnColor: ConstColors.primaryColor,
                  text: 'Facility reserved successfully',
                );
                Navigator.of(context).pushReplacementNamed('/');
              },
        child: const Text('Confirm'),
        style: ElevatedButton.styleFrom(
          primary: check ? ConstColors.primaryColor : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: check
                  ? Colors.transparent
                  : ConstColors.borderTextFieldsColor,
            ),
          ),
        ),
      ),
    );
  }

  Row agreeWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
          value: check,
          activeColor: ConstColors.backButtonColor,
          onChanged: (newCheck) {
            setState(
              () {
                check = newCheck!;
              },
            );
          },
        ),
        const Text('Agree the terms and conditions'),
      ],
    );
  }

  Container descriptionFacility(Size size, String hour, String min) {
    return Container(
      height: size.height > 880 ? size.height * 0.12 : size.height * 0.14,
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: ConstColors.borderCategory,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: double.infinity,
            child: Text(
              'Description of the facility',
              textAlign: TextAlign.center,
            ),
          ),
          sizedBox(5, 0),
          Text('Time: $hour:${min}0'),
          sizedBox(5, 0),
          Text('Date: ${widget.reservation.date.split(' ')[0]}'),
        ],
      ),
    );
  }

  Widget titleWidget() {
    return Row(
      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FittedBox(
          child: Text(
            widget.facility.name,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Spacer(),
        Text('(${widget.facility.voteCoun})${widget.facility.voteAvg}'),
        const Icon(Icons.star_border),
      ],
    );
  }

  Widget imageWidgte(Size size) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      height: size.height * 0.3,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          widget.facility.imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget sizedBox(double height, double width) {
    return SizedBox(
      height: height,
      width: width,
    );
  }

  void goBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  void goHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/');
  }

  Widget functionalityOfWidget(BuildContext context, String label) {
    return Row(
      //mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        helpMethodScreen(
          context,
          Icons.arrow_back_ios,
          goBack,
        ),
        const Spacer(),
        FittedBox(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Spacer(),
        helpMethodScreen(
          context,
          Icons.cancel_outlined,
          goHome,
        ),
      ],
    );
  }

  Container helpMethodScreen(
      BuildContext context, IconData icon, Function action) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: ConstColors.backButtonColor,
      ),
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () => action(context),
        child: Icon(icon),
      ),
    );
  }
}
