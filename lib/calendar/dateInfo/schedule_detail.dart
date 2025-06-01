import 'package:flutter/material.dart';
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

          Text(
            schedule.title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text("📍 장소: ${schedule.location}"),
          const SizedBox(height: 8),
          Text("🕒 시간: ${schedule.firstdate } ~ ${schedule.lastdate}"), // schedule.time 필드가 있다고 가정
          const SizedBox(height: 20),
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