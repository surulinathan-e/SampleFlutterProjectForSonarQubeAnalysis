import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/data/model/organization.dart';
import 'package:tasko/data/model/shift.dart';
import 'package:tasko/data/model/user_details_data_store.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class CreateShiftScreen extends StatefulWidget {
  final Shift? shift;
  const CreateShiftScreen({super.key, this.shift});

  @override
  State<CreateShiftScreen> createState() => _CreateShiftScreenState();
}

class _CreateShiftScreenState extends State<CreateShiftScreen> {
  //controllers
  TextEditingController? _shiftNameController;
  TextEditingController? _shiftInTimeController;
  TextEditingController? _shiftOutTimeController;

  //focusNode
  FocusNode? _shiftNameFocusNode;
  FocusNode? _shiftInTimeFocusNode;
  FocusNode? _shiftOutTimeFocusNode;
  FocusNode? _submitFocusNode;
  FocusNode? _startDateFocusNode;
  FocusNode? _endDateFocusNode;

  //formKey
  final _formKey = GlobalKey<FormState>();
  AdminBloc? adminBloc;

  String? selectedOrganization, selectedStartDate, selectedEndDate;
  List<Organization>? organizations;
  DateTime? selectedStartTime;
  DateTime? selectedEndTime;
  Shift? shift;

  String? existingShiftName, existingStartDate, existingEndDate;
  DateTime? existingInTime;
  DateTime? existingOutTime;
  bool? isAllDays;
  bool? isUpdatedAllDays;
  List multipleSelected = [];
  TextEditingController? _startDateController, _endDateController;

  List workingDays = [
    {
      'value': false,
      'day': 'Sunday',
    },
    {
      'value': false,
      'day': 'Monday',
    },
    {
      'value': false,
      'day': 'Tuesday',
    },
    {
      'value': false,
      'day': 'Wednesday',
    },
    {
      'value': false,
      'day': 'Thursday',
    },
    {
      'value': false,
      'day': 'Friday',
    },
    {
      'value': false,
      'day': 'Saturday',
    }
  ];

  @override
  void initState() {
    super.initState();
    adminBloc = BlocProvider.of<AdminBloc>(context);
    organizations = UserDetailsDataStore.getUserOrganizations!;

    //controllers
    _shiftNameController = TextEditingController();
    _shiftInTimeController = TextEditingController();
    _shiftOutTimeController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();

    //focusNodes
    _shiftNameFocusNode = FocusNode();
    _shiftInTimeFocusNode = FocusNode();
    _shiftOutTimeFocusNode = FocusNode();
    _submitFocusNode = FocusNode();

    shift = widget.shift;
    isAllDays = false;
    isUpdatedAllDays = isAllDays;
    checkShiftDetails();
  }

  checkShiftDetails() {
    if (shift != null) {
      _shiftNameController!.text = shift!.shiftName!;
      _shiftInTimeController!.text = ConvertionUtil.convertLocalTimeFromString(
          ConvertionUtil.convertToUTCWithZ(shift!.shiftStartTiming));
      _shiftOutTimeController!.text = ConvertionUtil.convertLocalTimeFromString(
          ConvertionUtil.convertToUTCWithZ(shift!.shiftEndTiming));
      _startDateController!.text =
          ConvertionUtil.convertLocalDateMonthYearString(
              shift!.shiftStartDate ?? '');
      _endDateController!.text = ConvertionUtil.convertLocalDateMonthYearString(
          shift!.shiftEndDate ?? '');
      workingDays[0]['value'] = shift!.sunday;
      workingDays[1]['value'] = shift!.monday;
      workingDays[2]['value'] = shift!.tuesday;
      workingDays[3]['value'] = shift!.wednesday;
      workingDays[4]['value'] = shift!.thursday;
      workingDays[5]['value'] = shift!.friday;
      workingDays[6]['value'] = shift!.saturday;

      if (workingDays.any((element) => element['value'] == false)) {
        isUpdatedAllDays = isAllDays = false;
      } else {
        isUpdatedAllDays = isAllDays = true;
      }

      existingShiftName = _shiftNameController!.text;
      existingInTime = DateTime.parse(
          ConvertionUtil.convertToUTCWithZ(shift!.shiftStartTiming));
      existingOutTime = DateTime.parse(
          ConvertionUtil.convertToUTCWithZ(shift!.shiftEndTiming));
      existingStartDate = shift!.shiftStartDate ?? '';
      existingEndDate = shift!.shiftEndDate ?? '';
      selectedStartTime = existingInTime;
      selectedEndTime = existingOutTime;
      selectedStartDate = existingStartDate;
      selectedEndDate = existingEndDate;
    }
  }

