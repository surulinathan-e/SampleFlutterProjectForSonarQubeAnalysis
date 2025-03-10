import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/colors/colors.dart';

class ChipListWidget<T> extends StatefulWidget {
  final String? heading;
  final List<T>? list;
  final ValueChanged<T>? onSelected;
  final bool? isSelected;
  const ChipListWidget(
      {super.key,
      this.heading,
      @required this.list,
      this.onSelected,
      this.isSelected});

  @override
  State<ChipListWidget<T>> createState() => _ChipListWidgetState();
}

class _ChipListWidgetState<T> extends State<ChipListWidget<T>> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          if (widget.heading != null) _buildHeading(widget.heading),
          const SizedBox(height: 10),
          if (widget.list != null)
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              runSpacing: 8,
              spacing: 8,
              children: widget.list!
                  .map((listItem) => _buildListItem(listItem))
                  .toList(),
            )
        ],
      ),
    );
  }

  Widget _buildListItem(listItem) {
    return GestureDetector(
      onTap: () {
        if (widget.onSelected != null) {
          widget.onSelected?.call(listItem);
        }
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.r),
            color: listItem.isSelected!
                ? secondaryColor.withValues(alpha: .4)
                : white),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 6),
          child: Text(
            listItem.name!.trim(),
            style: TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
                color: black),
          ),
        ),
      ),
    );
  }

  Widget _buildHeading(title) {
    return Text(title,
        style: TextStyle(
            color: black,
            fontSize: 14.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500));
  }
}
