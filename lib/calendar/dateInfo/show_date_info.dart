import 'package:flutter/material.dart';

import '../../reservation/reading_json.dart';

void showBottomSheetModal(BuildContext context, DateTime selectedDate) async {

  final strDate = "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
  List<Schedule> schedules = await getSchedule(strDate);

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context){
      return SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                textAlign: TextAlign.left,
                '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("일정"),
                    if (schedules.isNotEmpty)
                      for (Schedule schedule in schedules)
                        Text(schedule.title)
                    else
                      Text("일정이 없습니다.")
                  ],
                )
              ,
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("준비물"),
                    Text("과거는 지원하지 않습니다."),
                  ],
                )
            )
          ],
        ),
      );
    }
  );
}

