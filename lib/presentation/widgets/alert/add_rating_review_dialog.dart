import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/utils.dart';
import '../common/star_rating.dart';

class AddRatingReviewDialog extends StatefulWidget {
  final Function? onSubmitPressed;
  final String? title;
  final String? writeReviewHint;
  final String? possitiveBtnText;
  final String? negativeBtnText;
  const AddRatingReviewDialog(
      {super.key,
      this.onSubmitPressed,
      this.title = 'Rating & Review',
      this.writeReviewHint = 'Write Review',
      this.possitiveBtnText = 'Submit',
      this.negativeBtnText = 'Cancel'});

  @override
  State<AddRatingReviewDialog> createState() => _AddRatingReviewDialogState();
}

class _AddRatingReviewDialogState extends State<AddRatingReviewDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController reviewController = TextEditingController();
  String? enteredUserReview;
  int rating = 0;

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return AlertDialog(
      scrollable: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      title: Text(
        widget.title!,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 18, color: black, fontWeight: FontWeight.w400),
      ),
      content: SizedBox(
        height: height * 0.35,
        width: width,
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              StarRating(
                rating: rating.toDouble(),
                onRatingChanged: (index) => {
                  setState(() {
                    rating = index.toInt();
                  })
                },
                paddingValue: 10,
              ),
              SizedBox(height: 10.h),
              Container(
                decoration: BoxDecoration(
                  borderRadius: borderRadius(),
                  color: white,
                ),
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: reviewController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 7,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      hintText: widget.writeReviewHint!,
                      hintStyle: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.w400),
                      errorMaxLines: 2),
                  onChanged: (value) {
                    setState(() {
                      enteredUserReview = value.trim();
                    });
                  },
                  validator: (value) {
                    return null;
                  },
                ),
              )
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: greyBorderColor,
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          child: Text(widget.negativeBtnText!,
              style: const TextStyle(color: white)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              FocusManager.instance.primaryFocus?.unfocus();
              widget.onSubmitPressed!(rating, reviewController.text.trim());
              if (rating > 0) {
                Navigator.of(context).pop();
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          child: Text(
            widget.possitiveBtnText!,
            style: const TextStyle(color: white),
          ),
        ),
      ],
    );
  }
}
