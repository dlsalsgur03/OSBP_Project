import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherService {
  final String apiKey = dotenv.env['MY_API_KEY'] ?? "";

  Future<void> fetchWeather(BuildContext context, DateTime day) async {
    final String weatherUrl =
        'https://api.openweathermap.org/data/2.5/forecast?q=Seoul&appid=$apiKey&units=metric';
    final String airQualityUrl =
        'https://api.openweathermap.org/data/2.5/air_pollution?lat=37.5665&lon=126.9780&appid=$apiKey';

    try {
      final weatherResponse = await http.get(Uri.parse(weatherUrl));
      final airQualityResponse = await http.get(Uri.parse(airQualityUrl));

      if (weatherResponse.statusCode == 200 && airQualityResponse.statusCode == 200) {
        final weatherData = json.decode(weatherResponse.body);
        final airQualityData = json.decode(airQualityResponse.body);

        double tempMin = double.infinity, tempMax = double.negativeInfinity;
        String weatherDescription = "";
        int cloudCoverage = 0;
        String selectedDateKey = day.toIso8601String().split("T")[0];
        bool isRainyDay = false;

          for (var entry in weatherData['list']) {
            DateTime dateTime = DateTime.parse(entry['dt_txt']);
            String dateKey = dateTime.toIso8601String().split("T")[0];

            if (dateKey == selectedDateKey) {
              double temp = entry['main']['temp'];
              tempMin = temp < tempMin ? temp : tempMin;
              tempMax = temp > tempMax ? temp : tempMax;
              weatherDescription = entry['weather'][0]['description'];
              cloudCoverage = entry['clouds']['all'];
              if (entry['weather'][0]['main'].toLowerCase().contains("rain"))
                isRainyDay = true;
            }
          }

        int airQualityIndex = airQualityData['list'][0]['main']['aqi'];
        String airQuality = getAirQualityDescription(airQualityIndex);
        String recommendation = getRecommendation(tempMin, tempMax, weatherDescription, cloudCoverage, airQuality);

        showWeatherDialog(context, tempMin, tempMax, airQuality, recommendation, isRainyDay, selectedDateKey);
      } else {
        print('Failed to fetch weather or air quality data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String getAirQualityDescription(int aqi) {
    if (aqi == 1) return "좋음";
    else if (aqi == 2) return "보통";
    else if (aqi == 3) return "약간 나쁨";
    else if (aqi == 4) return "나쁨";
    else return "매우 나쁨";
  }

  String getRecommendation(double tempMin, double tempMax, String weatherDescription, int cloudCoverage, String airQuality) {
    List<String> recommendations = [];

    if (weatherDescription.contains("rain")) recommendations.add("우산");

    if (tempMin <= 10 && tempMax <= 15) recommendations.add("따뜻한 외투");
    else if (tempMin >= 9) recommendations.add("가벼운 겉옷");
    else if (tempMin >= 16) recommendations.add("반팔, 선크림");
    else if (tempMax <= 5) recommendations.add("패딩");

    if (cloudCoverage <= 25) recommendations.add("선크림");
    if (cloudCoverage < 10) recommendations.add("양산");
    if (airQuality != "좋음" && airQuality != "보통") recommendations.add("마스크");

    return recommendations.join(", ");
  }

  void showWeatherDialog(BuildContext context, double tempMin, double tempMax, String airQuality, String recommendation, bool isRainyDay, String day){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isRainyDay ? const Color(0xffd0eaff) : Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("날씨 정보 및 일정 정보"),
            if (isRainyDay) const SizedBox(width: 8),
            if (isRainyDay) const Text("☔", style: TextStyle(fontSize: 24)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("최저 온도: ${tempMin.toStringAsFixed(1)}℃"),
            Text("최고 온도: ${tempMax.toStringAsFixed(1)}℃"),
            const SizedBox(height: 20),
            Text("미세먼지 상태: $airQuality"),
            const SizedBox(height: 20),
            const Text("추천 준비물"),
            Text(recommendation),
            const SizedBox(height: 20),

          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("닫기"),
          ),
        ],
      ),
    );
  }

  void showRecommendationByMonth(BuildContext context, DateTime selectedDay) {
    List<String> recommendations = ["패딩", "따뜻한 외투", "따뜻한 외투 또는 가벼운 겉옷", "가벼운 겉옷", "반팔"];
    String recommendation = recommendations[(selectedDay.month - 1) ~/ 2];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("추천 준비물"),
        content: Text(recommendation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("닫기"),
          ),
        ],
      ),
    );
  }
}