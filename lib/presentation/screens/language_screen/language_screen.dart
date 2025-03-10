import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasko/data/classes/language.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/main.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  int? selectedIndex;
  Language? language;
  String? languageCode;
  List<Language> languageList = [
    Language(1, "English", "en"),
    Language(2, "Spanish", "es"),
    Language(3, "French", "fr"),
    Language(4, "Italian", "it"),
    Language(5, "Portuguese", "pt"),
  ];
  bool selectedLanguage = false;

  @override
  void initState() {
    getExisitingLanguage();
    super.initState();
  }

  getExisitingLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.getString('languageCode') ?? "en";
    for (var language in languageList) {
      if (languageCode == language.code) {
        setState(() {
          selectedLanguage = language.isSelected = true;
        });
      }
    }
  }

  Future<void> saveLanguage(String code) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(),
      body: _buildBodyContent(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
        forceMaterialTransparency: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios)),
        title: Text(translation(context).language,
            style: TextStyle(
                fontFamily: 'Roboto',
                color: black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500)),
        elevation: 0,
        centerTitle: true,
        titleSpacing: 0);
  }

  Widget _buildBodyContent() {
    return SingleChildScrollView(
        child: Column(children: [
      ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: languageList.length,
          itemBuilder: (context, index) {
            return Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: greyTextColor.withValues(alpha: 0.8),
                            width: 1.0))),
                width: MediaQuery.of(context).size.width,
                child: RadioListTile(
                    title: Text(languageList[index].name),
                    value: languageList[index].isSelected,
                    activeColor: primaryColor,
                    groupValue: selectedLanguage,
                    onChanged: (value) {
                      setState(() {
                        for (var language in languageList) {
                          language.isSelected = false;
                        }
                        selectedIndex = index;
                        language = languageList[selectedIndex!];
                        languageList[selectedIndex!].isSelected = true;
                      });
                    }));
          }),
      SizedBox(height: 30.h),
      _buildSaveBtn(context, language)
    ]));
  }

  Widget _buildSaveBtn(BuildContext context, Language? language) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: primaryColor,
            minimumSize: Size(150.h, 40.h)),
        onPressed: () async {
          if (language != null && language.code != languageCode) {
            await saveLanguage(language.code);
            await setLocale(language.code);
            if (context.mounted) {
              MyApp.setLocale(context, Locale(language.code));
              Navigator.pop(context);
            }
          } else {
            showAlertSnackBar(
                context, translation(context).noChangesMade, AlertType.info);
          }
        },
        child: Text(translation(context).save,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Roboto',
                color: white,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold)));
  }
}
