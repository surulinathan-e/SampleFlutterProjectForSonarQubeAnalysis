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

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key, required this.onBack});
  final Function onBack;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final bool _isPasswordObscure = true;
  UserBloc? userBloc;
  ClockBloc? clockBloc;
  AppConfig? appConfig;

  @override
  void initState() {
    super.initState();
    userBloc = BlocProvider.of<UserBloc>(context);
    clockBloc = BlocProvider.of<ClockBloc>(context);
    getAppConfig();
  }

  getAppConfig() {
    userBloc!.add(GetAppConfig());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bgColor,
        body: BlocListener<UserBloc, UserState>(
            bloc: userBloc,
            listener: (context, state) async {
              if (state is UserError) {
                if (mounted) {
                  if (ModalRoute.of(context)?.isCurrent != true) {
                    Navigator.of(context).pop();
                  }
                  showAlertSnackBar(
                      context, state.errorMessage!, AlertType.error);
                }
              } else if (state is DeleteUserSuccessState) {
                Navigator.pop(context);
                _navigateLogInScreen();
              } else if (state is GetAppConfigSuccess) {
                appConfig = state.appConfig;
              } else if (state is GetAppConfigFailed) {
                showAlertSnackBar(context, state.errorMessage, AlertType.error);
              }
            },
            child: BlocBuilder<UserBloc, UserState>(
                bloc: userBloc,
                builder: (context, state) {
                  return Stack(children: [
                    buildBackgroundWidget(),
                    Column(children: [
                      SizedBox(
                        height: 15.h,
                      ),
                      _buildToolbarSectionWidget(),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20.0, bottom: 20.0),
                        child: BlocBuilder<ClockBloc, ClockState>(
                            bloc: clockBloc,
                            builder: (context, state) {
                              String? firstName =
                                  UserDetailsDataStore.getUserFirstName;
                              String? lastName =
                                  UserDetailsDataStore.getUserLastName;
                              return userRowWidget(
                                  firstName!,
                                  lastName!,
                                  UserDetailsDataStore.getUserStatus!,
                                  true,
                                  context);
                            }),
                      ),
                      Expanded(
                          child: SingleChildScrollView(
                              child: Column(children: [
                        _buildNavItemWidgets(),
                        _buildAboutSectionItemWidgets()
                      ])))
                    ])
                  ]);
                })));
  }

  Widget _buildToolbarSectionWidget() {
    return Stack(children: [
      Align(
          alignment: Alignment.topLeft,
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: brightBackArrow(widget.onBack))),
      SizedBox(
          height: 40.0,
          child: Align(
              alignment: Alignment.center,
              child: Text(translation(context).profile,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: white))))
    ]);
  }

  Widget _buildNavItemWidgets() {
    return Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0),
        child: Column(children: [
          ListTile(
              leading:
                  const ImageIcon(AssetImage('assets/icons/personal_info.png')),
              title: Text(
                translation(context).updateProfile,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                var result = await Navigator.of(context)
                    .pushNamed(PageName.updateProfile);
                if (result != null) {
                  setState(() {});
                }
              }),
          // ListTile(
          //   leading:
          //       const ImageIcon(AssetImage('assets/icons/notifications.png')),
          //   title: const Text(
          //     'Notifications',
          //     style: TextStyle(fontWeight: FontWeight.bold),
          //   ),
          //   onTap: () {
          //     Navigator.of(context).pushNamed(PagesName.notifications);
          //   },
          // ),

          ListTile(
              leading:
                  const ImageIcon(AssetImage('assets/icons/view_records.png')),
              title: Text(
                translation(context).viewRecords,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.of(context).pushNamed(PageName.viewRecords);
              }),
          ListTile(
              leading: const ImageIcon(
                  AssetImage('assets/icons/change_password.png')),
              title: Text(translation(context).changePassword,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.of(context).pushNamed(PageName.changePasswordScreen);
              }),
          ListTile(
              leading: const ImageIcon(
                  AssetImage('assets/icons/added_organistation.png')),
              title: Text(translation(context).organisation,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.of(context)
                    .pushNamed(PageName.addedOrganizationScreen);
              }),
          ListTile(
            leading: const ImageIcon(AssetImage('assets/icons/globe.png')),
            title: Text(translation(context).language,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.of(context).pushNamed(PageName.languageScreen);
            },
          ),
          ListTile(
              leading: const ImageIcon(
                  AssetImage('assets/icons/delete_account.png'),
                  color: redIconColor),
              title: Text(translation(context).deleteAccount,
                  style: const TextStyle(
                      color: redTextColor, fontWeight: FontWeight.bold)),
              onTap: () {
                showAlertWithAction(
                    context: context,
                    title: translation(context).deleteAccount,
                    content: translation(context).deleteConfirmation,
                    onPress: () {
                      _displayTextInputDialog();
                    });
              })
        ]));
  }

  Widget _buildAboutSectionItemWidgets() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 10.0),
      child: Column(
        children: [
          Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(translation(context).about,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                      color: greyTextColor,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold))),
          ListTile(
              leading: const ImageIcon(AssetImage('assets/icons/privacy.png')),
              title: Text(translation(context).privacy,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                launchURL(appConfig!.privacyUrl!);
              }),
          ListTile(
            leading: const ImageIcon(
                AssetImage('assets/icons/terms_and_condition.png')),
            title: Text(translation(context).termsandConditions,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              launchURL(appConfig!.termsUrl!);
            },
          ),
          ListTile(
            leading:
                const ImageIcon(AssetImage('assets/icons/help_center.png')),
            title: Text(
              translation(context).helpCentre,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              launchURL(appConfig!.helpUrl!);
            },
          ),
          ListTile(
            leading: const ImageIcon(AssetImage('assets/icons/about.png')),
            title: Text(
              translation(context).about,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              launchURL(appConfig!.aboutUrl!);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _displayTextInputDialog() async {
    String? valueText;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              translation(context).passwordDelete,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  color: blueTextColor,
                  fontWeight: FontWeight.bold),
            ),
            content: Material(
              child: Form(
                  key: formKey,
                  child: TextFormField(
                    enabled: true,
                    textInputAction: TextInputAction.next,
                    obscureText: _isPasswordObscure,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 10.0),
                        hintText: translation(context).password,
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: darkTextColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                              color: grayBorderColor, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(color: darkBorderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(color: darkBorderColor),
                        )),
                    onChanged: (value) {
                      setState(() {
                        valueText = value;
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return translation(context).enterPassword;
                      } else {
                        return null;
                      }
                    },
                    onFieldSubmitted: (term) {},
                  )),
            ),
            actions: <Widget>[
              TextButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: greyBgColor,
                ),
                child: Text(translation(context).cancel,
                    style: const TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenButtonColor,
                ),
                child: Text(translation(context).submit,
                    style: const TextStyle(color: Colors.white)),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(context);
                    progress(context);
                    userBloc!.add(DeleteUserEvent(password: valueText));
                  }
                },
              ),
            ],
          );
        });
  }

  void _navigateLogInScreen() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    sharedPreferences.remove('organizationName');
    sharedPreferences.remove('userStatus');
    sharedPreferences.remove('isSigleOrganization');
    if (mounted) {
      Navigator.of(context).pop(false);

      Navigator.pushNamedAndRemoveUntil(
          context, PageName.loginScreen, (route) => false);
    }
  }
}
