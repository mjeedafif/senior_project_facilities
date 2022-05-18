import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:date_time_picker/date_time_picker.dart';
//import 'package:senior_project_facilities_app/provider/facilities.dart';

import 'package:easy_localization/easy_localization.dart';

//Color
import '../constants/colors.dart';

//Screen
import '../screens/conformation-screen.dart';

//Provider
import '../provider/canelled.dart';
import '../provider/facilities.dart';
import '../provider/booking.dart';

class CategoryFacility extends StatefulWidget {
  final int id;
  final String imageUrl;
  final String name;
  final int voteCunt;
  final double voteAvg;
  final GlobalKey<ScaffoldState> globalKey;

  const CategoryFacility(
      {required this.id,
      required this.imageUrl,
      required this.name,
      required this.voteCunt,
      required this.globalKey,
      required this.voteAvg,
      Key? key})
      : super(key: key);

  @override
  State<CategoryFacility> createState() => _CategoryFacilityState();
}

class _CategoryFacilityState extends State<CategoryFacility> {
  late PersistentBottomSheetController controller;
  late List<Booking> avaliableTime;
  //String date = DateTime.now().toIso8601String();
  Booking? reservation;
  DateTime? selectedDate;
  late Facilities facility;

  @override
  void initState() {
    int year = DateTime.now().year;
    int month = DateTime.now().month;
    int day = DateTime.now().day;
    selectedDate = DateTime.now();
    Future.delayed(Duration.zero, () {
      facility = Provider.of<FacilitiesProvider>(context, listen: false)
          .getFacility(widget.id);
      avaliableTime = Provider.of<BookingProvider>(context, listen: false)
          .avaliableTime(DateTime(year, month, day + 1).toString(), facility);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => selectDateAndTime(),
          child: Container(
            height: 270,
            width: 340,
            decoration: BoxDecoration(
              border: Border.all(
                color: ConstColors.borderCategory,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    imageWidget(),
                    detailsWidget(context),
                  ],
                ),
                favoirateWidget(),
                servicesWidget(context)
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }

  Widget detailsWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: widget.name.length > 18
                ? MediaQuery.of(context).size.width * 0.5
                : MediaQuery.of(context).size.width * 0.3,
            child: Text(
              widget.name,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
              softWrap: true,
            ),
          ),
          Row(
            children: [
              Text(
                '(${widget.voteCunt})${widget.voteAvg}',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              const Icon(Icons.star_border),
            ],
          )
        ],
      ),
    );
  }

  Widget imageWidget() {
    return SizedBox(
      height: 205,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        child: Image.network(
          widget.imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget favoirateWidget() {
    return Positioned(
      top: 13,
      left: 12,
      child: Container(
        height: 30,
        width: 30,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: GestureDetector(
            child: const Icon(Icons.favorite_border),
            onTap: () {
              print('Clicked');
            },
          ),
        ),
      ),
    );
  }

  //bottom right the icons widget
  Widget servicesWidget(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: context.locale.toString() == 'en' ? 0 : null,
      left: context.locale.toString() == 'en' ? null : 0,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: ConstColors.borderCategory,
            width: 1,
          ),
          borderRadius: BorderRadius.only(
            bottomRight: context.locale.toString() == 'en'
                ? const Radius.circular(10)
                : const Radius.circular(0),
            topLeft: context.locale.toString() == 'en'
                ? const Radius.circular(5)
                : const Radius.circular(0),
            topRight: context.locale.toString() == 'en'
                ? const Radius.circular(0)
                : const Radius.circular(5),
            bottomLeft: context.locale.toString() == 'en'
                ? const Radius.circular(0)
                : const Radius.circular(10),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 3),
          child: Row(
            children: const [
              Icon(Icons.slideshow),
              Icon(Icons.slow_motion_video),
            ],
          ),
        ),
      ),
    );
  }

  void selectDateAndTime() async {
    var duration = Provider.of<FacilitiesProvider>(context, listen: false)
        .getDuration(facility.belong);
    final year = DateTime.now().year;
    controller = widget.globalKey.currentState!.showBottomSheet(
      (context) => FractionallySizedBox(
        heightFactor: 0.85,
        child: Column(
          children: [
            helperLineWidget(),
            dateWidget(year, context),
            const Divider(
                //height: 150,
                ),
            if (avaliableTime.isNotEmpty)
              Text('The duration of each slot is $duration hour'),
            timeViewWidget(),
            if (reservation != null) conformButton(context)
          ],
        ),
      ),
      backgroundColor: ConstColors.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
        ),
      ),
    );
  }

  Widget conformButton(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    return SizedBox(
      height: mediaQuery.height > 880 ? 70 : 50,
      width: mediaQuery.height > 880 ? 400 : 300,
      child: ElevatedButton(
        onPressed: () {
          ///Save the filtering
          // Provider.of<BookingProvider>(context, listen: false)
          //     .addBookedTime(reservation!.date, reservation!);
          // Provider.of<ReservationsProvider>(context, listen: false)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => ConformationScreen(facility, reservation!),
            ),
          );
          setState(() {});
          //Navigator.of(context).pop();
        },
        child: const Text(
          'Next',
          style: TextStyle(
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

  Widget timeViewWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      height: 300,
      width: double.infinity,
      child: avaliableTime.isEmpty
          ? SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Weekend days',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    'No avaliable times',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              //physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (ctx, i) => Consumer<BookingProvider>(
                builder: (ctx, book, _) => timeWidget(
                  i,
                  book.bookedFacilities(avaliableTime[i].time,
                      avaliableTime[i].date, avaliableTime[i].item),
                ),
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 5,
                crossAxisSpacing: 10,
                //childAspectRatio: 3 / 3,
                //mainAxisExtent: 50,
              ),
              itemCount: avaliableTime.length,
              padding: const EdgeInsets.all(8),

              //shrinkWrap: true,
            ),
    );
  }

  Widget dateWidget(int year, BuildContext context) {
    int day = DateTime.now().day;
    int month = DateTime.now().month;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
      child: DateTimePicker(
        type: DateTimePickerType.date,
        dateMask: 'd MMM, yyyy',
        //Change this later to now
        initialValue: DateTime(year, month, day + 1).toString(),
        firstDate: DateTime(year, month, day + 1),
        lastDate: DateTime(year + 1),
        icon: const Icon(Icons.event),
        dateLabelText: 'Date',
        timeLabelText: "Hour",
        onChanged: (val) {
          avaliableTime = Provider.of<BookingProvider>(context, listen: false)
              .avaliableTime(val, facility);
          controller.setState!(() {});
        },
      ),
    );
  }

  Widget helperLineWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
      width: 25,
      margin: const EdgeInsets.only(top: 2),
      child: const SizedBox(height: 5),
    );
  }

  Widget timeWidget(int i, bool booked) {
    //int nextTime =
    int hour = avaliableTime[i].time.hour;
    String min =
        '${avaliableTime[i].time.minute != 0 ? avaliableTime[i].time.minute.toStringAsPrecision(2) : avaliableTime[i].time.minute.toString()}${avaliableTime[i].time.minute == 0 ? '0' : ''}';
    int nextHour =
        (avaliableTime[i].time.hour + avaliableTime[i].item.duration);
    String label = '$hour:$min - $nextHour:$min';
    return SizedBox(
      height: 20,
      width: 60,
      child: FilterChip(
        labelPadding: const EdgeInsets.symmetric(horizontal: 19),
        selectedColor: Colors.orangeAccent,
        backgroundColor:
            booked ? Colors.red : Color.fromARGB(255, 232, 236, 231),
        label: Text(
          ///Showing the time if min 0 add another 0
          ///Otherwise system will make it two digits
          label,
        ),
        onSelected: (isSelected) => selected(isSelected, avaliableTime[i]),
        selected: avaliableTime[i].isSelected[avaliableTime[i].date],
        showCheckmark: false,
      ),
    );
  }

  void selected(bool isSelected, Booking item) {
    bool booked = Provider.of<BookingProvider>(context, listen: false)
        .bookedFacilities(item.time, item.date, item.item);
    if (!booked) {
      //First selection
      if (reservation == null) {
        reservation = item;
        item.isSelected[item.date] = !item.isSelected[item.date];
        print('${reservation!.time.toString()} ${reservation!.date}');
      } else {
        //Get the previous selection to make it false
        var index = avaliableTime.indexWhere((e) {
          return e.time == reservation!.time;
        });
        avaliableTime[index].isSelected[avaliableTime[index].date] =
            !avaliableTime[index].isSelected[avaliableTime[index].date];

        //Save the new selection
        reservation = item;
        item.isSelected[item.date] = !item.isSelected[item.date];
        print('${reservation!.time.toString()} ${reservation!.date}');
      }
    }

    controller.setState!(() {});
  }
}