  @override
  void dispose() {
    super.dispose();
    //controllers
    _shiftNameController!.dispose();
    _shiftInTimeController!.dispose();
    _shiftOutTimeController!.dispose();

    //focusNodes
    _shiftNameFocusNode!.dispose();
    _shiftInTimeFocusNode!.dispose();
    _shiftOutTimeFocusNode!.dispose();
    _submitFocusNode!.dispose();
  }

  Future<void> _selectedStartDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _startDateController!.text =
            DateFormat('dd-MM-yyyy').format(pickedDate);
        selectedStartDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _selectedEndDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _endDateController!.text = DateFormat('dd-MM-yyyy').format(pickedDate);
        selectedEndDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bgColor,
        resizeToAvoidBottomInset: false,
        body: BlocListener<AdminBloc, AdminState>(
            bloc: adminBloc,
            listener: (context, state) {
              if (state is CreateShiftSuccess) {
                Navigator.pop(context);
                _clearTextData();
                showAlertSnackBar(context, translation(context).shiftAdded,
                    AlertType.success);
                Navigator.of(context).pop(true);
              } else if (state is CreateShiftFailed) {
                Navigator.pop(context);
                showAlertSnackBar(context, state.errorMessage, AlertType.error);
              } else if (state is UpdateShiftFailed) {
                Navigator.pop(context);
                showAlertSnackBar(context, state.errorMessage, AlertType.error);
              } else if (state is UpdateShiftSuccess) {
                Navigator.pop(context);
                showAlertSnackBar(context,
                    translation(context).shiftUpdateSuccess, AlertType.success);
                Navigator.of(context).pop(true);
              }
            },
            child: BlocBuilder<AdminBloc, AdminState>(
                bloc: adminBloc,
                builder: (context, state) {
                  return Stack(children: [
                    bGMainMini(),
                    SingleChildScrollView(child: _buildBodyContentWidget())
                  ]);
                })));
  }

  //login frm
  Widget _buildBodyContentWidget() {
    return Form(
        key: _formKey,
        child: Column(children: [
          SizedBox(height: 20.h),
          Align(
              alignment: Alignment.topLeft,
              child: goBack(() => {Navigator.of(context).pop()})),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              shift == null
                  ? translation(context).createShift
                  : translation(context).updateShift,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600),
            ),
          ),
          sizedBoxHeight_20(),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(children: [
                sizedBoxHeight_20(),
                shift == null ? _buildOrganizationWidget() : const SizedBox(),
                shift == null ? sizedBoxHeight_10() : const SizedBox(),
                _buildShiftNameWidget(),
                sizedBoxHeight_10(),
                _buildShiftStartDateWidget(),
                sizedBoxHeight_10(),
                _buildShiftEndDateWidget(),
                sizedBoxHeight_10(),
                _buildShiftInTimeWidget(),
                sizedBoxHeight_10(),
                _buildShiftOutTimeWidget(),
                sizedBoxHeight_10(),
                _buildIsAllDays(),
                _buildShiftWorkingDaysWidget(),
                _buildSubmitBtn()
              ]))
        ]));
  }

  Widget _buildOrganizationWidget() {
    return DropdownButtonFormField(
        hint: Text(translation(context).selectOrganisation),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(left: 20, right: 20),
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
        validator: (value) =>
            value == null ? translation(context).selectOrganisation : null,
        dropdownColor: Colors.white,
        value: selectedOrganization,
        onChanged: (String? newValue) {
          setState(() {
            selectedOrganization = newValue;
          });
        },
        items: organizations!
            .map((organization) => DropdownMenuItem(
                value: '${organization.id}',
                child: Text('${organization.name}')))
            .toList());
  }

  Widget _buildShiftNameWidget() {
    return TextFormField(
      focusNode: _shiftNameFocusNode,
      enabled: true,
      textInputAction: TextInputAction.next,
      controller: _shiftNameController,
      keyboardType: TextInputType.name,
      enableSuggestions: true,
      autocorrect: true,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10.0),
        prefixIcon: const Icon(
          Icons.verified_user_outlined,
          color: darkTextColor,
        ),
        hintText: translation(context).shiftName,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(color: grayBorderColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return translation(context).enterShiftName;
        }
        return null;
      },
      onFieldSubmitted: (term) {
        _shiftNameFocusNode!.unfocus();
        FocusScope.of(context).requestFocus(_shiftInTimeFocusNode);
      },
    );
  }

  Widget _buildShiftStartDateWidget() {
    return TextFormField(
        controller: _startDateController,
        focusNode: _startDateFocusNode,
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10.0),
            prefixIcon: const Icon(
              Icons.calendar_month_rounded,
              color: darkTextColor,
            ),
            hintText: translation(context).shiftStartDate,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: grayBorderColor, width: 2)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: darkBorderColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: darkBorderColor))),
        validator: (value) {
          if (value!.isEmpty) {
            return translation(context).pleaseSelectStartDate;
          }
          return null;
        },
        readOnly: true,
        onTap: () async {
          _selectedStartDate(context);
        });
  }

  Widget _buildShiftEndDateWidget() {
    return TextFormField(
        controller: _endDateController,
        focusNode: _endDateFocusNode,
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10.0),
            prefixIcon:
                const Icon(Icons.calendar_month_rounded, color: darkTextColor),
            hintText: translation(context).shiftEndDate,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: grayBorderColor, width: 2)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: darkBorderColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: darkBorderColor))),
        validator: (value) {
          if (value!.isEmpty) {
            return translation(context).pleaseSelectEndDate;
          }
          return null;
        },
        readOnly: true,
        onTap: () async {
          _selectedEndDate(context);
        });
  }

  Widget _buildShiftInTimeWidget() {
    return TextFormField(
        controller: _shiftInTimeController,
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10.0),
            prefixIcon: const Icon(Icons.timer_outlined, color: darkTextColor),
            hintText: translation(context).startTime,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: grayBorderColor, width: 2)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: darkBorderColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: darkBorderColor))),
        validator: (value) {
          if (value!.isEmpty) {
            return translation(context).enterShiftStartTime;
          }
          return null;
        },
        readOnly: true,
        onTap: () async {
          TimeOfDay time = TimeOfDay.now();

          TimeOfDay? picked =
              await showTimePicker(context: context, initialTime: time);
          if (picked != null) {
            _shiftInTimeController!.text = picked.toString();
            var now = DateTime.now();
            selectedStartTime = DateTime(
                now.year, now.month, now.day, picked.hour, picked.minute);
            _shiftInTimeController!.text =
                ConvertionUtil.convertLocalTimeFromString(
                    selectedStartTime.toString());
            setState(() {});
          }
        });
  }

  Widget _buildShiftOutTimeWidget() {
    return TextFormField(
        controller: _shiftOutTimeController,
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10.0),
            prefixIcon: const Icon(Icons.timer_outlined, color: darkTextColor),
            hintText: translation(context).endTime,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: grayBorderColor, width: 2)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: darkBorderColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: darkBorderColor))),
        validator: (value) {
          if (value!.isEmpty) {
            return translation(context).enterShiftEndTime;
          }
          return null;
        },
        readOnly: true,
        onTap: () async {
          TimeOfDay time = TimeOfDay.now();

          TimeOfDay? picked =
              await showTimePicker(context: context, initialTime: time);
          if (picked != null) {
            _shiftOutTimeController!.text = picked.toString();
            var now = DateTime.now();
            selectedEndTime = DateTime(
                now.year, now.month, now.day, picked.hour, picked.minute);
            _shiftOutTimeController!.text =
                ConvertionUtil.convertLocalTimeFromString(
                    selectedEndTime.toString());
            setState(() {});
          }
        });
  }

  Widget _buildIsAllDays() {
    return CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        activeColor: primaryColor,
        title: const Text('All Days'),
        value: isUpdatedAllDays,
        onChanged: (value) {
          setState(() {
            isUpdatedAllDays = value!;
            for (var day in workingDays) {
              day['value'] = isUpdatedAllDays;
            }
          });
        },
        controlAffinity: ListTileControlAffinity.leading);
  }

  Widget _buildShiftWorkingDaysWidget() {
    return SizedBox(
        height: MediaQuery.of(context).size.height / 4,
        child: GridView.builder(
            itemCount: workingDays.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 4),
            itemBuilder: (context, index) {
              return CheckboxListTile(
                  activeColor: primaryColor,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(workingDays[index]['day'],
                      style: const TextStyle(fontSize: 16.0, color: black)),
                  value: workingDays[index]['value'],
                  onChanged: (value) {
                    setState(() {
                      workingDays[index]['value'] = value;
                      if (multipleSelected.contains(workingDays[index])) {
                        multipleSelected.remove(workingDays[index]);
                      } else {
                        multipleSelected.add(workingDays[index]);
                      }
                    });
                  });
            }));
  }

  //final submit btn
  Widget _buildSubmitBtn() {
    return BlocBuilder(
        bloc: adminBloc,
        builder: (context, state) {
          if (state is GetUsersOrganizationLoading) {
            return const Loading();
          } else {
            return showSubmitBtn();
          }
        });
  }

  //submit btn
  Widget showSubmitBtn() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(23.0))),
        focusNode: _submitFocusNode,
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            if (multipleSelected.isNotEmpty ||
                workingDays.any((element) => element['value'] == true)) {
              if (selectedStartTime == selectedEndTime) {
                showAlertSnackBar(
                    context,
                    translation(context).startTimeEndTimeAlert,
                    AlertType.error);
              } else if (shift == null) {
                progress(context);
                _shiftNameFocusNode!.unfocus();
                _shiftInTimeFocusNode!.unfocus();
                _shiftOutTimeFocusNode!.unfocus();
                FocusScope.of(context).requestFocus(_submitFocusNode);
                _formKey.currentState!.save();
                adminBloc!.add(CreateShift(
                    selectedOrganization!,
                    _shiftNameController!.text.trim(),
                    selectedStartDate ?? '',
                    selectedEndDate ?? '',
                    selectedStartTime!.toUtc(),
                    selectedEndTime!.toUtc(),
                    workingDays[0]['value'],
                    workingDays[1]['value'],
                    workingDays[2]['value'],
                    workingDays[3]['value'],
                    workingDays[4]['value'],
                    workingDays[5]['value'],
                    workingDays[6]['value']));
              } else {
                if (selectedStartTime == selectedEndTime) {
                  showAlertSnackBar(
                      context,
                      translation(context).startTimeEndTimeAlert,
                      AlertType.error);
                } else if (workingDays
                    .every((element) => element['value'] == false)) {
                  showAlertSnackBar(context,
                      translation(context).shiftWorkingDay, AlertType.info);
                } else if (existingShiftName != _shiftNameController!.text ||
                    existingInTime != selectedStartTime ||
                    existingOutTime != selectedEndTime ||
                    existingEndDate != selectedEndDate ||
                    existingStartDate != selectedStartDate ||
                    shift!.sunday != workingDays[0]['value'] ||
                    shift!.monday != workingDays[1]['value'] ||
                    shift!.tuesday != workingDays[2]['value'] ||
                    shift!.wednesday != workingDays[3]['value'] ||
                    shift!.thursday != workingDays[4]['value'] ||
                    shift!.friday != workingDays[5]['value'] ||
                    shift!.saturday != workingDays[6]['value']) {
                  progress(context);
                  _shiftNameFocusNode!.unfocus();
                  _shiftInTimeFocusNode!.unfocus();
                  _shiftOutTimeFocusNode!.unfocus();
                  FocusScope.of(context).requestFocus(_submitFocusNode);
                  _formKey.currentState!.save();
                  adminBloc!.add(UpdateShift(
                      shift!.id!,
                      shift!.organizationId!,
                      _shiftNameController!.text.trim(),
                      selectedStartDate ?? '',
                      selectedEndDate ?? '',
                      selectedStartTime!.toUtc(),
                      selectedEndTime!.toUtc(),
                      workingDays[0]['value'],
                      workingDays[1]['value'],
                      workingDays[2]['value'],
                      workingDays[3]['value'],
                      workingDays[4]['value'],
                      workingDays[5]['value'],
                      workingDays[6]['value']));
                } else {
                  showAlertSnackBar(context,
                      translation(context).noUpdateChanges, AlertType.info);
                }
              }
            } else {
              showAlertSnackBar(context, translation(context).shiftWorkingDay,
                  AlertType.info);
            }
          }
        },
        child: Text(translation(context).submit,
            style: TextStyle(
                color: brightTextColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600)));
  }

  void _clearTextData() {
    _shiftNameController!.clear();
    _shiftInTimeController!.clear();
    _shiftOutTimeController!.clear();
    isUpdatedAllDays = false;
    for (var day in workingDays) {
      day['value'] = false;
    }
  }
}
