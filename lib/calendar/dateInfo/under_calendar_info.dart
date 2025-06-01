import 'package:OBSP_Project/calendar/dateInfo/schedule_detail.dart';
import 'package:flutter/material.dart';
import '../../reservation/reading_json.dart';

class ScheduleListWidget extends StatefulWidget {
  final DateTime selectedDate;
  const ScheduleListWidget({super.key, required this.selectedDate});

  @override
  State<ScheduleListWidget> createState() => ScheduleListWidgetState();
}

class ScheduleListWidgetState extends State<ScheduleListWidget> {
  late Future<List<Schedule>> _scheduleFuture;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  void _loadSchedule() {
    _scheduleFuture = getSchedule(widget.selectedDate);
  }

  void refresh() {
    print('🔄 ScheduleListWidget.refresh() called'); // ✅ 로그 확인용
    setState(() {
      _loadSchedule();
    });
  }

  @override
  void didUpdateWidget(covariant ScheduleListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      refresh(); // 날짜 변경 시 자동 갱신
    }
  }

  @override
  Widget build(BuildContext context){
    return FutureBuilder<List<Schedule>> (
      future: _scheduleFuture,
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("에러 발생 : ${snapshot.error}"));
        } else{
          final schedules = snapshot.data!;
          if(schedules.isEmpty){
            return ListView(
              children: [_buildBox(const Text("일정이 없습니다."))],
            );
          }

          return ListView(
            children: schedules.map((schedule) {
              return GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) {
                      return FractionallySizedBox(
                        heightFactor: 0.7,
                        child: ScheduleDetailBottomSheet(schedule: schedule),
                      );
                    },
                  );
                },
                child: _buildBox(
                  ListTile(
                    title: Text(schedule.title),
                    subtitle: Text(schedule.location),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              );
            }).toList(),
          );
        }
      }
    );
  }

  Widget _buildBox(Widget child){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: child,
    );
  }
}

