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
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false, // 드래그로 확장 가능
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.all(16.0),
          width: MediaQuery.of(context).size.width * 0.7,
          decoration: BoxDecoration(
            color: Color(0XffFFFFFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController, // 스크롤 가능하게 설정
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("일정", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                          Divider(),
                          if (schedules.isNotEmpty)
                            for (Schedule schedule in schedules)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.0),
                                child: Container(
                                  width: double.infinity,
                                  constraints: BoxConstraints(
                                    minHeight: 75,
                                    maxHeight: 75,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xffF2F2F2),
                                    borderRadius: BorderRadius.circular(5.0),
                                    border: Border.all(color: Color(0xffF2F2F2), width: 1.0)
                                  ),
                                  padding: EdgeInsets.all(10),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '${schedule.emoji.isNotEmpty ? '${schedule.emoji} ' : ''}${schedule.title}',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              )
                          else
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.0),
                              child: Container(
                                width: double.infinity,
                                constraints: BoxConstraints(
                                  minHeight: 75,
                                  maxHeight: 75,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xffF2F2F2),
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(color: Color(0xffF2F2F2), width: 1.0)
                                ),
                                child: Text("일정이 없습니다."),
                              ),
                            )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              if (selectedDate.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("준비물"),
                                    content: const Text("과거는 지원하지 않습니다."),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("닫기"),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                fetchWeatherOrRecommendation(context, selectedDate);
                              }
                            },
                            child: const Text("준비물", style: TextStyle(color: Color(0xff2D2D2D)),),
                            style: TextButton.styleFrom(
                              backgroundColor: Color(0xffF2F2F2),
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            )
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

void fetchWeatherOrRecommendation(BuildContext context, DateTime selectedDay) {
  if (selectedDay.difference(DateTime.now()).inDays > 4) {
    weatherService.showRecommendationByMonth(context, selectedDay);
  } else {
    weatherService.fetchWeather(context, selectedDay);
  }
}