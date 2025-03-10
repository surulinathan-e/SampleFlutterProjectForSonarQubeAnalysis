import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/organization.dart';
import 'package:tasko/data/model/shift.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/presentation/routes/pages_name.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class ShiftListScreen extends StatefulWidget {
  const ShiftListScreen({super.key});

  @override
  State<ShiftListScreen> createState() => _ShiftListScreenState();
}

class _ShiftListScreenState extends State<ShiftListScreen> {
  AdminBloc? adminBloc;

  String? selectedOrganization;
  Organization? selectedOrganizationDetails;
  List<Organization>? organizations;
  List<Shift>? shiftList = [];
  int page = 1, limit = 10;
  ScrollController? scrollController;
  bool isLastShift = false;

  @override
  void initState() {
    super.initState();
    adminBloc = BlocProvider.of<AdminBloc>(context);
    scrollController = ScrollController();
    organizations = UserDetailsDataStore.getUserOrganizations!;
    selectedOrganization = UserDetailsDataStore.getSelectedOrganizationId;
    selectedOrganizationDetails = organizations!
        .singleWhere((element) => element.id == selectedOrganization);
    scrollController!.addListener(loadMore);
    readData();
  }

  readData() {
    adminBloc!.add(GetOrganizationShifts(selectedOrganization!, page, limit));
  }

  loadMore() {
    double maxScroll = scrollController!.position.maxScrollExtent;
    double offset = scrollController!.offset;
    bool outOfRange = scrollController!.position.outOfRange;
    if (offset >= maxScroll && !outOfRange && !isLastShift) {
      page = page + 1;
      readData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bgColor,
        floatingActionButton: FloatingActionButton(
            backgroundColor: primaryColor,
            onPressed: () async {
              var result = await Navigator.pushNamed(
                  context, PageName.createShiftScreen);
              if (result == true) {
                // adminBloc!.add(GetOrganizationShifts(selectedOrganization!));
                page = 1;
                readData();
              }
            },
            child: const Icon(Icons.add, color: white)),
        resizeToAvoidBottomInset: false,
        body: Stack(children: [
          bGMainMini(),
          BlocListener<AdminBloc, AdminState>(
              bloc: adminBloc,
              listener: (context, state) {
                if (state is GetOrganizationShiftsSuccess) {
                  if (page == 1) {
                    isLastShift = state.shifts.isEmpty;
                    shiftList = state.shifts;
                  } else {
                    isLastShift = state.shifts.isEmpty;
                    shiftList!.addAll(state.shifts);
                  }
                } else if (state is GetOrganizationShiftsFailed) {
                  showAlertSnackBar(
                      context, state.errorMessage, AlertType.error);
                }
              },
              child: _buildBodyContentWidget())
        ]));
  }

