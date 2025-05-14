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

          if (dateKey == selectedDateKey &&
              entry['weather'][0]['main'].toLowerCase().contains("rain")) {
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
        String recommendation = getRecommendation(
            tempMin, tempMax, weatherDescription, cloudCoverage, airQuality);

        showWeatherDialog(
            context, tempMin, tempMax, airQuality, recommendation, isRainyDay);
      } else {
        print('Failed to fetch weather');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

}