import 'package:flutter/material.dart';
import '../../reservation/reading_json.dart';

class ScheduleListWidget extends StatelessWidget{
  final DateTime selectedDate;

  const ScheduleListWidget({super.key, required this.selectedDate});

  Future<List<Widget>> buildScheduleList(DateTime selectedDate) async {
    List<Schedule> schedules = await getSchedule(selectedDate);

    if (schedules.isEmpty){
      return [const Text("일정이 없습니다.")];
    }

    return schedules.map((schedule) {
      return ListTile(
        title: Text(schedule.title),
        subtitle: Text(schedule.location),
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

