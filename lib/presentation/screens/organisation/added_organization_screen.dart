import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class AddedOrganizationScreen extends StatefulWidget {
  const AddedOrganizationScreen({super.key});

  @override
  State<AddedOrganizationScreen> createState() =>
      _AddedOrganizationScreenState();
}

class _AddedOrganizationScreenState extends State<AddedOrganizationScreen> {
  @override
  Widget build(context) {
    return Scaffold(
        backgroundColor: bgColor,
        body: Stack(children: [
          // bg
          bGMainMini(),
          Column(children: [
            SizedBox(height: 20.h),
            Align(
                alignment: Alignment.topLeft,
                child: goBack(() {
                  Navigator.of(context).pop();
                })),
            Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(translation(context).organisation,
                    style: const TextStyle(
                        color: brightTextColor,
                        fontSize: 24,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold))),
            const SizedBox(height: 40),
            (UserDetailsDataStore.getUserOrganizations!.isNotEmpty)
                ? Expanded(child: _buildBodyContentWidget())
                : Expanded(child: _buildNoOrganizationWidget())
          ])
        ]));
  }

  // show multiple organization
  Widget _buildBodyContentWidget() {
    return SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: UserDetailsDataStore.getUserOrganizations!
                .map((organization) => Card(
                    color: white,
                    margin: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    child: ListTile(
                        title: Column(children: [
                          Text(organization.name!,
                              style: const TextStyle(
                                  color: darkTextColor,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold)),
                          Text(organization.email!,
                              style: const TextStyle(
                                  color: darkTextColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.normal))
                        ]),
                        subtitle: Text(organization.address!,
                            style: const TextStyle(
                                color: darkTextColor,
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal),
                            textAlign: TextAlign.center))))
                .toList()));
  }

  // no organization widget
  Widget _buildNoOrganizationWidget() {
    return Container(
        width: 350.0,
        height: 300.0,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: loadingOpacityBrightColor,
        ),
        child: Column(children: [
          Text(translation(context).noOrganisation,
              style: const TextStyle(
                  fontSize: 16.0, fontWeight: FontWeight.normal),
              textAlign: TextAlign.center),
          sizedBoxHeight_10(),
          // const Text(
          //   'Login after joining any one Organisation.',
          //   style: TextStyle(fontSize: 16.0, color: greyTextColor),
          //   textAlign: TextAlign.center,
          // ),
          sizedBoxHeight_20(),
          _buildGoBackBtn()
        ]));
  }

  // submit btn
  Widget _buildGoBackBtn() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: greenButtonColor,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(23.0),
            )),
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(translation(context).goBack,
            style: const TextStyle(
                color: brightTextColor,
                fontSize: 18.0,
                fontWeight: FontWeight.bold)));
  }
}
