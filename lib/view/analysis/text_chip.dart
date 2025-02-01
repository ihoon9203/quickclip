import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextChip extends StatelessWidget {
  final String text;
  final Function onPressedAction;
  const TextChip({super.key, required this.text, required this.onPressedAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.yellowAccent,
          fontSize: 20,
        ),
      ),
    );
  }
}