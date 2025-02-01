import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:quick_clip/utils/stylesheet.dart';

class TextEditDialog extends StatelessWidget {
  final String text;
  final int index;
  final Function(String, int) onEdit;
  final Function(int) onDelete;

  const TextEditDialog({
    super.key,
    required this.text,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });
  
  @override
  Widget build(BuildContext context) {
    var textEditingController = TextEditingController(text: text);
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          CupertinoTextField(
            controller: textEditingController,
            maxLines: 10,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: textEditingController.text));
                  Fluttertoast.showToast(msg: '클립보드에 복사되었습니다.');
                },
                child: CircleAvatar(
                  backgroundColor: Stylesheet.accentColor2,
                  child: const Icon(Icons.copy),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.redAccent)
                  ),
                  onPressed: () {
                    onDelete(index);
                  },
                  child: const Text('삭제', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.grey)
                  ),
                  onPressed: () {
                    onEdit(textEditingController.text, index);
                    Navigator.of(context).pop();
                  },
                  child: const Text('수정', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ),
            ]
          ),
        ],
      ),
    );
  }
}