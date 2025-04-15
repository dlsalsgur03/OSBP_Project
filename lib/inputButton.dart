import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("캘린더 앱"),
      ),
      body: const Center(
        child: Text("달력 화면"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 팝업창 호출
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const SchedulePopup();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SchedulePopup extends StatelessWidget {
  const SchedulePopup({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController dateController = TextEditingController();

    return AlertDialog(
      title: const Text("일정 추가"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: "일정 제목",
            ),
          ),
          TextField(
            controller: locationController,
            decoration: const InputDecoration(
              labelText: "장소",
            ),
          ),
          TextField(
            controller: dateController,
            decoration: const InputDecoration(
              labelText: "날짜 범위",
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // 팝업창 닫기
          },
          child: const Text("취소"),
        ),
        TextButton(
          onPressed: () {
            // 일정 데이터를 저장하거나 처리하는 로직
            print("제목: ${titleController.text}");
            print("장소: ${locationController.text}");
            print("날짜 범위: ${dateController.text}");
            Navigator.of(context).pop(); // 팝업창 닫기
          },
          child: const Text("저장"),
        ),
      ],
    );
  }
}