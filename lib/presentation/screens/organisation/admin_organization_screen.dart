import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/organization.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/presentation/routes/pages_name.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/colors/colors.dart';

class AdminOrganizationScreen extends StatefulWidget {
  const AdminOrganizationScreen({super.key});

  @override
  State<AdminOrganizationScreen> createState() =>
      _AdminOrganizationScreenState();
}

class _AdminOrganizationScreenState extends State<AdminOrganizationScreen> {
  UserBloc? _userBloc;
  List<Organization>? subOrganizations;
  String? subOrganizationName;
  bool? isExpanded = false;
  @override
  void initState() {
    _userBloc = BlocProvider.of<UserBloc>(context);
    readData();
    super.initState();
  }

  readData() async {
    _userBloc!.add(ReadUserOrganizationEvent());
    setState(() {});
  }

  @override
  Widget build(context) {
    return Scaffold(
        backgroundColor: bgColor,
        floatingActionButton: FloatingActionButton(
            backgroundColor: primaryColor,
            onPressed: () async {
              var result = await Navigator.pushNamed(
                  context, PageName.addOrganizationScreen, arguments: {
                'organization': null,
                'isSubOrganization': false
              });
              if (result == true) {
                readData();
              }
            },
            child: const Icon(Icons.add, color: white)),
        body: Stack(children: [
          bGMainMini(),
          Column(children: [
            SizedBox(height: 20.h),
            Align(
                alignment: Alignment.topLeft,
                child: goBack(() {
                  Navigator.of(context).pop();
                })),
            Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(translation(context).organisation,
                    style: const TextStyle(
                        color: brightTextColor,
                        fontSize: 24,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600))),
            const SizedBox(height: 40),
            (UserDetailsDataStore.getUserOrganizations!.isNotEmpty)
                ? Expanded(
                    child: BlocBuilder(
                        bloc: _userBloc,
                        builder: (context, state) {
                          if (state is OrganizationLoading) {
                            return const Center(child: Loading());
                          }
                          return _buildBodyContentWidget();
                        }))
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
                .map((organization) => ((organization
                                    .subOrganizations!.isNotEmpty ||
                                organization.subOrganizations != null) &&
                            !organization.isSubOrganization! ||
                        organization.isParentOrganization!)
                    ? Column(children: [
                        Card(
                            color: primaryColor,
                            margin: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            child: ExpansionTile(
                                collapsedShape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide.none),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide.none),
                                expandedAlignment: Alignment.centerRight,
                                onExpansionChanged: (value) {
                                  setState(() {
                                    isExpanded = value;
                                  });
                                },
                                title: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(organization.name!,
                                          style: TextStyle(
                                              color: white,
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold)),
                                      Text(organization.email!,
                                          style: TextStyle(
                                              color: white,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.normal))
                                    ]),
                                subtitle: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(organization.address!,
                                        style: TextStyle(
                                            color: white,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.normal),
                                        textAlign: TextAlign.center)),
                                trailing: PopupMenuButton(
                                    iconColor: white,
                                    color: white,
                                    itemBuilder: (context) {
                                      return [
                                        PopupMenuItem(
                                            value: 'edit',
                                            child: Text(
                                                translation(context).edit,
                                                style: const TextStyle(
                                                    fontSize: 13.0)),
                                            onTap: () async {
                                              var result =
                                                  await Navigator.pushNamed(
                                                      context,
                                                      PageName
                                                          .addOrganizationScreen,
                                                      arguments: {
                                                    'organization': organization
                                                  });
                                              if (result == true) {
                                                readData();
                                              }
                                            }),
                                        PopupMenuItem(
                                            value: 'delete',
                                            child: Text(
                                                translation(context).delete,
                                                style: const TextStyle(
                                                    fontSize: 13.0)),
                                            onTap: () async {
                                              String orgId = organization.id!;
                                              String orgName =
                                                  organization.name!;
                                              var result = await showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      DeleteOrganizationDialog(
                                                          orgId: orgId,
                                                          orgName: orgName));
                                              if (result != null) {
                                                _userBloc!.add(
                                                    ReadUserOrganizationEvent());
                                              }
                                            }),
                                        PopupMenuItem(
                                            value: 'add Sub Organisation',
                                            child: Text(
                                                translation(context).addSubOrg,
                                                style:
                                                    TextStyle(fontSize: 11.sp)),
                                            onTap: () async {
                                              var result =
                                                  await Navigator.pushNamed(
                                                      context,
                                                      PageName
                                                          .addOrganizationScreen,
                                                      arguments: {
                                                    'organization':
                                                        organization,
                                                    'isSubOrganization': true
                                                  });
                                              if (result == true) {
                                                readData();
                                              }
                                            })
                                      ];
                                    }),
                                children: organization.subOrganizations!
                                    .map((subOrganization) => Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 5.h, horizontal: 40.h),
                                        color: white,
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(subOrganization.name!,
                                                        style: const TextStyle(
                                                            color:
                                                                darkTextColor,
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Text(subOrganization.email!,
                                                        style: const TextStyle(
                                                            color:
                                                                darkTextColor,
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal))
                                                  ]),
                                              PopupMenuButton(
                                                  color: bgColor,
                                                  itemBuilder: (context) {
                                                    return [
                                                      PopupMenuItem(
                                                          value: 'edit',
                                                          child: Text(
                                                              translation(
                                                                      context)
                                                                  .edit,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          13.0)),
                                                          onTap: () async {
                                                            var result = await Navigator
                                                                .pushNamed(
                                                                    context,
                                                                    PageName
                                                                        .addOrganizationScreen,
                                                                    arguments: {
                                                                  'organization':
                                                                      subOrganization
                                                                });
                                                            if (result ==
                                                                true) {
                                                              readData();
                                                            }
                                                          }),
                                                      PopupMenuItem(
                                                          value: 'delete',
                                                          child: Text(
                                                              translation(
                                                                      context)
                                                                  .delete,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          13.0)),
                                                          onTap: () async {
                                                            String orgId =
                                                                subOrganization
                                                                    .id!;
                                                            String orgName =
                                                                subOrganization
                                                                    .name!;
                                                            var result = await showDialog(
                                                                context:
                                                                    context,
                                                                builder: (context) =>
                                                                    DeleteOrganizationDialog(
                                                                        orgId:
                                                                            orgId,
                                                                        orgName:
                                                                            orgName));
                                                            if (result !=
                                                                null) {
                                                              _userBloc!.add(
                                                                  ReadUserOrganizationEvent());
                                                            }
                                                          }),
                                                      PopupMenuItem(
                                                          value:
                                                              'add Sub Organisation',
                                                          child: Text(
                                                              translation(
                                                                      context)
                                                                  .addSubOrg,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      11.sp)),
                                                          onTap: () async {
                                                            var result = await Navigator
                                                                .pushNamed(
                                                                    context,
                                                                    PageName
                                                                        .addOrganizationScreen,
                                                                    arguments: {
                                                                  'organization':
                                                                      subOrganization,
                                                                  'isSubOrganization':
                                                                      true
                                                                });
                                                            if (result ==
                                                                true) {
                                                              readData();
                                                            }
                                                          })
                                                    ];
                                                  })
                                            ])))
                                    .toList()))
                      ])
                    : const SizedBox())
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
            color: loadingOpacityBrightColor),
        child: Column(children: [
          Text(translation(context).noOrganisation,
              style: const TextStyle(
                  fontSize: 16.0, fontWeight: FontWeight.normal),
              textAlign: TextAlign.center),
          // sizedBoxHeight_10(),
          const SizedBox(height: 10),
          // const Text(
          //   'Login after joining any one Organisation.',
          //   style: TextStyle(fontSize: 16.0, color: greyTextColor),
          //   textAlign: TextAlign.center,
          // ),
          // sizedBoxHeight_20(),
          const SizedBox(height: 20),
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
                borderRadius: BorderRadius.circular(23.0))),
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
