import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DefaultButton extends StatefulWidget {
  final String? text;
  final Color btnColor;
  final Function()? press;

  const DefaultButton({
    super.key,
    this.text,
    this.btnColor = Colors.grey,
    this.press,
  });

  @override
  State<DefaultButton> createState() => _DefaultButtonState();
}

class _DefaultButtonState extends State<DefaultButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      child: TextButton(
        style: TextButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: widget.btnColor,
        ),
        onPressed: widget.press,
        child: Text(
          widget.text!,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}