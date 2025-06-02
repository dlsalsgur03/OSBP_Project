import 'package:OBSP_Project/calendar/dateInfo/schedule_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
              DateTime sdt = DateTime.parse(schedule.firstdate);
              DateTime edt = DateTime.parse(schedule.lastdate);
              String startTime = DateFormat('HH:mm').format(sdt);
              String endTime = DateFormat('HH:mm').format(edt);

              final sd = widget.selectedDate;

              DateTime sDate = DateTime(sdt.year, sdt.month, sdt.day);
              DateTime eDate = DateTime(edt.year, edt.month, edt.day);
              DateTime selectedDate = DateTime(sd.year, sd.month, sd.day);

              bool isSameDay(DateTime a, DateTime b){
                return a.year == b.year && a.month == b.month && a.day == b.day;
              }

              Widget buildDateInfo() {
                if (isSameDay(selectedDate, sDate)) {
                  // 선택된 날 == 시작일
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        startTime,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      (isSameDay(sDate, eDate))
                          ? Text(
                        endTime,
                        style: TextStyle(color: Colors.grey[700]),
                      )
                          : Text(
                        DateFormat('dd일 (E)', 'ko_KR').format(edt),
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  );
                } else if (selectedDate.isAfter(sDate) && selectedDate.isBefore(eDate)) {
                  // 선택된 날이 시작일과 끝나는일 사이일 때
                  return Text(
                    '하루종일',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  );
                } else if (isSameDay(selectedDate, eDate)) {
                  // 선택된 날 == 끝나는일
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd일 (E)', 'ko_KR').format(sdt),
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        endTime,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                } else {
                  // 그 외 (선택된 날이 일정 밖인 경우)
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd일 (E)', 'ko_KR').format(sdt),
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        isSameDay(sdt, edt)
                            ? endTime
                            : DateFormat('dd일 (E)', 'ko_KR').format(edt),
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  );
                }
              }

              return GestureDetector(
                onTap: () async {
                  final result = await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) {
                      return DraggableScrollableSheet(
                        expand: false,
                        initialChildSize: 0.8,
                        minChildSize: 0.4,
                        maxChildSize: 0.95,
                        builder: (context, scrollController) {
                          return ScheduleDetailBottomSheet(
                              schedule: schedule,
                              scrollController: scrollController
                          );
                        },
                      );
                    },
                  );
                  if (result == true) {
                    setState(() {
                      refresh();
                    });
                  }
                },

                child: _buildBox(
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        alignment: Alignment.centerLeft,
                        child: buildDateInfo(),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
                        height: 40,
                        width: 2,
                        color: Colors.grey[400],
                      ),
                      Expanded(
                        child: ListTile(
                          title: Text(schedule.title),
                          subtitle: Text(schedule.location),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  )
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