  Widget _buildBodyContentWidget() {
    return Column(children: [
      SizedBox(height: 20.h),
      Align(
        alignment: Alignment.topLeft,
        child: goBack(() => Navigator.of(context).pop()),
      ),
      Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(translation(context).organisationShifts,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600))),
      sizedBoxHeight_20(),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: BlocBuilder<AdminBloc, AdminState>(
              bloc: adminBloc,
              builder: (context, state) {
                if (state is GetOrganizationShiftsLoading) {
                  return Padding(
                      padding: EdgeInsets.symmetric(vertical: 200.w),
                      child: const Loading());
                } else {
                  return Column(children: [
                    sizedBoxHeight_20(),
                    _buildOrganizationWidget(),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.65,
                        child: SingleChildScrollView(
                            controller: scrollController,
                            child: (shiftList != null && shiftList!.isNotEmpty)
                                ? _buildShiftWidget(context)
                                : _buildEmptyListWidget()))
                  ]);
                }
              }))
    ]);
  }

  _buildEmptyListWidget() {
    return Padding(
        padding: const EdgeInsets.only(top: 150),
        child: Center(
            child: Text(translation(context).noShiftsFound,
                style: const TextStyle(fontSize: 16))));
  }

  Widget _buildOrganizationWidget() {
    return DropdownButtonFormField(
        hint: Text(translation(context).selectOrganisation),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: grayBorderColor, width: 2),
            borderRadius: BorderRadius.circular(25.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(color: darkBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(color: darkBorderColor),
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        dropdownColor: Colors.white,
        value: selectedOrganization,
        onChanged: (String? newValue) {
          shiftList!.clear();
          page = 1;
          adminBloc!.add(GetOrganizationShifts(newValue!, page, limit));
          setState(() {
            selectedOrganization = newValue;
            selectedOrganizationDetails =
                organizations!.singleWhere((element) => element.id == newValue);
          });
        },
        items: organizations!
            .map((organization) => DropdownMenuItem(
                value: "${organization.id}",
                child: Text("${organization.name}")))
            .toList());
  }

  _buildShiftWidget(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 0),
        child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: shiftList!.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildShiftItemWidget(shiftList![index], index);
            }));
  }

  Widget _buildShiftItemWidget(Shift shiftDetail, int index) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, PageName.assignShiftUserScreen,
            arguments: {
              'shift': shiftDetail,
              'organization': selectedOrganizationDetails
            });
      },
      child: shiftList != null && shiftList!.isNotEmpty
          ? Card(
              color: white,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 10),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                      shiftDetail.shiftName != null &&
                              shiftDetail.shiftName!.isNotEmpty
                          ? shiftDetail.shiftName!
                          : 'Shift ${index + 1}',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  subtitle: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          color: bgColor),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 5.0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                      '${translation(context).shiftStartDate} : ',
                                      style: const TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600)),
                                  Text(
                                      shiftDetail.shiftStartDate != null &&
                                              shiftDetail
                                                  .shiftStartDate!.isNotEmpty
                                          ? ConvertionUtil
                                              .convertLocalDateMonthYearString(
                                                  shiftDetail.shiftStartDate ??
                                                      '')
                                          : '--',
                                      style: const TextStyle(
                                          color: greyTextColor, fontSize: 14.0))
                                ]),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    '${translation(context).shiftEndDate} : ',
                                    style: const TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                      shiftDetail.shiftEndDate != null &&
                                              shiftDetail
                                                  .shiftEndDate!.isNotEmpty
                                          ? ConvertionUtil
                                              .convertLocalDateMonthYearString(
                                                  shiftDetail.shiftEndDate ??
                                                      '')
                                          : '--',
                                      style: const TextStyle(
                                          color: greyTextColor, fontSize: 14.0))
                                ]),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('${translation(context).startTime} : ',
                                      style: const TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600)),
                                  Text(
                                      shiftDetail.shiftStartTiming != null &&
                                              shiftDetail
                                                  .shiftStartTiming!.isNotEmpty
                                          ? ConvertionUtil
                                              .convertLocalTimeFromString(
                                                  ConvertionUtil
                                                      .convertToUTCWithZ(
                                                          shiftDetail
                                                              .shiftStartTiming))
                                          : '--',
                                      style: const TextStyle(
                                          color: greyTextColor, fontSize: 14.0))
                                ]),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('${translation(context).endTime} : ',
                                      style: const TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600)),
                                  Text(
                                      shiftDetail.shiftEndTiming != null &&
                                              shiftDetail
                                                  .shiftEndTiming!.isNotEmpty
                                          ? ConvertionUtil
                                              .convertLocalTimeFromString(
                                                  ConvertionUtil
                                                      .convertToUTCWithZ(
                                                          shiftDetail
                                                              .shiftEndTiming))
                                          : '--',
                                      style: const TextStyle(
                                          color: greyTextColor, fontSize: 14.0))
                                ])
                          ])),
                  trailing: PopupMenuButton(
                    color: bgColor,
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(
                            translation(context).edit,
                            style: const TextStyle(fontSize: 13.0),
                          ),
                          onTap: () async {
                            var result = await Navigator.pushNamed(
                                context, PageName.createShiftScreen,
                                arguments: shiftDetail);
                            if (result == true) {
                              page = 1;
                              readData();
                              // adminBloc!.add(
                              //     GetOrganizationShifts(selectedOrganization!));
                            }
                          },
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            translation(context).delete,
                            style: const TextStyle(fontSize: 13.0),
                          ),
                          onTap: () async {
                            String shiftId = shiftDetail.id!;
                            String shiftName = shiftDetail.shiftName!;
                            var result = await showDialog(
                              context: context,
                              builder: (context) => DeleteShiftDialog(
                                  shiftId: shiftId, shiftName: shiftName),
                            );
                            if (result == true) {
                              page = 1;
                              readData();
                              // adminBloc!.add(
                              //     GetOrganizationShifts(selectedOrganization!));
                            }
                          },
                        ),
                      ];
                    },
                  ),
                ),
              ))
          : _buildEmptyListWidget(),
    );
  }
}
