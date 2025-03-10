import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/scheduled_shift.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class ScheduledShiftUserScreen extends StatefulWidget {
  const ScheduledShiftUserScreen({super.key});

  @override
  State<ScheduledShiftUserScreen> createState() =>
      _ScheduledShiftUserScreenState();
}

class _ScheduledShiftUserScreenState extends State<ScheduledShiftUserScreen> {
  AdminBloc? adminBloc;
  List<ScheduledShift>? scheduledShiftList = [];
  bool? isShiftAccepted;
  int? updatedStatusIndex;
  bool isShiftStatusUpdated = false, isAllShiftsAccepted = true;

  @override
  void initState() {
    adminBloc = BlocProvider.of<AdminBloc>(context);
    getUserScheduledShift();
    super.initState();
  }

  getUserScheduledShift() {
    adminBloc!.add(GetUserScheduledShifts(
        UserDetailsDataStore.getSelectedOrganizationId!,
        UserDetailsDataStore.getCurrentFirebaseUserID!));
  }

  @override
  Widget build(context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) {
            return;
          }
          Navigator.of(context).pop(isShiftStatusUpdated);
          return Future.value();
        },
        child: Scaffold(
            backgroundColor: bgColor,
            body: Stack(children: [
              bGMainMini(),
              Column(children: [
                SizedBox(height: 20.h),
                Align(
                    alignment: Alignment.topLeft,
                    child: goBack(() =>
                        {Navigator.of(context).pop(isShiftStatusUpdated)})),
                Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(translation(context).scheduledShifts,
                        style: const TextStyle(
                            color: brightTextColor,
                            fontSize: 24,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold))),
                const SizedBox(height: 40),
                Expanded(
                    child: BlocListener(
                        bloc: adminBloc,
                        listener: (context, state) {
                          if (state is GetUserScheduledShiftsSuccess) {
                            scheduledShiftList = state.scheduledShifts
                                .where((element) => element.isDeleted == false)
                                .toList();
                            isAllShiftsAccepted = scheduledShiftList!
                                .every((shift) => shift.status != "Pending");
                          } else if (state is GetUserScheduledShiftsFailed) {
                            showAlertSnackBar(
                                context, state.errorMessage, AlertType.error);
                          } else if (state is ShiftAcceptOrRejectSuccess) {
                            Navigator.pop(context);
                            isShiftStatusUpdated = true;
                            setState(() {
                              if (isShiftAccepted!) {
                                scheduledShiftList![updatedStatusIndex!]
                                    .status = 'Accepted';
                              } else {
                                scheduledShiftList![updatedStatusIndex!]
                                    .status = 'Rejected';
                              }
                            });
                          } else if (state is ShiftAcceptOrRejectFailed) {
                            Navigator.pop(context);
                            showAlertSnackBar(
                                context, state.errorMessage, AlertType.error);
                          } else if (state
                              is AcceptAllPendingScheduledShiftsSuccess) {
                            showAlertSnackBar(
                                context,
                                translation(context)
                                    .acceptedAllScheduledShiftsSuccess,
                                AlertType.success);
                            getUserScheduledShift();
                          } else if (state
                              is AcceptAllPendingScheduledShiftsFailed) {
                            showAlertSnackBar(
                                context, state.errorMessage, AlertType.error);
                          }
                        },
                        child: BlocBuilder(
                            bloc: adminBloc,
                            builder: (context, state) {
                              if (state is GetUserScheduledShiftsLoading) {
                                return const Center(child: Loading());
                              } else {
                                return SingleChildScrollView(
                                    child: Column(children: [
                                  scheduledShiftList != null &&
                                          scheduledShiftList!.isNotEmpty &&
                                          !isAllShiftsAccepted
                                      ? _buildAcceptAllButton()
                                      : const SizedBox(),
                                  _buildBodyContentWidget()
                                ]));
                              }
                            })))
              ])
            ])));
  }

  Widget _buildAcceptAllButton() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          InkWell(
              onTap: () {
                adminBloc!.add(AcceptAllPendingScheduledShifts(
                    UserDetailsDataStore.getCurrentFirebaseUserID!,
                    UserDetailsDataStore.getSelectedOrganizationId!));
              },
              child: Container(
                  padding: const EdgeInsets.only(
                      left: 16, top: 8, right: 16, bottom: 8),
                  decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(65.0)),
                  child: Text(translation(context).acceptAll,
                      style: const TextStyle(
                          fontSize: 14,
                          color: brightTextColor,
                          fontWeight: FontWeight.w500))))
        ]));
  }

  Widget _buildAcceptButton(String scheduledShiftId, int updatedIndex) {
    return InkWell(
        onTap: () {
          progress(context);
          isShiftAccepted = true;
          updatedStatusIndex = updatedIndex;
          adminBloc!.add(ShiftAcceptOrReject(scheduledShiftId, 'Accepted'));
        },
        child: Container(
          padding:
              const EdgeInsets.only(left: 10, top: 2, right: 10, bottom: 2),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Text(
            translation(context).accept,
            style: const TextStyle(
                fontSize: 14,
                color: brightTextColor,
                fontWeight: FontWeight.w500),
          ),
        ));
  }

  _doReject(String scheduledShiftId, int updatedIndex) {
    progress(context);
    isShiftAccepted = false;
    updatedStatusIndex = updatedIndex;
    adminBloc!.add(ShiftAcceptOrReject(scheduledShiftId, 'Rejected'));
  }

  Widget _buildRejectButton(String scheduledShiftId, int updatedIndex) {
    return InkWell(
        onTap: () {
          showAlertWithAction(
              context: context,
              title: translation(context).reject,
              content: translation(context).rejectMessage,
              onPress: () {
                _doReject(scheduledShiftId, updatedIndex);
              });
        },
        child: Container(
          padding:
              const EdgeInsets.only(left: 10, top: 2, right: 10, bottom: 2),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Text(
            translation(context).reject,
            style: const TextStyle(
                fontSize: 14,
                color: brightTextColor,
                fontWeight: FontWeight.w500),
          ),
        ));
  }

  // show multiple organization
  Widget _buildBodyContentWidget() {
    return SingleChildScrollView(
      child: scheduledShiftList != null && scheduledShiftList!.isNotEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: scheduledShiftList!
                  .map((shift) => Card(
                        color: white,
                        margin: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        child: ListTile(
                            title: Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                          child: Column(
                            children: [
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      '${shift.userShift!.organizationDetail!.name} - ${shift.userShift!.shiftDetail!.shiftName}',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold))),
                              SizedBox(height: 5.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(ConvertionUtil
                                      .convertLocalDateMonthFromString(
                                          shift.date.toString())),
                                  const SizedBox(width: 5),
                                  Row(
                                    children: [
                                      Text(
                                        ConvertionUtil
                                            .convertLocalTimeFromString(
                                                ConvertionUtil
                                                    .convertToUTCWithZ(shift
                                                        .userShift!
                                                        .shiftDetail!
                                                        .shiftStartTiming)),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const Text('-'),
                                      Text(
                                        ConvertionUtil
                                            .convertLocalTimeFromString(
                                                ConvertionUtil
                                                    .convertToUTCWithZ(shift
                                                        .userShift!
                                                        .shiftDetail!
                                                        .shiftEndTiming)),
                                        style: const TextStyle(fontSize: 16),
                                      )
                                    ],
                                  ),
                                  // const SizedBox(
                                  //   width: 10,
                                  // ),
                                  // InkWell(
                                  //   onTap: () {},
                                  //   child: const Icon(
                                  //     Icons.check_box_outlined,
                                  //     color: Colors.green,
                                  //   ),
                                  // ),
                                  // const SizedBox(
                                  //   width: 5,
                                  // ),
                                  // InkWell(
                                  //     onTap: () {},
                                  //     child: const Icon(
                                  //       Icons.close_outlined,
                                  //       color: Colors.red,
                                  //     ))
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              shift.status == 'Pending'
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        _buildAcceptButton(shift.id!,
                                            scheduledShiftList!.indexOf(shift)),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        _buildRejectButton(shift.id!,
                                            scheduledShiftList!.indexOf(shift))
                                      ],
                                    )
                                  : Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        '${shift.status}',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: shift.status == 'Accepted'
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.bold),
                                      ))
                            ],
                          ),
                        )),
                      ))
                  .toList(),
            )
          : _buildNoUsersWidget(),
    );
  }

  // no users widget
  Widget _buildNoUsersWidget() {
    return Container(
      width: 350.0,
      height: 300.0,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: loadingOpacityBrightColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            translation(context).noScheduleFound,
            style:
                const TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
