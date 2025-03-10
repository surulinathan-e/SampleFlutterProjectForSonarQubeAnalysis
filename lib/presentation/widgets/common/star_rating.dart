import 'package:flutter/material.dart';

import '../../../utils/colors/colors.dart';

typedef RatingChangeCallback = void Function(double rating);

class StarRating extends StatelessWidget {
  final int starCount;
  final double rating;
  final RatingChangeCallback? onRatingChanged;
  final Color color;
  final double iconSize;
  final double paddingValue;

  const StarRating(
      {super.key,
      this.starCount = 5,
      this.rating = .0,
      required this.onRatingChanged,
      this.color = primaryColor,
      this.iconSize = 30,
      this.paddingValue = 5});

  Widget buildStar(BuildContext context, int index) {
    return Tooltip(
      message: "${index + 1} of 5",
      child: InkWell(
        onTap: onRatingChanged != null
            ? () {
                onRatingChanged!(rating == (index + 1).toDouble()
                    ? index.toDouble()
                    : (index + 1).toDouble());
              }
            : null,
        child: Padding(
          padding: EdgeInsets.all(paddingValue),
          child: Icon(
            index < rating
                ? index > rating - 1 && index < rating
                    ? Icons.star_half
                    : Icons.star
                : Icons.star_border,
            color: index < rating ? color : null,
            size: iconSize,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        children:
            List.generate(starCount, (index) => buildStar(context, index)));
  }
}
