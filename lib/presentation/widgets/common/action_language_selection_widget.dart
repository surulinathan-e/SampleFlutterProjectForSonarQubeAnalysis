import 'package:flutter/material.dart';
import 'package:tasko/utils/colors/colors.dart';

import '../../../data/classes/language.dart';
import '../../../data/classes/language_constant.dart';
import '../../../main.dart';

Widget buildLanguageSectionWidget(BuildContext context,
    {String? toolTipMessage = 'Translate'}) {
  return PopupMenuButton<Language>(
    tooltip: toolTipMessage,
    icon: Image.asset('assets/images/language_icon.png',
        height: 24, width: 24, color: greyIconColor),
    onSelected: (Language language) async {
      await setLocale(language.code);
      if (context.mounted) {
        MyApp.setLocale(context, Locale(language.code));
      }
    },
    itemBuilder: (BuildContext context) => Language.languageList()
        .map((language) =>
            PopupMenuItem(value: language, child: Text(language.name)))
        .toList(),
  );
}
