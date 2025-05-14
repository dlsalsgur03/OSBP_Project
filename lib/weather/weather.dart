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

      if (weatherResponse.statusCode == 200) {
        final weatherData = json.decode(weatherResponse.body);
        final airQualityData = json.decode(airQualityResponse.body);

        bool isRainyDay = false;
        String selectedDateKey = day.toIso8601String().split("T")[0];

        double tempMin = double.infinity;
        double tempMax = double.negativeInfinity;
        String weatherDescription = "";
        int cloudCoverage = 0;

        for (var entry in weatherData['list']) {
          DateTime dateTime = DateTime.parse(entry['dt_txt']);
          String dateKey = dateTime.toIso8601String().split("T")[0];

          if (dateKey == selectedDateKey && entry['weather'][0]['main'].toLowerCase().contains("rain")) {
            isRainyDay = true;
          }
          if (dateKey == selectedDateKey) {
            double temp = entry['main']['temp'];
            tempMin = temp < tempMin ? temp : tempMin;
            tempMax = temp > tempMax ? temp : tempMax;
            weatherDescription = entry['weather'][0]['description'];
            cloudCoverage = entry['clouds']['all'];
          }
        }

        int airQualityIndex = airQualityData['list'][0]['main']['aqi'];
        String airQuality = getAirQualityDescription(airQualityIndex);
        String recommendation = getRecommendation(tempMin, tempMax, weatherDescription, cloudCoverage, airQuality);

        showWeatherDialog(context, tempMin, tempMax, airQuality, recommendation, isRainyDay);
      } else {
        print('Failed to fetch weather');
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
    String baseRecommendation = "";

    if (weatherDescription.contains("rain")) {
      if (tempMin <= 10 && tempMax <= 15) {
        baseRecommendation = "우산, 따뜻한 외투";
      } else if (tempMin >= 9) {
        baseRecommendation = "우산, 가벼운 겉옷";
      } else if (tempMin >= 20) {
        baseRecommendation = "우산, 반팔";
      } else if (tempMax <= 10) {
        baseRecommendation = "우산, 패딩";
      } else {
        baseRecommendation = "우산";
      }
    } else {
      if (tempMin <= 10 && tempMax <= 15) {
        baseRecommendation = "따뜻한 외투";
      } else if (tempMin >= 9) {
        baseRecommendation = "가벼운 겉옷";
      } else if (tempMin >= 16) {
        baseRecommendation = "반팔, 선크림";
      } else if (tempMax <= 5) {
        baseRecommendation = "패딩";
      } else {
        baseRecommendation = "";
      }
    }

    if (cloudCoverage <= 25) baseRecommendation += ", 선크림";
    if (cloudCoverage < 10) baseRecommendation += ", 양산";
    if (airQuality != "좋음" && airQuality != "보통") baseRecommendation += ", 마스크";

    return baseRecommendation;
  }

  void showWeatherDialog(BuildContext context, double tempMin, double tempMax, String airQuality, String recommendation, bool isRainyDay) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isRainyDay ? const Color(0xffd0eaff) : Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("날씨 정보"),
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
    String recommendation = "";
    switch (selectedDay.month) {
      case 1:
      case 12:
        recommendation = "패딩";
        break;
      case 2:
      case 11:
        recommendation = "따뜻한 외투";
        break;
      case 3:
      case 10:
        recommendation = "따뜻한 외투 또는 가벼운 겉옷";
        break;
      case 4:
      case 5:
        recommendation = "가벼운 겉옷";
        break;
      case 6:
      case 7:
      case 8:
      case 9:
        recommendation = "반팔";
        break;
      default:
        recommendation = "알 수 없음";
    }

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