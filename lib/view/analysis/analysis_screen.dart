import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:quick_clip/provider/analysis_provider.dart';
import 'package:quick_clip/service/shared_preference_service.dart';
import 'package:quick_clip/utils/stylesheet.dart';
import 'package:quick_clip/view/analysis/text_chip.dart';
import 'package:quick_clip/view/analysis/text_edit_dialog.dart';
import 'package:quick_clip/view/camera/display_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnalysisScreen extends StatefulWidget {
  final String? prefKey;
  final String originImagePath;
  final String croppedImagePath;
  final double cropWidth;
  final double cropHeight;
  final List<String> textlist;
  final int timestamp;
  final File image;
  final bool isNotStored;

  const AnalysisScreen({super.key, required this.textlist, required this.image, this.prefKey, required this.originImagePath, required this.croppedImagePath, required this.cropWidth, required this.cropHeight, required this.timestamp, required this.isNotStored});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  late List<String> _textlist;
  late AnalysisProvider provider;
  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _tmpTextEditingController = TextEditingController();
  bool willSaveOnDispose = true; // 삭제할 때 false됨

  @override
  void initState() {
    super.initState();
    _textlist = widget.textlist;
    _textEditingController = TextEditingController(text: _textlist.join(' '));
    provider = Provider.of<AnalysisProvider>(context, listen: false);
  }

  @override
  void dispose() {
    // 새로운 데이터거나 삭제를 안할 것이라면 저장시킴킴
    if (willSaveOnDispose && widget.isNotStored) {
      setPreferenceData();
    }
    super.dispose();
  }

  void showDeleteOption() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.bottomSlide,
      title: '삭제',
      desc: '이 분석 결과를 삭제하시겠습니까?',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        provider.removeDataByTimestamp(widget.timestamp);
        setState(() {
         willSaveOnDispose = false;
        });
        Navigator.of(context).pop();
      },
      btnOkText: '삭제',
      btnOkColor: Colors.red,
      btnCancelText: '취소',
      btnCancelColor: Colors.grey,
    ).show();
  }

  Future setPreferenceData() async {
    provider.setData(originImagePath: widget.originImagePath, croppedImagePath: widget.croppedImagePath, texts: _textlist, cropWidth: widget.cropWidth, cropLength: widget.cropHeight);
  }
  

  void _onTextEdit(String newText, int index) {
    setState(() {
      _textlist[index] = newText;
      _textEditingController.text = _textlist.join(' ');
    });
  }

  void onDelete(int index) {
    setState(() {
      _textlist.removeAt(index);
      _textEditingController.text = _textlist.join(' ');
    });
    Navigator.of(context).pop();
  }

  // 드래그 종료 후 아이템이 놓일 새로운 위치를 계산하는 함수
  int _calculateNewIndex(Offset offset) {
    // 위치 계산을 단순화한 예시입니다.
    double itemWidth = 100.0; // 각 아이템의 너비 (예시)
    int newIndex = (offset.dx / itemWidth).floor();
    newIndex = newIndex.clamp(0, _textlist.length - 1);
    return newIndex;
  }

  void _onTappedForEdit(int index) {
    _tmpTextEditingController.text = _textlist[index];
    showDialog(
      context: context,
      builder: (context) {
        return TextEditDialog(
          text: _textlist[index],
          index: index,
          onEdit: _onTextEdit,
          onDelete: onDelete,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Stylesheet.accentColor,
      appBar: AppBar(
        backgroundColor: Stylesheet.accentColor2,
        title: const Text('분석 결과'),
        actions: [
          IconButton(
            onPressed: () {
              showDeleteOption();
            },
            icon: const Icon(
              CupertinoIcons.delete,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 상단 이미지 표시
            Padding(
              padding: const EdgeInsets.all(20),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DisplayScreen(imagePath: widget.originImagePath, width: widget.cropWidth, height: widget.cropHeight),
                    ),
                  );
                },
                child: Image.file(widget.image)
              ),
            ),
              // Wrap을 사용한 드래그 앤 드롭 처리
            Wrap(
              spacing: 8,
              direction: Axis.horizontal,
              children: [
                ...List.generate(_textlist.length, (index) {
                  return Draggable<int>(
                    data: index,
                    feedback: Material(
                      color: Colors.transparent,
                      child: TextChip(
                        text: _textlist[index],
                        onPressedAction: () {
                          _onTappedForEdit(index);
                        },
                      ),
                    ),
                    onDragEnd: (data) {
                      // 만약 같은 포지션으로 드래그 되었다면
                      // if (!data.wasAccepted) {
                      //   _onTappedForEdit(index);
                      // };
                    },
                    childWhenDragging: Opacity(
                      opacity: 0.5,
                      child: TextChip(
                        text: _textlist[index],
                        onPressedAction: () {},
                      ),
                    ),
                    child: DragTarget<int>(
                      onWillAcceptWithDetails: (data) {
                        return true;
                      },
                      onAcceptWithDetails: (data) {
                        // 드래그된 아이템을 새로운 위치에 삽입
                        setState(() {
                          _textlist.insert(index, _textlist.removeAt(data.data));
                          _textEditingController.text = _textlist.join(' ');
                        });
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Material(
                          color: Colors.transparent,
                          child: TextChip(
                            text: _textlist[index],
                            onPressedAction: () {
                              _tmpTextEditingController.text = _textlist[index];
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return TextEditDialog(
                                    text: _textlist[index],
                                    index: index,
                                    onEdit: _onTextEdit,
                                    onDelete: onDelete,
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                })
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CupertinoTextField(
                maxLines: null,
                controller: _textEditingController,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                onTapOutside: (e) {
                  setState(() {
                    _textlist = _textEditingController.text.split(' ');
                  });
                  Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    await Clipboard.setData(
                        ClipboardData(text: _textEditingController.text));
                    Fluttertoast.showToast(msg: '클립보드에 복사되었습니다.');
                  },
                  child: CircleAvatar(
                    backgroundColor: Stylesheet.accentColor2,
                    child: const Icon(Icons.copy),
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
            const SizedBox(height: 50),
          ],
        )
      ),
    );
  }
}
