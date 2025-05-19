import 'package:flutter/material.dart';

import '../../reservation/reading_json.dart';
import '../../weather/weather.dart';

DateTime today = DateTime.now();
DateTime yesterday = today.subtract(const Duration(days: 1));

final WeatherService weatherService = WeatherService();

void showBottomSheetModal(BuildContext context, DateTime selectedDate) async {

  List<Schedule> schedules = await getSchedule(selectedDate);

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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (selectedDate.isBefore(yesterday)){
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("준비물"),
                              content: const Text("과거는 지원하지 않습니다."),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("닫기")
                                )
                              ],
                            )
                          );
                        }
                        else {
                          fetchWeatherOrRecommendation(context, selectedDate);
                        }
                      },
                      child: const Text("준비물"),
                    )
                  ],
                )
            )
          ],
        ),
      );
    }
  );
}

void fetchWeatherOrRecommendation(BuildContext context, DateTime selectedDay) {
  if (selectedDay.difference(DateTime.now()).inDays > 4) {
    weatherService.showRecommendationByMonth(context, selectedDay);
  } else {
    weatherService.fetchWeather(context, selectedDay);
  }
}