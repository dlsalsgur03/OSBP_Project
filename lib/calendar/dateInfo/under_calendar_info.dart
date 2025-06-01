import 'package:flutter/material.dart';
import '../../reservation/reading_json.dart';

class ScheduleListWidget extends StatelessWidget{
  final DateTime selectedDate;

  const ScheduleListWidget({super.key, required this.selectedDate});

  Future<List<Widget>> buildScheduleList(DateTime selectedDate) async {
    List<Schedule> schedules = await getSchedule(selectedDate);

    if (schedules.isEmpty){
      return [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: ListTile(
            title: Text("일정이 없습니다."),
            contentPadding: EdgeInsets.zero, // 패딩 제거 (원하는 경우)
          ),
        )
      ];
    }

    return schedules.map((schedule) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: ListTile(
          title: Text(schedule.title),
          subtitle: Text(schedule.location),
          contentPadding: EdgeInsets.zero, // 패딩 제거 (원하는 경우)
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context){
    return FutureBuilder<List<Widget>> (
      future: buildScheduleList(selectedDate),
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("에러 발생 : ${snapshot.error}"));
        } else{
          return ListView(children: snapshot.data!);
        }
      }
    );
  }
}

