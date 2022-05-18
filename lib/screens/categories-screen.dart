import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//Colors
import '../constants/colors.dart';

//Provider
import '../provider/facilities.dart';

//Widgets
import '../widgets/categoryFacilityWidget.dart';

class CategoryScreen extends StatelessWidget {
  static const String routeName = 'categoryScreen';
  final GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();
  CategoryScreen({Key? key}) : super(key: key);
  List<Facilities> facilities = [];

  void goBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  void goHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/');
  }

  Future<void> _future(BuildContext context, String label) async {
    facilities = await Provider.of<FacilitiesProvider>(context, listen: false)
        .getFacilities(context, label);
  }

  @override
  Widget build(BuildContext context) {
    final label = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      key: globalKey,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
        child: FutureBuilder(
          future: _future(context, label),
          builder: (ctx, snapshoot) =>
              snapshoot.connectionState == ConnectionState.waiting
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Column(
                      children: [
                        functionalityOfWidget(context, label),
                        const Divider(
                          color: Colors.grey,
                        ),
                        // const SizedBox(
                        //   height: 20,
                        // ),
                        facilities.isEmpty
                            ? const Center(
                                child: Text(
                                  'Sorry. No facilities',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : Expanded(
                                child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemBuilder: (ctx, i) => CategoryFacility(
                                    id: facilities[i].id,
                                    imageUrl: facilities[i].imageUrl,
                                    name: facilities[i].name,
                                    voteCunt: facilities[i].voteCoun,
                                    globalKey: globalKey,
                                    voteAvg: facilities[i].voteAvg,
                                  ),
                                  itemCount: facilities.length,
                                ),
                              ),
                      ],
                    ),
        ),
      ),
    );
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
