import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/app_config.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/presentation/routes/pages_name.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class DrawerWidget extends StatefulWidget {
  final Function? navigateProfileScreen;
  const DrawerWidget({super.key, this.navigateProfileScreen});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  UserBloc? userBloc;
  String? userId;
  AppConfig? appConfig;
  SharedPreferences? sharedPreferences;

  @override
  void initState() {
    userBloc = BlocProvider.of<UserBloc>(context);
    userId = UserDetailsDataStore.getCurrentFirebaseUserID;
    getAppConfig();
    getSharedPreferences();
    super.initState();
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

  getAppConfig() {
    userBloc!.add(GetAppConfig());
  }

  clearPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
        bloc: userBloc,
        listener: (context, state) async {
          if (state is UserDeleteSuccess) {
            clearPref();
            Navigator.pushNamedAndRemoveUntil(
                context, PageName.loginScreen, (route) => false);
            showAlertSnackBar(context, translation(context).accountDeleted,
                AlertType.success);
          } else if (state is UserFailed) {
            showAlertSnackBar(context, state.errorMessage, AlertType.error);
          } else if (state is UserLoading) {
            const Loading();
          } else if (state is GetAppConfigSuccess) {
            appConfig = state.appConfig;
          } else if (state is GetAppConfigFailed) {
            showAlertSnackBar(context, state.errorMessage, AlertType.error);
          }
        },
        child: BlocBuilder<UserBloc, UserState>(
            bloc: userBloc,
            builder: (context, state) {
              return _buildDrawer();
            }));
  }

  Widget _buildDrawer() {
    return Drawer(
        backgroundColor: bgColor,
        child: Padding(
            padding: EdgeInsets.only(
                top: 10.h, bottom: 20.h, right: 10.w, left: 10.w),
            child: Column(children: [
              _buildUserProfileWidget(context),
              _buildMenuItemsWidget(context),
              _buildTermsAndConditionWidget(context)
            ])));
  }

  Widget _buildUserProfileWidget(BuildContext context) {
    return Padding(
        padding:
            EdgeInsets.only(top: 20.0 + MediaQuery.of(context).padding.top),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // user avatar
              BlocBuilder<ClockBloc, ClockState>(
                  bloc: BlocProvider.of<ClockBloc>(context),
                  builder: (context, state) {
                    return userAvatar(UserDetailsDataStore.getUserProfilePic,
                        UserDetailsDataStore.getUserStatus!, true);
                  }),
              BlocBuilder<ClockBloc, ClockState>(
                  bloc: BlocProvider.of<ClockBloc>(context),
                  builder: (context, state) {
                    String userName = ConvertionUtil.convertSingleName(
                        UserDetailsDataStore.getUserFirstName!,
                        UserDetailsDataStore.getUserLastName!);
                    return Text(userName,
                        style: TextStyle(
                            color: darkTextColor,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500));
                  }),
              TextButton(
                  onPressed: () {
                    _navigateProfileScreen();
                  },
                  child: Text(translation(context).profile,
                      style:
                          TextStyle(color: greenButtonColor, fontSize: 12.sp)))
            ]));
  }

  Widget _buildMenuItemsWidget(BuildContext context) {
    return Column(children: [
      ListTile(
          leading:
              const ImageIcon(AssetImage('assets/icons/personal_info.png')),
          title: Text(translation(context).personalInfo,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          onTap: () {
            _navigateProfileScreen();
          }),
      ListTile(
          leading: const ImageIcon(AssetImage('assets/icons/organization.png')),
          title: Text(translation(context).changeOrganization,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          onTap: () {
            _navigateChangeOrganizationScreen();
          }),
      ListTile(
          leading: const ImageIcon(AssetImage('assets/icons/globe.png')),
          title: Text(translation(context).language,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          onTap: () {
            _navigateChangeLanguageScreen();
          }),
      // ListTile(
      //   leading:
      //       const ImageIcon(AssetImage('assets/icons/applied_shift.png')),
      //   title: const Text(
      //     'Applied shifts',
      //     style: TextStyle(fontWeight: FontWeight.bold),
      //   ),
      //   onTap: () {
      //     showConstructionAlert();
      //   },
      // ),
      // ListTile(
      //   leading:
      //       const ImageIcon(AssetImage('assets/icons/proposed_shift.png')),
      //   title: const Text(
      //     'Proposed shifts',
      //     style: TextStyle(fontWeight: FontWeight.bold),
      //   ),
      //   onTap: () {
      //     showConstructionAlert();
      //   },
      // ),
      // ListTile(
      //   leading:
      //       const ImageIcon(AssetImage('assets/icons/scheduled_shift.png')),
      //   title: const Text(
      //     'Scheduled info',
      //     style: TextStyle(fontWeight: FontWeight.bold),
      //   ),
      //   onTap: () {
      //     showConstructionAlert();
      //   },
      // ),
      // ListTile(
      //   leading: const ImageIcon(AssetImage('assets/icons/resume.png')),
      //   title: const Text(
      //     'Resume',
      //     style: TextStyle(fontWeight: FontWeight.bold),
      //   ),
      //   onTap: () {
      //     showConstructionAlert();
      //   },
      // ),
      // ListTile(
      //   leading: const ImageIcon(AssetImage('assets/icons/settings.png')),
      //   title: const Text(
      //     'Settings',
      //     style: TextStyle(fontWeight: FontWeight.bold),
      //   ),
      //   onTap: () {
      //     showConstructionAlert();
      //   },
      // ),
      ListTile(
          leading: const ImageIcon(AssetImage('assets/icons/logout.png'),
              color: redIconColor),
          title: Text(translation(context).logout,
              style: const TextStyle(
                  color: redTextColor, fontWeight: FontWeight.bold)),
          onTap: () async {
            if (UserDetailsDataStore.getUserStatus!) {
              showAlert(context, translation(context).clockoutLogout);
            } else {
              showAlertWithAction(
                  context: context,
                  title: 'Logout',
                  content: translation(context).confirmLogout,
                  onPress: () {
                    _doLogOut(context);
                  });
            }
          })
    ]);
  }

  Widget _buildTermsAndConditionWidget(BuildContext context) {
    return Expanded(
        child: Container(
            alignment: Alignment.bottomCenter,
            child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  launchURL(appConfig!.privacyUrl!);
                },
                child: Text(translation(context).termsandConditions,
                    style:
                        TextStyle(color: greenButtonColor, fontSize: 12.sp)))));
  }

  void _navigateProfileScreen() {
    Navigator.pop(context);
    widget.navigateProfileScreen!();
  }

  void _navigateChangeOrganizationScreen() {
    Navigator.pop(context);
    if (UserDetailsDataStore.getUserStatus!) {
      showAlert(context, translation(context).clockoutOrganisation);
    } else {
      sharedPreferences!.setBool('isNavigateFromDashboard', true);
      Navigator.pushNamed(context, PageName.organizationSelectionScreen);
    }
  }

  void _navigateChangeLanguageScreen() {
    Navigator.pop(context);
    Navigator.pushNamed(context, PageName.languageScreen);
  }

  void _doLogOut(context) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await FirebaseAuth.instance.signOut().then((value) {
      sharedPreferences.clear();
      Navigator.pushNamedAndRemoveUntil(
          context, PageName.loginScreen, (route) => false);
    });
  }
}
