import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/app_config.dart';
import 'package:tasko/data/model/attendance_history.dart';
import 'package:tasko/data/model/organization.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/presentation/routes/pages_name.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class OrganizationSelectionScreen extends StatefulWidget {
  const OrganizationSelectionScreen({super.key});

  @override
  State<OrganizationSelectionScreen> createState() =>
      _OrganizationSelectionScreenState();
}

class _OrganizationSelectionScreenState
    extends State<OrganizationSelectionScreen> {
  List<Organization>? organizationList;
  SharedPreferences? sharedPreferences;
  UserBloc? _userBloc;
  AttendanceHistroy? attendanceHistroy;
  List<Organization>? orgList;
  String clockInOrganizationName = '';
  AppConfig? appConfigDetail;

  @override
  void initState() {
    setInstance();
    _userBloc = BlocProvider.of<UserBloc>(context);
    _userBloc!.add(ReadUserOrganizationEvent());
    getAppConfig();
    super.initState();
  }

  @override
  void dispose() {
    sharedPreferences!.setBool('isNavigateFromDashboard', false);
    super.dispose();
  }

  setInstance() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  getAppConfig() {
    _userBloc!.add(GetAppConfig());
  }

  getOrgName(List<Organization> organizationLists) async {
    try {
      sharedPreferences = await SharedPreferences.getInstance();
      String? organizationName =
          sharedPreferences!.getString('organizationName');
      String? organizationId = sharedPreferences!.getString('organizationId');
      // String? organizationLatitude =
      //     sharedPreferences!.getString('organizationLatitude');
      // String? organizationLongitude =
      //     sharedPreferences!.getString('organizationLongitude');
      // String? organizationRadius =
      //     sharedPreferences!.getString('organizationRadius');
      // bool? geoLocationEnable = sharedPreferences!.getBool('geoLocationEnable');
      bool? isSigleOrganization =
          sharedPreferences!.getBool('isSigleOrganization');
      bool? isNavigateFromDashboard =
          sharedPreferences!.getBool('isNavigateFromDashboard');
      if (organizationId != null &&
          organizationId.isNotEmpty &&
          organizationName != null &&
          organizationName.isNotEmpty &&
          isNavigateFromDashboard != null &&
          !isNavigateFromDashboard) {
        if (!mounted) return;
        Organization selectedOrganization = organizationLists
            .firstWhere((organization) => organization.id == organizationId);

        checkInstalledAppVersion(
            context,
            appConfigDetail!,
            _navigateHome,
            selectedOrganization.id,
            selectedOrganization.name,
            selectedOrganization.latitude,
            selectedOrganization.longitude,
            selectedOrganization.radius,
            selectedOrganization.geoLocationEnable,
            isSigleOrganization: isSigleOrganization);
      } else {
        setState(() {
          organizationList = organizationLists;
        });
        sharedPreferences!.setBool('isNavigateFromDashboard', false);
      }
    } catch (error) {
      Logger.printLog(error);
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
        backgroundColor: bgColor,
        body: BlocListener<UserBloc, UserState>(
            bloc: _userBloc,
            listener: (context, state) {
              if (state is GetAppConfigSuccess) {
                appConfigDetail = state.appConfig;
              } else if (state is UserLoading) {
                const Center(child: Loading());
              } else if (state is GetAppConfigFailed) {
                showAlertSnackBar(context, state.errorMessage, AlertType.error);
              } else if (state is SingleOrganizationState) {
                checkInstalledAppVersion(
                    context,
                    appConfigDetail!,
                    _navigateHome,
                    state.organizationId,
                    state.organizationName,
                    state.organizationLatitude,
                    state.organizationLongitude,
                    state.organizationRadius,
                    state.geoLocationEnable,
                    isSigleOrganization: true);
              } else if (state is MultipleOrganizationState) {
                orgList = state.organizationList;
                getOrgName(state.organizationList);
              } else if (state is UpdateProfileFailedState) {
                showAlertSnackBar(
                    context, state.errorMessage!, AlertType.error);
              } else if (state is GetAttendanceHistorySuccess) {
                attendanceHistroy = state.record;
                orgList = state.assignedOrganizations;
                UserDetailsDataStore.setCurrentClockInId = state.record.id!;
                orgList = orgList!
                    .where((item) => item.id == state.record.organizationId!)
                    .toList();
                clockInOrganizationName = orgList!.first.name!;
              } else if (state is GetAttendanceHistoryFailed) {
                showAlertSnackBar(context, state.errorMessage, AlertType.error);
              }
            },
            child: BlocBuilder<UserBloc, UserState>(
                bloc: _userBloc,
                builder: (context, state) {
                  return Stack(children: [
                    bGEntry(),
                    if (state is OrganizationLoading || state is UserLoading)
                      const Center(child: Loading()),
                    if (orgList != null &&
                        orgList!.isNotEmpty &&
                        attendanceHistroy == null &&
                        (state is! OrganizationLoading))
                      _buildBodyContentWidget(),
                    if (attendanceHistroy != null &&
                        (state is! OrganizationLoading))
                      _buildClockoutOrganization(),
                    if (state is EmptyOrganizationState &&
                        (state is! OrganizationLoading))
                      _buildNoOrganizationWidget()
                  ]);
                })));
  }

  Widget _buildClockoutOrganization() {
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: const Color(0xffF2F4FF)),
                      child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20, right: 20),
                                        child: Text(
                                            'Hey ${UserDetailsDataStore.getUserFirstName}, you are already clocked-in with ${orgList!.first.name}.',
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)))),
                                SizedBox(height: 20.h),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: greenButtonColor,
                                        minimumSize: const Size.fromHeight(50),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(23.0))),
                                    onPressed: () {
                                      progress(context);
                                      checkInstalledAppVersion(
                                          context,
                                          appConfigDetail!,
                                          _navigateHome,
                                          orgList!.first.id,
                                          orgList!.first.name!,
                                          orgList!.first.latitude,
                                          orgList!.first.longitude,
                                          orgList!.first.radius,
                                          orgList!.first.geoLocationEnable);
                                    },
                                    child: Text('Go to ${orgList!.first.name}',
                                        style: const TextStyle(
                                            color: brightTextColor,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold)))
                              ])))
                ])));
  }

  Widget _buildBodyContentWidget() {
    List<Widget> content = [];

    if (organizationList == null) {
      content.add(const Center(child: Loading()));
    } else {
      content.add(Text(translation(context).selectOrganisation,
          style: TextStyle(
              fontSize: 20.sp, fontWeight: FontWeight.bold, color: black)));
      content.add(const SizedBox(height: 20.0));
      for (var organization in organizationList!) {
        content.add((organization.subOrganizations != null &&
                organization.subOrganizations!.isNotEmpty)
            ? Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                child: ExpansionTile(
                    collapsedBackgroundColor: primaryColor,
                    backgroundColor: primaryColor,
                    collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(23.0)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(23.0)),
                    title: Text(organization.name!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: white)),
                    collapsedIconColor: white,
                    iconColor: white,
                    children: organization.subOrganizations!
                        .map((subOrganization) => InkWell(
                            onTap: () {
                              progress(context);
                              checkInstalledAppVersion(
                                  context,
                                  appConfigDetail!,
                                  _navigateHome,
                                  subOrganization.id,
                                  subOrganization.name!,
                                  subOrganization.latitude,
                                  subOrganization.longitude,
                                  subOrganization.radius,
                                  subOrganization.geoLocationEnable);
                            },
                            child: DropdownMenuItem(
                                value: subOrganization.id,
                                child: Container(
                                    padding: EdgeInsets.only(
                                        top: 10.h, bottom: 10.h),
                                    color: white,
                                    child: Center(
                                        child: Text(subOrganization.name!,
                                            textAlign: TextAlign.justify,
                                            style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                                color: black)))))))
                        .toList()))
            : (organization.isParentOrganization! ||
                    !organization.isSubOrganization!)
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23.0))),
                        onPressed: () {
                          progress(context);
                          checkInstalledAppVersion(
                              context,
                              appConfigDetail!,
                              _navigateHome,
                              organization.id,
                              organization.name!,
                              organization.latitude,
                              organization.longitude,
                              organization.radius,
                              organization.geoLocationEnable);
                        },
                        child: Text(organization.name!, style: TextStyle(color: brightTextColor, fontSize: 20.sp, fontWeight: FontWeight.bold))))
                : const SizedBox.shrink());
      }
    }

    return Center(
        child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: content)));
  }

  // no organization widget
  Widget _buildNoOrganizationWidget() {
    return Center(
        child: Container(
            width: 350.0,
            height: 300.0,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: loadingOpacityBrightColor,
            ),
            child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Text(translation(context).noOrganisation,
                      style: const TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  sizedBoxHeight_10(),
                  Text(translation(context).loginAfterOrganisation,
                      style:
                          const TextStyle(fontSize: 18.0, color: greyTextColor),
                      textAlign: TextAlign.center),
                  sizedBoxHeight_20(),
                  _buildGoBackBtn()
                ]))));
  }

  // submit btn
  Widget _buildGoBackBtn() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(23.0))),
        onPressed: () {
          Navigator.pushReplacementNamed(context, PageName.loginScreen);
        },
        child: Text(translation(context).goBack,
            style: const TextStyle(
                color: brightTextColor,
                fontSize: 18.0,
                fontWeight: FontWeight.bold)));
  }

  void _navigateHome(organizationId, organizationName, organizationLatitude,
      organizationLongitude, organizationRadius, geoLocationEnable,
      {isSigleOrganization = false}) {
    sharedPreferences!.setString('organizationId', organizationId);
    sharedPreferences!.setString('organizationName', organizationName);
    sharedPreferences!.setString('organizationLatitude', organizationLatitude);
    sharedPreferences!
        .setString('organizationLongitude', organizationLongitude);
    sharedPreferences!.setString('organizationRadius', organizationRadius);
    sharedPreferences!.setBool('geoLocationEnable', geoLocationEnable);
    sharedPreferences!.setBool('isSigleOrganization', isSigleOrganization);
    sharedPreferences!.setBool('isNavigateFromDashboard', false);
    sharedPreferences!.setBool('isChatUserListLoad', false);

    UserDetailsDataStore.setOrganizationId = organizationId;
    UserDetailsDataStore.setOrganizationName = organizationName;
    UserDetailsDataStore.setOrganizationLatitude = organizationLatitude;
    UserDetailsDataStore.setOrganizationLongitude = organizationLongitude;
    UserDetailsDataStore.setOrganizationRadius = organizationRadius;
    UserDetailsDataStore.setOrganizationGeoLocationEnable = geoLocationEnable;

    try {
      UserDetailsDataStore.setCurrentClockInId =
          sharedPreferences!.getString('currentClockInId')!;
    } catch (_) {}

    Navigator.pushNamedAndRemoveUntil(
        context, PageName.dashBoardScreen, (route) => false);
  }
}
