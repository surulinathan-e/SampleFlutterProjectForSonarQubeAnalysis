import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/attendance_history.dart';
import 'package:tasko/data/model/organization.dart';
import 'package:tasko/data/model/user.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class AdminViewRecordsScreen extends StatefulWidget {
  const AdminViewRecordsScreen({super.key});

  @override
  State<AdminViewRecordsScreen> createState() => _AdminViewRecordsScreenState();
}

class _AdminViewRecordsScreenState extends State<AdminViewRecordsScreen> {
  int page = 1;
  int limit = 10;
  bool isLastPost = false;
  ScrollController scrollController = ScrollController();
  List<AttendanceHistroy>? attendanceHistory;
  String? organizationId;
  bool shiftButtonPressed = false;
  bool monthButtonPressed = false;
  bool dayButtonPressed = false;
  String selectedDate = '';
  String month = '';
  String shift = '';
  final GlobalKey<PopupMenuButtonState> _monthKey = GlobalKey();
  final GlobalKey<PopupMenuButtonState> _shiftKey = GlobalKey();
  AdminViewRecordsBloc? adminViewRecordsBloc;
  FilteringBloc? filteringBloc;
  String? selectedOrganization;
  List<Organization>? organizations;

//rpk
  List<List<String>> lls = [];
  List<String> ls = [];
  List<String> shifts = ['All shifts'];
  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void initState() {
    adminViewRecordsBloc = BlocProvider.of<AdminViewRecordsBloc>(context);
    filteringBloc = BlocProvider.of<FilteringBloc>(context);
    organizations = UserDetailsDataStore.getUserOrganizations!;
    netWorkStatusCheck();
    scrollController.addListener(loadMore);
    super.initState();
  }

