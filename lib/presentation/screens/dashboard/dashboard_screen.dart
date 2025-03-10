import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/presentation/routes/pages_name.dart';
import 'package:tasko/presentation/screens/screens.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class DashboardScreen extends StatefulWidget {
  final int? position;
  const DashboardScreen({super.key, this.position});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 2;
  NavigationBloc? navigationBloc;
  bool isCreateTaskEnabled = false;
  bool isPostRefresh = true;

  List<Widget>? _widgetOptions = [];
  final GlobalKey<PopupMenuButtonState> _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.position!;
    navigationBloc = BlocProvider.of<NavigationBloc>(context);
    _onItemTapped(_selectedIndex);
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == 0 && index == 0 && !isPostRefresh) {
      Navigator.pushNamedAndRemoveUntil(
          context, PageName.dashBoardScreen, (route) => false);
    } else {
      setState(() {
        _selectedIndex = index;
        isCreateTaskEnabled = false;
        navigationBloc!.add(OnTap(_selectedIndex));
      });
    }
  }

  void onTaskSelected() async {
    var result = await Navigator.pushNamed(context, PageName.updateTaskScreen);
    if (result == true) {
      setState(() {
        _selectedIndex = 2;
        navigationBloc!.add(OnTap(_selectedIndex));
      });
    }
  }

  void onDashboardSelected() {
    setState(() {
      _selectedIndex = 0;
      navigationBloc!.add(OnTap(0));
    });
  }

  void onUserProfileSelected() {
    setState(() {
      _selectedIndex = 3;
      navigationBloc!.add(OnTap(3));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  getCurrentWidget() {
    return _widgetOptions = <Widget>[
      const HomeScreen(),
      MessageScreen(onBack: () {
        onDashboardSelected();
      }),
      TaskListScreen(
          onBack: () {
            onDashboardSelected();
          },
          isCreateTask: isCreateTaskEnabled),
      UserProfileScreen(onBack: () {
        onDashboardSelected();
      }),
      if (UserDetailsDataStore.getAdminFlag!)
        AdminDashboardScreen(onBack: () {
          onDashboardSelected();
        })
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) {
            return;
          }
          if (_selectedIndex != 0) {
            _onItemTapped(0);
          } else {
            showAlertWithAction(
                context: context,
                title: translation(context).exit,
                content: translation(context).exitConfirm,
                onPress: () {
                  exit(0);
                });
          }
          return;
        },
        child: Scaffold(
            endDrawer: DrawerWidget(navigateProfileScreen: () {
              onUserProfileSelected();
            }),
            backgroundColor: bgColor,
            body: BlocListener<NavigationBloc, NavigationState>(
                bloc: navigationBloc,
                listener: (context, state) {
                  if (state is NavigationIndex) {
                    getCurrentWidget()[state.index];
                  }
                },
                child: BlocBuilder<NavigationBloc, NavigationState>(
                    bloc: navigationBloc,
                    builder: (context, state) {
                      return _buildBodyContent();
                    })),
            bottomNavigationBar: CupertinoTabBar(
                key: _key,
                activeColor: primaryColor,
                border:
                    const Border(top: BorderSide(color: Colors.transparent)),
                onTap: _onItemTapped,
                currentIndex: _selectedIndex,
                items: [
                  BottomNavigationBarItem(
                      label: translation(context).home,
                      icon: const ImageIcon(
                          AssetImage('assets/images/home.png'))),
                  BottomNavigationBarItem(
                      label: translation(context).chat,
                      icon: const ImageIcon(
                          AssetImage('assets/images/message.png'))),
                  BottomNavigationBarItem(
                      label: translation(context).task,
                      icon: const ImageIcon(
                          AssetImage('assets/images/task.png'))),
                  BottomNavigationBarItem(
                      label: translation(context).profile,
                      icon: const ImageIcon(
                          AssetImage('assets/images/profile.png'))),
                  if (UserDetailsDataStore.getAdminFlag!)
                    BottomNavigationBarItem(
                        label: translation(context).admin,
                        icon: const Icon(Icons.admin_panel_settings, size: 35))
                ])));
  }

  Widget _buildBodyContent() {
    return SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(children: [
          _widgetOptions!.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.zero,
                  child:
                      Center(child: _widgetOptions!.elementAt(_selectedIndex)))
              : const SizedBox(),
          Positioned(
            bottom: _selectedIndex == 2 ? 75 : 10,
            right: 10,
            child: FloatingActionButton(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(180)),
                onPressed: () {
                  addPostTask();
                },
                child: const Icon(Icons.add, color: white)),
          ),
        ]));
  }

  addPostTask() {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext _) {
          return Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
              child: CupertinoActionSheet(
                  actions: <Widget>[
                    CupertinoActionSheetAction(
                        onPressed: () async {
                          Navigator.pop(context);
                          var result = await Navigator.pushNamed(
                              context, PageName.addFeed,
                              arguments: {'isMyPostUpdate': false});
                          if (result == true) {
                            isPostRefresh = false;
                            _onItemTapped(0);
                          }
                        },
                        child: Text(translation(context).postFeed,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: primaryColor))),
                    if (_selectedIndex != 2)
                      CupertinoActionSheetAction(
                          onPressed: () {
                            isCreateTaskEnabled = true;
                            Navigator.pop(context);
                            onTaskSelected();
                          },
                          child: Text(translation(context).createTask,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: primaryColor))),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                              context, PageName.projectDetailScreen);
                        },
                        child: Text(translation(context).createAProject,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: primaryColor))),
                    // UserDetailsDataStore.getAdminFlag!
                    //     ? CupertinoActionSheetAction(
                    //         onPressed: () async {
                    //           Navigator.pop(context);
                    //           var result = await Navigator.pushNamed(
                    //               context, PageName.addOrganizationScreen);
                    //           if (result != null &&
                    //               result is bool &&
                    //               result &&
                    //               mounted) {
                    //             Navigator.pushNamed(
                    //                 context, PageName.adminOrganizationScreen);
                    //           }
                    //         },
                    //         child: Text(translation(context).addOrganization,
                    //             style: const TextStyle(
                    //                 fontSize: 18,
                    //                 fontWeight: FontWeight.w400,
                    //                 color: primaryColor)))
                    //     : const SizedBox(),
                    UserDetailsDataStore.getAdminFlag!
                        ? CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                  context, PageName.createUserScreen);
                            },
                            child: Text(translation(context).createAnUser,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: primaryColor)))
                        : const SizedBox(),
                    UserDetailsDataStore.getAdminFlag!
                        ? CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                  context, PageName.createShiftScreen);
                            },
                            child: Text(translation(context).createAShift,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: primaryColor)))
                        : const SizedBox()
                  ],
                  cancelButton: CupertinoActionSheetAction(
                      isDefaultAction: true,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(translation(context).cancel,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: primaryColor)))));
        });
  }
}
