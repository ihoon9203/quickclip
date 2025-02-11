import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quick_clip/utils/stylesheet.dart';

class TextChip extends StatelessWidget {
  final String text;
  final Function onPressedAction;
  const TextChip({super.key, required this.text, required this.onPressedAction});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressedAction();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Stylesheet.labelPrimaryColor,
            width: 1,
          )
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Stylesheet.labelPrimaryColor,
            fontSize: 20,
          ),
        ),
      )
    );
  }
}