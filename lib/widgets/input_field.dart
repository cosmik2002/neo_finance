import 'package:flutter/material.dart';
import 'package:neo_finance/constants/theme.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InputField extends StatelessWidget {
  final String label;
  final String? hint;
  final bool? isAmount;
  final TextEditingController? controller;
  final Widget? widget;
  final bool focus;
  final void Function(String)? onChanged;
  InputField({
    Key? key,
    this.hint,
    required this.label,
    this.isAmount = false,
    this.controller,
    this.widget,this.focus = false, this.onChanged
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 14.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Themes().labelStyle,
          ),
          Container(
            height: 48.h, //24.sp,
            margin: EdgeInsets.only(
              top: 6.h,
            ),
            padding: EdgeInsets.only(
              left: 14.w,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1.w,
              ),
              borderRadius: BorderRadius.circular(
                5.r,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType:
                        isAmount! ? TextInputType.number : TextInputType.text,
                    // readOnly: widget == null ? false : true,
                    autofocus: focus,
                    cursorColor: Get.isDarkMode
                        ? Colors.grey.shade100
                        : Colors.grey.shade700,
                    controller: controller,
                    style: Themes().labelStyle,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: hint,
                        hintStyle: Themes().labelStyle),
                    onChanged: onChanged,
                  ),
                ),
                widget == null
                    ? Container()
                    : Container(
                        child: widget,
                      )
              ],
            ),
          )
        ],
      ),
    );
  }
}
