import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../reservation/reading_json.dart';

class ScheduleDetailBottomSheet extends StatelessWidget {
  final Schedule schedule;

  const ScheduleDetailBottomSheet({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              IconButton(
                icon: Icon(Icons.delete_outline_rounded),
                onPressed: () async {
                  await deleteSchedule(schedule);
                  Navigator.pop(context, true);
                },
              )
            ],
          ),

          Divider(),

          const SizedBox(height: 40,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(Icons.access_time, size: 18),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Row(
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
              )
            ]
          ),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2), // 위치 보정
                child: Icon(Icons.location_on_outlined, size: 20),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(" 장소: ${schedule.location}"),
              ),
            ],
          ),
          const SizedBox(height: 8),

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

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("닫기"),
            ),
          ),
        ],
      )
    );
  }
}