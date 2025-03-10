import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/data/model/user_pending_scheduled_shift.dart';
import 'package:tasko/presentation/routes/pages_name.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  SharedPreferences? sharedPreferences;

  ClockBloc? _clockBloc;

  // Position? _currentPosition;
  AnimationController? _animationController;

  bool serviceEnabled = false;
  String clockInText = '';
  String clockOutText = '';
  String? organizationId;
  String startAt = '';
  String finishAt = '';
  String? shiftId, userName = FirebaseAuth.instance.currentUser!.displayName;
  DateTime currentDateTime = DateTime.now();
  DateTime? inDateTime;
  DateTime? outDateTime;
  int? shiftHours;
  int? shiftMinutes;
  List<UserPendingScheduledShift>? pendingList;
  bool? isShiftAvailable;
  String clockOutReason = '';
  @override
  void initState() {
    organizationId = UserDetailsDataStore.getSelectedOrganizationId;
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 5000), vsync: this);
    getSharedPreferences();
    _clockBloc = BlocProvider.of<ClockBloc>(context);
    netWorkStatusCheck();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    clockInText = translation(context).clockIn;
    clockOutText = translation(context).clockOut;
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  netWorkStatusCheck() async {
    await connectivityCheck().then((internet) {
      if (!internet && mounted) {
        showModal(context, () {
          getTodayScheduledShift();
        });
      } else {
        getTodayScheduledShift();
      }
    });
  }

  getTodayScheduledShift() {
    _clockBloc!.add(GetTodayScheduledShift(organizationId!));
    _clockBloc!.add(GetUserPendingScheduledShifts(
        organizationId!, UserDetailsDataStore.getCurrentFirebaseUserID!));
  }

  void getSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
    try {
      bool userStatus = sharedPreferences!.getBool('userStatus')!;
      if (userStatus) {
        UserDetailsDataStore.setClockIn = userStatus;
      } else {
        UserDetailsDataStore.setClockOut = userStatus;
      }
      setState(() {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [buildBackgroundWidget(), _buildBodyContentWidget()]);
  }

  Widget _buildBodyContentWidget() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(children: [
          SizedBox(
            child: // user profile row
                BlocBuilder<ClockBloc, ClockState>(
                    bloc: _clockBloc,
                    builder: (context, state) {
                      String? firstName = UserDetailsDataStore.getUserFirstName;
                      String? lastName = UserDetailsDataStore.getUserLastName;
                      return userRowWidget(firstName!, lastName!,
                          UserDetailsDataStore.getUserStatus!, false, context);
                    }),
          ),
          // shift container
          Padding(
              padding: EdgeInsets.only(top: 50.h, bottom: 4.h),
              child: Column(children: [
                Container(
                    padding: EdgeInsets.only(
                        top: 0.h, left: 15.w, bottom: 8.h, right: 10.w),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: primaryColor.withValues(alpha: .1)),
                    child: Column(children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Padding(
                                    padding: UserDetailsDataStore
                                                .getUserOrganizations!.length >
                                            1
                                        ? EdgeInsets.zero
                                        : const EdgeInsets.only(
                                            top: 10, bottom: 10),
                                    child: Text(
                                        UserDetailsDataStore
                                                .getSelectedOrganizationName ??
                                            'Organisation Name',
                                        style: const TextStyle(
                                            color: darkTextColor,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w600)))),
                            SizedBox(width: 5.w),
                            UserDetailsDataStore.getUserOrganizations!.length >
                                    1
                                ? OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            width: 1.0, color: primaryColor),
                                        minimumSize: Size.zero,
                                        padding: EdgeInsets.only(
                                            left: 8.w, right: 8.w),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(23.0))),
                                    onPressed: () {
                                      if (UserDetailsDataStore.getUserStatus!) {
                                        showAlert(
                                            context,
                                            translation(context)
                                                .clockoutOrganisation);
                                      } else {
                                        sharedPreferences!.setBool(
                                            'isNavigateFromDashboard', true);
                                        Navigator.pushNamed(
                                            context,
                                            PageName
                                                .organizationSelectionScreen);
                                      }
                                    },
                                    child: Text('OrgList',
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold)))
                                : const Text(''),
                          ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(children: [
                              BlocListener<ClockBloc, ClockState>(
                                  bloc: _clockBloc,
                                  listener: (context, state) {
                                    if (state
                                        is GetTodayScheduledShiftSuccess) {
                                      isShiftAvailable =
                                          state.shiftData != null;
                                      if (isShiftAvailable!) {
                                        var startTime =
                                            state.shiftData!.shiftStartTiming;
                                        var endTime =
                                            state.shiftData!.shiftEndTiming;
                                        var inTime = DateTime.parse(
                                                ConvertionUtil
                                                    .convertToUTCWithZ(
                                                        startTime!))
                                            .toLocal();
                                        var outTime = DateTime.parse(
                                                ConvertionUtil
                                                    .convertToUTCWithZ(
                                                        endTime!))
                                            .toLocal();
                                        inDateTime = DateTime(
                                            currentDateTime.year,
                                            currentDateTime.month,
                                            currentDateTime.day,
                                            inTime.hour,
                                            inTime.minute);
                                        outDateTime = DateTime(
                                            currentDateTime.year,
                                            currentDateTime.month,
                                            currentDateTime.day,
                                            outTime.hour,
                                            outTime.minute);
                                        startAt = ConvertionUtil
                                            .convertLocalTimeFromString(
                                                ConvertionUtil
                                                    .convertToUTCWithZ(
                                                        startTime));
                                        finishAt = ConvertionUtil
                                            .convertLocalTimeFromString(
                                                ConvertionUtil
                                                    .convertToUTCWithZ(
                                                        endTime));
                                        UserDetailsDataStore.getUserStatus! &&
                                                currentDateTime.compareTo(
                                                        outDateTime!) >=
                                                    0
                                            ? offTimerDuration()
                                            : getTimerDuration();
                                        shiftId = state.shiftData!.id;
                                      }
                                    } else if (state is ClockIn) {
                                      _animationController!.repeat();
                                    } else if (state is ClockOut) {
                                      _animationController!.reset();
                                    } else if (state
                                        is GetUserPendingScheduledShiftsSuccess) {
                                      pendingList = state.pendingScheduledShift;
                                    } else if (state
                                        is GetUserPendingScheduledShiftsFailed) {
                                      showAlertSnackBar(context,
                                          state.errorMessage, AlertType.error);
                                    }
                                  },
                                  child: BlocBuilder<ClockBloc, ClockState>(
                                      bloc: _clockBloc,
                                      builder: (context, state) {
                                        if (state is ClockLoading) {
                                          return const CircularProgressIndicator(
                                              color: primaryColor);
                                        } else {
                                          if (UserDetailsDataStore
                                              .getUserStatus!) {
                                            return Align(
                                                alignment: Alignment.centerLeft,
                                                child: outDateTime != null
                                                    ? Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                            _buildButtonClockInAndOut(
                                                              clockOutText,
                                                              () {
                                                                final durationDifference =
                                                                    currentDateTime
                                                                        .difference(
                                                                            outDateTime!)
                                                                        .inMinutes
                                                                        .abs();

                                                                if (durationDifference <=
                                                                    10) {
                                                                  clockOutReason =
                                                                      "Shift completed";
                                                                  checkGeoLocationConfiguration(
                                                                      clockOutText);
                                                                } else {
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return ClockOutAlertDialog(
                                                                        onTap:
                                                                            () {
                                                                          checkGeoLocationConfiguration(
                                                                              clockOutText);
                                                                        },
                                                                        onReasonSelected:
                                                                            (String
                                                                                reason) {
                                                                          setState(
                                                                              () {
                                                                            clockOutReason =
                                                                                reason;
                                                                          });
                                                                        },
                                                                      );
                                                                    },
                                                                  );
                                                                }
                                                              },
                                                              false,
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            buildShiftTime()
                                                          ])
                                                    : const CircularProgressIndicator(
                                                        color: primaryColor));
                                          } else {
                                            return Align(
                                                alignment: Alignment.centerLeft,
                                                child: ((isShiftAvailable !=
                                                                null &&
                                                            isShiftAvailable!) ||
                                                        inDateTime != null)
                                                    ? Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                            _buildButtonClockInAndOut(
                                                                clockInText,
                                                                () async {
                                                              if (currentDateTime
                                                                          .compareTo(
                                                                              inDateTime!) >=
                                                                      0 &&
                                                                  outDateTime!.compareTo(
                                                                          currentDateTime) ==
                                                                      1) {
                                                                await getTimerDuration();
                                                                checkGeoLocationConfiguration(
                                                                    clockInText);
                                                              } else {
                                                                showAlert(
                                                                    context,
                                                                    translation(
                                                                            context)
                                                                        .shiftNotStarted);
                                                              }
                                                            }, false),
                                                            SizedBox(
                                                                height: 10.h),
                                                            buildShiftTime()
                                                          ])
                                                    : isShiftAvailable !=
                                                                null &&
                                                            !isShiftAvailable!
                                                        ? Text(
                                                            translation(context)
                                                                .noShiftsFound)
                                                        : const CircularProgressIndicator(
                                                            color:
                                                                primaryColor));
                                          }
                                        }
                                      }))
                            ]),
                            BlocBuilder<ClockBloc, ClockState>(
                              bloc: _clockBloc,
                              builder: (context, state) {
                                return UserDetailsDataStore.getUserStatus!
                                    ? shiftHours != null && shiftMinutes != null
                                        ? shiftHours == 0 && shiftMinutes == 0
                                            ? const SizedBox()
                                            : SlideCountdown(
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                separatorStyle: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                duration: Duration(
                                                    hours: shiftHours!,
                                                    minutes: shiftMinutes!),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 5,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xffF2F4FF),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(5)),
                                                ),
                                              )
                                        : const CircularProgressIndicator(
                                            color: primaryColor)
                                    : const SizedBox();
                              },
                            ),
                            RotationTransition(
                                turns: Tween(begin: 0.0, end: 1.0)
                                    .animate(_animationController!),
                                child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: Image.asset(
                                        'assets/icons/time_loader.png',
                                        color: primaryColor)))
                          ]),
                      sizedBoxHeight_10(),
                      BlocBuilder<ClockBloc, ClockState>(
                          bloc: _clockBloc,
                          builder: (context, state) {
                            return Align(
                                alignment: Alignment.centerLeft,
                                child: _buildScheduleShiftButton());
                          })
                    ])),
                SizedBox(height: 10.h)
              ])),
          Expanded(child: FeedWidget(onBack: () {}))
        ]));
  }

  Widget showDontDashBoard(String nextShiftTime) {
    return const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, children: []);
  }

  Widget clockInDisableButton(String val) {
    return _buildButtonClockInAndOut(clockInText, () async {
      _clockBloc!.add(ClockInDisableEvent());
      await showAlert(
          context,
          val == 'distance'
              ? translation(context).organisationRadius
              : translation(context).enableServices);
    }, true);
  }

  Widget _buildScheduleShiftButton() {
    return InkWell(
        onTap: () async {
          var result = await Navigator.pushNamed(
              context, PageName.scheduledShiftUserScreen);
          if (result == true) {
            getTodayScheduledShift();
          }
        },
        child: Container(
            padding:
                EdgeInsets.only(left: 16.w, top: 2.h, right: 16.w, bottom: 2.h),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(65.0),
            ),
            child: Text(
                pendingList != null && pendingList!.isNotEmpty
                    ? '${translation(context).schedule} (${pendingList!.first.pendingShifts!.length.toString()}*)'
                    : translation(context).schedule,
                style: TextStyle(
                    fontSize: 14.sp,
                    color: brightTextColor,
                    fontWeight: FontWeight.w500))));
  }

  Widget _buildButtonClockInAndOut(String title, onTap, isDisable) {
    return InkWell(
        onTap: () {
          onTap();
        },
        child: Container(
            padding:
                EdgeInsets.only(left: 16.w, top: 2.h, right: 16.w, bottom: 2.h),
            decoration: BoxDecoration(
              color: !isDisable ? primaryColor : lightIconColor,
              borderRadius: BorderRadius.circular(65.0),
            ),
            child: Text(title,
                style: TextStyle(
                    fontSize: 14.sp,
                    color: brightTextColor,
                    fontWeight: FontWeight.w500))));
  }

  Widget buildShiftTime() {
    return Container(
        margin: EdgeInsets.only(right: 8.w),
        child: Text(
            UserDetailsDataStore.getUserStatus!
                ? '${translation(context).finishAt} $finishAt'
                : '${translation(context).startAt} $startAt',
            style: TextStyle(
                fontSize: 14.sp,
                color: darkTextColor,
                fontWeight: FontWeight.bold)));
  }

  checkGeoLocationConfiguration(clockInOrClockOut) async {
    if (UserDetailsDataStore.getSelectedOrganizationGeoLocationEnable != null &&
        UserDetailsDataStore.getSelectedOrganizationGeoLocationEnable!) {
      bool hasPermission = await getLocationEnableStatus();
      if (hasPermission) {
        bool? result =
            await getLocationDistanceBetweenUserCurrentLocationAndOrganizationLocation();
        if (result != null && result) {
          _clockInOrClockOut(clockInOrClockOut);
        } else {
          // ignore: use_build_context_synchronously
          await showAlert(context, translation(context).organisationRadius);
        }
      }
    } else {
      _clockInOrClockOut(clockInOrClockOut);
    }
  }

  _clockInOrClockOut(clockInOrClockOut) {
    if (clockInOrClockOut == clockInText) {
      _doClockIn();
    } else {
      _doClockOut();
    }
  }

  _doClockIn() async {
    var userId = FirebaseAuth.instance.currentUser!.uid;
    var attendanceRecordId = "";
    _clockBloc!.add(ClockInEvent(
        userId,
        shiftId!,
        UserDetailsDataStore.getSelectedOrganizationId!,
        attendanceRecordId,
        clockOutReason));
  }

  _doClockOut() async {
    var userId = FirebaseAuth.instance.currentUser!.uid;
    var attendanceRecordId = UserDetailsDataStore.getCurrentClockInId!;
    _clockBloc!.add(ClockOutEvent(
        userId,
        shiftId!,
        UserDetailsDataStore.getSelectedOrganizationId!,
        attendanceRecordId,
        clockOutReason));
  }

  Future<bool> getLocationEnableStatus() async {
    final hasPermission = await handleLocationPermission();

    return hasPermission;
  }

  Future<bool> handleLocationPermission() async {
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && mounted) {
      showAlert(context, translation(context).enableServices);
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied && mounted) {
        showAlert(context, translation(context).locationPermissions);
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever && mounted) {
      showAlert(context, translation(context).permanentlyDenied);

      return false;
    }
    return true;
  }

  Future<bool>?
      getLocationDistanceBetweenUserCurrentLocationAndOrganizationLocation() async {
    bool aroundDistanceRadius = true;
    if (UserDetailsDataStore.getSelectedOrganizationRadius == null) {
      return aroundDistanceRadius;
    }
    double? distance;

    await Geolocator.getCurrentPosition(
            locationSettings:
                const LocationSettings(accuracy: LocationAccuracy.high))
        .then((Position position) {
      // _currentPosition = position;
      // double lat1 =
      //     double.parse(UserDetailsDataStore.getSelectedOrganizationLatitude!);
      // double lon1 =
      //     double.parse(UserDetailsDataStore.getSelectedOrganizationLongitude!);
      // double lat2 = _currentPosition!.latitude;
      // double lon2 = _currentPosition!.longitude;

      // distance = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);

      distance = 50;

      aroundDistanceRadius = distance! <
          double.parse(UserDetailsDataStore.getSelectedOrganizationRadius!);
    }).catchError((e) {
      debugPrint(e);
    });
    return aroundDistanceRadius;
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    var totalDistance = (12742 * asin(sqrt(a))) * 1000;
    return totalDistance;
  }

  getTimerDuration() {
    if (UserDetailsDataStore.getUserStatus!) {
      _animationController!.repeat();
    }
    DateTime now = DateTime.now();
    Duration dif = outDateTime!.difference(now);
    shiftHours = dif.inHours;
    shiftMinutes = dif.inMinutes.remainder(60) + 1;
    setState(() {});
  }

  offTimerDuration() {
    _animationController!.reset();
    shiftHours = 0;
    shiftMinutes = 0;
    setState(() {});
  }
}
