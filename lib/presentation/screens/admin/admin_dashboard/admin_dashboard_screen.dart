import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/presentation/routes/pages_name.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class AdminDashboardScreen extends StatefulWidget {
  final Function onBack;

  const AdminDashboardScreen({super.key, required this.onBack});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  List<User>? userList;
  int activeUserCount = 0;
  int inActiveUserCount = 0;
  int totalUserCount = 0;
  AdminBloc? adminBloc;
  String? userName = FirebaseAuth.instance.currentUser!.displayName;
  @override
  void initState() {
    adminBloc = BlocProvider.of<AdminBloc>(context);
    BlocProvider.of<AdminBloc>(context).add(GetUsersDataEvent());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            buildBackgroundWidget(),
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 15.h),
                  Align(
                      alignment: Alignment.topLeft,
                      child: goBack(widget.onBack)),
                  // filterButtons(),
                  BlocListener(
                    bloc: adminBloc,
                    listener: (context, state) {
                      if (state is UsersCountState) {
                        activeUserCount = state.activeUserCount;
                        inActiveUserCount = state.inActiveUserCount;
                        totalUserCount = state.totalUserCount;
                      }
                    },
                    child: BlocBuilder<AdminBloc, AdminState>(
                      bloc: adminBloc,
                      builder: (context, state) {
                        if (state is AdminLoadingState) {
                          return _buildLoadingWidget(context);
                        } else {
                          return _buildUsersCounttWidget(activeUserCount,
                              inActiveUserCount, totalUserCount);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _buildLoadingWidget(BuildContext context) {
    return SizedBox(
        height: 300,
        width: MediaQuery.of(context).size.width,
        child: Center(child: showCirclularLoading()));
  }

  Widget _buildUsersCounttWidget(
    activeUserCount,
    inActiveUserCount,
    totalUserCount,
  ) {
    String? firstName = UserDetailsDataStore.getUserFirstName;
    String? lastName = UserDetailsDataStore.getUserLastName;
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          userRowWidget(firstName!, lastName!,
              UserDetailsDataStore.getUserStatus!, true, context),
          const SizedBox(
            height: 30,
          ),
          // Card(
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(25.0),
          //   ),
          //   color: Colors.white,
          //   child: SizedBox(
          //     width: 350,
          //     height: 130,
          //     // color: Colors.blue,
          //     child: Column(
          //       children: [
          //         Padding(
          //           padding: const EdgeInsets.symmetric(vertical: 15),
          //           child: SizedBox(
          //             width: 280,
          //             // color: Colors.red,
          //             child: Row(
          //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //               children: [
          //                 Column(
          //                   children: [
          //                     Text(
          //                       activeUserCount.toString(),
          //                       style: const TextStyle(
          //                           fontWeight: FontWeight.bold,
          //                           color: Color(0xff5386E4),
          //                           fontSize: 48),
          //                     ),
          //                     const Text('Active',
          //                         style: TextStyle(
          //                             fontSize: 14,
          //                             fontFamily: 'Poppins',
          //                             fontWeight: FontWeight.bold,
          //                             color: Color(0xffAFB0B6)))
          //                   ],
          //                 ),
          //                 Column(
          //                   children: [
          //                     Text(inActiveUserCount.toString(),
          //                         style: const TextStyle(
          //                             fontWeight: FontWeight.bold,
          //                             color: Color(0xffAFB0B6),
          //                             fontSize: 48)),
          //                     const Text('In-Active',
          //                         style: TextStyle(
          //                             fontSize: 14,
          //                             fontFamily: 'Poppins',
          //                             fontWeight: FontWeight.bold,
          //                             color: Color(0xffAFB0B6)))
          //                   ],
          //                 ),
          //                 Column(
          //                   children: [
          //                     Text(totalUserCount.toString(),
          //                         style: const TextStyle(
          //                             fontWeight: FontWeight.bold,
          //                             color: Colors.black,
          //                             fontSize: 48)),
          //                     const Text('Total',
          //                         style: TextStyle(
          //                             fontSize: 14,
          //                             fontFamily: 'Poppins',
          //                             fontWeight: FontWeight.bold,
          //                             color: Color(0xffAFB0B6)))
          //                   ],
          //                 )
          //               ],
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),

          const SizedBox(height: 5),
          _buildDashboardMenu(),
        ],
      ),
    );
  }

  Widget _buildDashboardMenu() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _dashboardItemWidget(
                onTap: () {
                  Navigator.pushNamed(
                      context, PageName.assignOrganizationScreen);
                },
                iconPath: 'assets/icons/invite_users.png',
                title: translation(context).assignOrganisation),
            _dashboardItemWidget(
                onTap: () {
                  Navigator.pushNamed(context, PageName.userListScreen);
                },
                iconPath: 'assets/icons/invited_users.png',
                title: translation(context).users),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _dashboardItemWidget(
                onTap: () {
                  Navigator.pushNamed(context, PageName.adminViewRecords);
                },
                iconPath: 'assets/icons/view_records.png',
                title: translation(context).viewRecords),
            _dashboardItemWidget(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    PageName.adminOrganizationScreen,
                  );
                },
                iconPath: 'assets/icons/view_records.png',
                title: translation(context).viewOrganisation),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _dashboardItemWidget(
                onTap: () {
                  Navigator.pushNamed(context, PageName.shiftListScreen);
                },
                iconPath: 'assets/icons/view_records.png',
                title: translation(context).viewShifts),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget _dashboardItemWidget({onTap, iconPath, title}) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        color: Colors.white,
        child: SizedBox(
            width: (MediaQuery.of(context).size.width / 2) - 30,
            height: 130,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ImageIcon(
                    AssetImage(iconPath),
                    color: primaryColor,
                    size: 50,
                  ),
                  const SizedBox(height: 5),
                  Text(title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          color: primaryColor)),
                ],
              ),
            )),
      ),
    );
  }
}