  netWorkStatusCheck() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    organizationId = sharedPreferences.getString('organizationId');
    selectedOrganization = organizationId;
    await connectivityCheck().then((internet) {
      if (!internet && mounted) {
        showModal(context, () {
          getAttendanceHistory();
        });
      } else {
        getAttendanceHistory();
      }
    });
  }

  loadMore() {
    double maxScroll = scrollController.position.maxScrollExtent;
    double offset = scrollController.offset;
    bool outOfRange = scrollController.position.outOfRange;

    if (offset >= maxScroll && !outOfRange && !isLastPost) {
      page = page + 1;
      getAttendanceHistory();
    }
  }

  getAttendanceHistory() async {
    adminViewRecordsBloc!
        .add(GetUsersAttendanceHistoryEvent(organizationId!, page, limit));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bgColor,
        body: Stack(children: [
          // bg
          bGMainMini(),
          Column(children: [
            SizedBox(height: 20.h),
            Align(
                alignment: Alignment.topLeft,
                child: goBack(() => {Navigator.of(context).pop()})),
            Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Text(translation(context).viewRecords,
                    style: const TextStyle(
                        color: brightTextColor,
                        fontSize: 24,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600))),
            // filterButtons(),
            BlocListener<AdminViewRecordsBloc, AdminViewRecordsState>(
                bloc: adminViewRecordsBloc,
                listener: (context, state) {
                  if (state is GetUserAttendanceHistorySuccess) {
                    isLastPost = state.attendanceHistory.isEmpty ||
                        state.attendanceHistory.length < 10;
                    if (page == 1) {
                      attendanceHistory = state.attendanceHistory;
                    } else {
                      attendanceHistory!.addAll(state.attendanceHistory);
                    }
                  } else if (state is GetUserAttendanceHistoryFailed) {
                    showAlertSnackBar(
                        context, state.errorMessage, AlertType.error);
                  }
                },
                child: BlocBuilder<AdminViewRecordsBloc, AdminViewRecordsState>(
                    bloc: adminViewRecordsBloc,
                    builder: (context, state) {
                      if (state is ViewRecordsLoadingState) {
                        return _buildLoadingWidget(context);
                      } else {
                        return _buildAttendanceHistoryWidget(context);
                      }
                    }))
          ])
        ]));
  }

  Widget _buildOrganizationWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30),
      child: DropdownButtonFormField(
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
            fillColor: transparent,
          ),
          validator: (value) =>
              value == null ? translation(context).selectOrganisation : null,
          dropdownColor: white,
          value: selectedOrganization,
          onChanged: (String? newValue) {
            attendanceHistory!.clear();
            organizationId = newValue;
            page = 1;
            adminViewRecordsBloc!
                .add(GetUsersAttendanceHistoryEvent(newValue!, page, limit));
            setState(() {
              selectedOrganization = newValue;
            });
          },
          items: organizations!
              .map((organization) => DropdownMenuItem(
                  value: '${organization.id}',
                  child: Text('${organization.name}')))
              .toList()),
    );
  }

  Widget _buildLoadingWidget(BuildContext context) {
    return SizedBox(
        height: 400,
        width: MediaQuery.of(context).size.width,
        child: const Center(child: Loading()));
  }

  filterButtons() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                  key: _shiftKey,
                  onPressed: () {
                    final RenderBox renderBox = _shiftKey.currentContext
                        ?.findRenderObject() as RenderBox;
                    final Size size = renderBox.size;
                    final Offset offset = renderBox.localToGlobal(Offset.zero);
                    showMenu(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      constraints: const BoxConstraints(maxWidth: 150),
                      context: context,
                      position: RelativeRect.fromLTRB(
                          offset.dx,
                          offset.dy + size.height,
                          offset.dx + size.width,
                          offset.dy + size.height),
                      items: shifts.map((String shiftList) {
                        return PopupMenuItem(
                          padding: const EdgeInsets.all(0),
                          value: shiftList,
                          child: RadioListTile(
                              title: Text(shiftList,
                                  style: const TextStyle(fontSize: 14)),
                              value: shiftList,
                              groupValue: shift,
                              onChanged: (value) {
                                Navigator.pop(context);
                                filteringBloc!
                                    .add(ShiftFilter(value.toString()));
                                monthButtonPressed = false;
                                dayButtonPressed = false;
                                month = '';
                                shift = value.toString();
                                if (shift == 'All') {
                                  shiftButtonPressed = false;
                                } else {
                                  shiftButtonPressed = true;
                                }
                                setState(() {});
                              }),
                        );
                      }).toList(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !shiftButtonPressed ? white : blueButtonColor,
                      minimumSize: const Size(108, 40),
                      side: BorderSide(
                          width: 2.0,
                          color: !shiftButtonPressed
                              ? const Color(0xffAFB0B6)
                              : blueButtonColor),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                  child: Text(
                    !shiftButtonPressed
                        ? (shifts.length > 1 ? 'By Shift' : 'By All')
                        : shift,
                    style: !shiftButtonPressed
                        ? const TextStyle(color: Color(0xffAFB0B6))
                        : const TextStyle(color: Color(0xffFFFFFF)),
                  )),
              ElevatedButton(
                  key: _monthKey,
                  onPressed: () {
                    final RenderBox renderBox = _monthKey.currentContext
                        ?.findRenderObject() as RenderBox;
                    final Size size = renderBox.size;
                    final Offset offset = renderBox.localToGlobal(Offset.zero);
                    showMenu(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        context: context,
                        position: RelativeRect.fromLTRB(
                            offset.dx,
                            offset.dy + size.height,
                            offset.dx + size.width,
                            offset.dy + size.height),
                        constraints:
                            const BoxConstraints(maxWidth: 200, maxHeight: 400),
                        items: months.map((String monthList) {
                          return PopupMenuItem(
                            padding: const EdgeInsets.all(0),
                            child: RadioListTile(
                                title: Text(monthList,
                                    style: const TextStyle(fontSize: 14)),
                                value: monthList,
                                groupValue: month,
                                onChanged: (value) {
                                  Navigator.pop(context);
                                  filteringBloc!
                                      .add(MonthFilter(value.toString()));
                                  setState(() {
                                    month = value.toString();
                                    monthButtonPressed = true;
                                  });
                                }),
                          );
                        }).toList());
                    setState(() {
                      shiftButtonPressed = false;
                      dayButtonPressed = false;
                      shift = '';
                      if (month.isEmpty) {
                        monthButtonPressed = false;
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !monthButtonPressed ? white : blueButtonColor,
                      minimumSize: const Size(108, 40),
                      side: BorderSide(
                          width: 2.0,
                          color: !monthButtonPressed
                              ? const Color(0xffAFB0B6)
                              : blueButtonColor),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                  child: Text(
                    !monthButtonPressed ? 'By Month' : month,
                    style: !monthButtonPressed
                        ? const TextStyle(color: Color(0xffAFB0B6))
                        : const TextStyle(color: Color(0xffFFFFFF)),
                  )),
              ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2022),
                        lastDate: DateTime.now());
                    if (pickedDate != null) {
                      String formattedDate =
                          DateFormat('dd/MM/yyyy').format(pickedDate);
                      selectedDate = formattedDate;
                      if (!mounted) return;
                      filteringBloc!.add(DateFilter(selectedDate));
                      setState(() {
                        dayButtonPressed = !dayButtonPressed;
                        monthButtonPressed = false;
                        shiftButtonPressed = false;
                        shift = '';
                        month = '';
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !dayButtonPressed ? white : blueButtonColor,
                      minimumSize: const Size(108, 40),
                      side: BorderSide(
                          width: 2.0,
                          color: !dayButtonPressed
                              ? const Color(0xffAFB0B6)
                              : blueButtonColor),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                  child: Text(
                    !dayButtonPressed ? 'By Date' : selectedDate,
                    style: !dayButtonPressed
                        ? const TextStyle(color: Color(0xffAFB0B6))
                        : const TextStyle(color: Color(0xffFFFFFF)),
                  )),
            ],
          ),
        )
      ],
    );
  }

  // empty screen
  _buildEmptyListWidget() {
    return Center(
      child: Text(
        translation(context).recordsNotFound,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  // history details screen
  _buildAttendanceHistoryWidget(BuildContext historyContext) {
    return Expanded(
        child: Column(children: [
      const SizedBox(height: 10),
      _buildOrganizationWidget(),
      Expanded(
          child: attendanceHistory != null && attendanceHistory!.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  controller: scrollController,
                  itemCount: !isLastPost
                      ? attendanceHistory!.length + 1
                      : attendanceHistory!.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == attendanceHistory!.length) {
                      return isLastPost
                          ? const SizedBox()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                  Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      height: 40,
                                      width: 40,
                                      child: const Loading())
                                ]);
                    } else {
                      return _buildAttendanceHistoryItemWidget(
                          attendanceHistory![index]);
                    }
                  },
                )
              : _buildEmptyListWidget())
    ]));
  }

  Widget _buildAttendanceHistoryItemWidget(
      AttendanceHistroy attendanceHistory) {
    User? user = attendanceHistory.user;

    String userName = user == null
        ? translation(context).userNotFound
        : ConvertionUtil.convertSingleName(user.firstName!, user.lastName!);

    return Card(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
        child: ListTile(
            title: Text(
              userName,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: brightBGColor,
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            attendanceHistory.clockIn != null &&
                                    attendanceHistory.clockIn!.isNotEmpty
                                ? ConvertionUtil.convertLocalDateFromString(
                                    attendanceHistory.clockIn!)
                                : '--',
                            style: const TextStyle(
                              color: darkTextColor,
                              fontSize: 14.0,
                            ),
                          ),
                          Text(
                            attendanceHistory.clockIn != null &&
                                    attendanceHistory.clockIn!.isNotEmpty
                                ? ConvertionUtil.convertLocalTimeFromString(
                                    ConvertionUtil.convertToUTCWithZ(
                                        attendanceHistory.clockIn!))
                                : '--',
                            style: const TextStyle(
                              color: greyTextColor,
                              fontSize: 12.0,
                            ),
                          ),
                          Text(
                            attendanceHistory.clockOut != null &&
                                    attendanceHistory.clockOut!.isNotEmpty
                                ? ConvertionUtil.convertLocalTimeFromString(
                                    ConvertionUtil.convertToUTCWithZ(
                                        attendanceHistory.clockOut!))
                                : '--',
                            style: const TextStyle(
                              color: greyTextColor,
                              fontSize: 12.0,
                            ),
                          ),
                          Text(
                            attendanceHistory.clockOut != null &&
                                    attendanceHistory.clockOut!.isNotEmpty
                                ? ConvertionUtil.calculateBetweenDuration(
                                    attendanceHistory.clockIn!,
                                    attendanceHistory.clockOut!)
                                : '--',
                            style: const TextStyle(
                              color: darkTextColor,
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                      if (attendanceHistory.clockOutReason != null &&
                          attendanceHistory.clockOutReason!.isNotEmpty)
                        Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                                '${translation(context).reason}: ${attendanceHistory.clockOutReason}',
                                style: const TextStyle(
                                    color: darkTextColor, fontSize: 14.0)))
                    ]))));
  }
}
