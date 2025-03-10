import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/presentation/widgets/widgets.dart';

import '../../../utils/colors/colors.dart';

class ExpandableText extends StatefulWidget {
  const ExpandableText(
    this.text, {
    super.key,
    this.trimLines = 2,
  }) : assert(text != null);

  final String? text;
  final int trimLines;

  @override
  ExpandableTextState createState() => ExpandableTextState();
}

class ExpandableTextState extends State<ExpandableText> {
  bool _readMore = true;

  void _onTapLink() {
    setState(() => _readMore = !_readMore);
  }

  void _onTapUrl(String url) async {
    launchURL(url);
  }

  @override
  Widget build(BuildContext context) {
    const colorClickableText = primaryColor;
    const widgetColor = black;
    TextStyle textStyle = TextStyle(
      fontFamily: 'Arial',
      fontWeight: FontWeight.w500,
      color: widgetColor,
      fontSize: 12.sp,
    );

    TextSpan readMoreSpan = TextSpan(
      text: _readMore
          ? translation(context).readMore
          : translation(context).readLess,
      style: const TextStyle(
        color: colorClickableText,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w500,
      ),
      recognizer: TapGestureRecognizer()..onTap = _onTapLink,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final double maxWidth = constraints.maxWidth;

        final processedText = _processText(widget.text ?? '', textStyle);

        TextPainter linkPainter = TextPainter(
          text: readMoreSpan,
          textDirection: TextDirection.rtl,
          maxLines: widget.trimLines,
          ellipsis: '...',
        );
        linkPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final linkSize = linkPainter.size;

        TextPainter textPainter = TextPainter(
          text: processedText,
          textDirection: TextDirection.ltr,
          maxLines: widget.trimLines,
          ellipsis: '...',
        );
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);

        final textSize = textPainter.size;

        int? endIndex;
        final pos = textPainter.getPositionForOffset(
          Offset(textSize.width - linkSize.width, textSize.height),
        );
        endIndex = textPainter.getOffsetBefore(pos.offset) ?? 0;
        String subStringText = widget.text!.substring(0, endIndex);

        final processedSubStringText = _processText(subStringText, textStyle);

        TextSpan finalSpan;

        if (textPainter.didExceedMaxLines) {
          finalSpan = TextSpan(
            children: _readMore
                ? [
                    processedSubStringText,
                    readMoreSpan,
                  ]
                : [
                    processedText,
                    readMoreSpan,
                  ],
          );
        } else {
          finalSpan = processedText;
        }
        return RichText(
          softWrap: true,
          overflow: TextOverflow.clip,
          text: finalSpan,
        );
      },
    );
  }

  TextSpan _processText(String text, TextStyle textStyle) {
    final linkRegex = RegExp(
        r'((https?:\/\/)?(www\.)?[a-zA-Z0-9._-]+\.[a-zA-Z]{2,})(\/\S*)?');
    final matches = linkRegex.allMatches(text);
    final spans = <TextSpan>[];

    int start = 0;

    for (final match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(
          text: text.substring(start, match.start),
          style: textStyle,
        ));
      }

      final linkText = text.substring(match.start, match.end);
      spans.add(TextSpan(
        text: linkText,
        style: textStyle.copyWith(
            color: blueLinkColor, decoration: TextDecoration.underline),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            final url =
                linkText.startsWith('http') ? linkText : 'https://$linkText';
            _onTapUrl(url);
          },
      ));

      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: textStyle,
      ));
    }

    return TextSpan(children: spans);
  }
}
