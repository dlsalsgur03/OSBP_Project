import 'package:OBSP_Project/calendar/dateInfo/pinmark.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../reservation/reading_json.dart';

Color selectedColor = const Color(0xFF800020);
class ScheduleDetailBottomSheet extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
      child: SingleChildScrollView(
        controller: scrollController,
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
                  schedule.title,
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
                    await deleteSchedule(schedule);
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
                              DateFormat('MM월 dd일 (E)', 'ko_KR').format(DateTime.parse(schedule.firstdate)),
                              style: const TextStyle(fontSize: 15),
                            ),
                            Text(
                              DateFormat('HH:mm', 'ko_KR').format(DateTime.parse(schedule.firstdate)),
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
                              DateFormat('MM월 dd일 (E)', 'ko_KR').format(DateTime.parse(schedule.lastdate)),
                              style: const TextStyle(fontSize: 15),
                            ),
                            Text(
                              DateFormat('HH:mm', 'ko_KR').format(DateTime.parse(schedule.lastdate)),
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
                  child: LocationMap(locationName: schedule.location)
                )
              ],
            ),
            const SizedBox(height: 30),

            // Memo
            Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.notes),
                    SizedBox(width: 10),
                    Text(
                      "메모",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                    )
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(12.0),
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: 100),
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
                  child: Text(
                    schedule.memo.isNotEmpty ? schedule.memo : "내용이 없습니다.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
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
      Color tempColor = selectedColor;
      return AlertDialog(
        title: Text('색상 선택'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: tempColor,
            onColorChanged: (color) {
              tempColor = color;
            },
            showLabel: false,
          ),
        ),
        actions: [
          TextButton(
            child: Text('취소'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('확인'),
            onPressed: () {
              selectedColor = tempColor;
              onColorChanged(tempColor);
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}
