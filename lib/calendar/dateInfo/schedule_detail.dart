import 'package:OBSP_Project/calendar/dateInfo/pinmark.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


import '../../reservation/reading_json.dart';

Color selectedColor = const Color(0xFF800020);
class ScheduleDetailBottomSheet extends StatefulWidget {
  final Schedule schedule;
  final ScrollController scrollController;
  final Function(Color) onColorChanged;

  const ScheduleDetailBottomSheet({
    super.key,
    required this.schedule,
    required this.scrollController,
    required this.onColorChanged,
  });

  @override
  State<ScheduleDetailBottomSheet> createState() => _ScheduleDetailBottomSheetState();
}

class _ScheduleDetailBottomSheetState extends State<ScheduleDetailBottomSheet> {

  // memo 재설정에 관한 함수 및 변수
  TextEditingController _memoController = TextEditingController();

  late Schedule _editableSchedule;
  @override
  void initState() {
    super.initState();
    _editableSchedule = widget.schedule;
    _memoController.text = widget.schedule.memo;
    _loadLatestSchedule();
  }

  Future<void> _loadLatestSchedule() async {
    // 저장된 모든 일정 불러오기
    final schedules = await getAllSchedules();
    // 현재 일정과 일치하는 일정 찾기 (예: title + firstdate 기준)
    final updatedSchedule = schedules.firstWhere(
          (sch) =>
      sch.title == _editableSchedule.title &&
          sch.firstdate == _editableSchedule.firstdate,
      orElse: () => _editableSchedule,
    );

    // 상태 업데이트
    setState(() {
      _editableSchedule = updatedSchedule;
      _memoController.text = updatedSchedule.memo;
    });
  }

  Future<void> _saveMemo() async {
    // 저장소에 저장된 모든 일정 불러오기
    final schedules = await getAllSchedules();

    // 일정 목록에서 현재 일정 찾기
    final index = schedules.indexWhere((sch) =>
      sch.title == _editableSchedule.title &&
      sch.firstdate == _editableSchedule.firstdate);

    if (index != -1) {
      // memo만 변경된 복사본으로 대체
      final updatedSchedule = schedules[index].copyWith(memo: _memoController.text);
      schedules[index] = updatedSchedule;

      // 변경된 리스트 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('schedules_storage', jsonEncode(schedules));

      setState(() {
        _editableSchedule = updatedSchedule;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('메모가 저장되었습니다.')),
      );
    }
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }


  Color selectedColor = const Color(0xFF800020);
  void _showColorPickerDialog(BuildContext context) {
    final List<Color> presetColors = [
      Colors.red, Colors.redAccent, Colors.red.shade200, Colors.red.shade100, Colors.red.shade50,
      Colors.orange, Colors.orangeAccent, Colors.orange.shade200, Colors.orange.shade100, Colors.orange.shade50,
      Colors.yellow, Colors.yellowAccent, Colors.yellow.shade200, Colors.yellow.shade100, Colors.yellow.shade50,
      Colors.green, Colors.greenAccent, Colors.green.shade200, Colors.green.shade100, Colors.green.shade50,
      Colors.blue, Colors.blueAccent, Colors.blue.shade200, Colors.blue.shade100, Colors.blue.shade50,
      Colors.purple, Colors.purpleAccent, Colors.purple.shade200, Colors.purple.shade100, Colors.purple.shade50,
      Colors.black,
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('색상 선택'),
          content: SizedBox(
            width: 300,
            height: 400,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: presetColors.length,
              itemBuilder: (context, index) {
                final color = presetColors[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = color;
                    });
                    widget.onColorChanged(color);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
      child: SingleChildScrollView(
        controller: widget.scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text( // 선택한 일정 제목
                  widget.schedule.title,
                  style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showColorPickerDialog(context),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                      ),
                    ),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded),
                  onPressed: () async {
                    await deleteSchedule(widget.schedule);
                    if (context.mounted) {
                      Navigator.pop(context, true);
                    }
                  },)],
                )
              ],
            ),

            Divider(),
            const SizedBox(height: 30,),

            // FirstDate -> LastDate
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start ,
                    children: [
                      Icon(Icons.access_time),
                      SizedBox(width: 10,),
                      Text(
                        "기간",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),
                      )
                    ],
                  ),
                  Divider(),
                  SizedBox(height: 15,),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly ,
                      children: [
                        Column(
                          children: [
                            Text(
                              DateFormat('MM월 dd일 (E)', 'ko_KR').format(DateTime.parse(widget.schedule.firstdate)),
                              style: const TextStyle(fontSize: 15),
                            ),
                            Text(
                              DateFormat('HH:mm', 'ko_KR').format(DateTime.parse(widget.schedule.firstdate)),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        Padding(padding: const EdgeInsets.all(10)),
                        Icon(Icons.keyboard_arrow_right, size: 30,),
                        Padding(padding: const EdgeInsets.all(10)),
                        Column(
                          children: [
                            Text(
                              DateFormat('MM월 dd일 (E)', 'ko_KR').format(DateTime.parse(widget.schedule.lastdate)),
                              style: const TextStyle(fontSize: 15),
                            ),
                            Text(
                              DateFormat('HH:mm', 'ko_KR').format(DateTime.parse(widget.schedule.lastdate)),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ]
                  ),
                ]
            ),
            const SizedBox(height: 30),

            // Location
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 28,),
                    SizedBox(width: 10,),
                    Text(
                      "위치",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
                Divider(),
                SizedBox(height: 15,),
                SizedBox(
                  height: 200,
                  child: LocationMap(locationName: widget.schedule.location)
                )
              ],
            ),
            const SizedBox(height: 30),

            // Memo
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.notes),
                    SizedBox(width: 10),
                    Text(
                      "메모",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.save),
                      onPressed: () async {
                        // 저장 함수 호출
                        await updateScheduleMemo(_editableSchedule.firstdate, _editableSchedule.title, _memoController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('메모가 저장되었습니다.')),
                        );
                        setState(() {
                          _editableSchedule = _editableSchedule.copyWith(memo: _memoController.text);
                        });
                      },
                    )
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey.shade50),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: TextField(
                    controller: _memoController,
                    maxLines: null,
                    decoration: InputDecoration.collapsed(hintText: "메모을 입력하세요"),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),


            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("닫기"),
              ),
            ),
          ],
        ),
      )
    );
  }
}

