import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import '../reservation/transportation_popup.dart';
import '../reservation/reading_json.dart';

class SchedulePopup extends StatefulWidget {
  const SchedulePopup({super.key});

  @override
  State<SchedulePopup> createState() => _SchedulePopupState();
}
class _SchedulePopupState extends State<SchedulePopup> {
  DateTime? startDate;
  DateTime? endDate;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController memoController = TextEditingController();
  final TextEditingController emojiController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    void dispose() {
      titleController.dispose();
      locationController.dispose();
      startDateController.dispose();
      endDateController.dispose();
      memoController.dispose();
      emojiController.dispose();
      super.dispose();
    }

    String formatDateTime(DateTime dateTime) {
      return "${dateTime.year.toString().padLeft(4, '0')}-"
          "${dateTime.month.toString().padLeft(2, '0')}-"
          "${dateTime.day.toString().padLeft(2, '0')} "
          "${dateTime.hour.toString().padLeft(2, '0')}:"
          "${dateTime.minute.toString().padLeft(2, '0')}";
    }

    String formatDate(DateTime dateTime) {
      return "${dateTime.year.toString().padLeft(4, '0')}-"
          "${dateTime.month.toString().padLeft(2, '0')}-"
          "${dateTime.day.toString().padLeft(2, '0')}";
    }

    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text("일정 추가"),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 300,
          child: Column(
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
                controller: startDateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "일정 시작",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  DateTime? pickedDate = await pickDateTime(context);
                  if (pickedDate != null){
                    setState(() {
                      startDate = pickedDate;
                      startDateController.text = formatDate(pickedDate);
                    });
                  }
                },
              ),
              TextField(
                controller: endDateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "일정 종료",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async{
                  DateTime? pickedDate = await pickDateTime(context);
                  if(pickedDate != null){
                    setState(() {
                      endDate = pickedDate;
                      endDateController.text = formatDate(pickedDate);
                    });
                  }
                },
              ),
              TextField(
                controller: memoController,
                decoration: const InputDecoration(
                  labelText: "메모",
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: emojiController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "이모티콘",
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions),
                    onPressed: () {
                      _showEmojiPicker(context, emojiController);
                    },
                  )
                ]
              )
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // 팝업창 닫기
          },
          child: const Text("취소"),
        ),
        TextButton(
          onPressed: () async {

            // 날짜가 선택되지 않은 경우 안내 메시지 띄우기
            if (startDate == null || endDate == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('시작일과 종료일을 모두 선택해주세요.')),
              );
              return;
            }

            final String title = titleController.text;
            final String location = locationController.text;
            // 입력 데이터 처리 로직
            //print("제목: ${titleController.text}");
            final String? firstDateStr = startDate != null ? formatDateTime(startDate!) : null;
            final String? lastDateStr = endDate != null ? formatDateTime(endDate!) : null;

            print("제목: $title");
            print("장소: $location");
            print("일정 시작: $firstDateStr");
            print("일정 종료: $lastDateStr");
            print("메모: ${titleController.text}");

            await save_schedule_web(
              title : title,
              location : location,
              firstdate : startDate,
              lastdate : endDate,
              emoji: emojiController.text,
            );
            read_data();
            getSchedule(startDate!);

            Navigator.of(context).pop(true); // 팝업창 닫기
            showBookingOptions(context, title ,startDate!);
          },
          child: const Text("다음"),
        ),
      ],
    );
  }
  void _showEmojiPicker(BuildContext context, TextEditingController controller) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return EmojiPicker(
          onEmojiSelected: (category, emoji) {
            controller.text = emoji.emoji;
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

Future<DateTime?> pickDateTime(BuildContext context) async {
  final DateTime? date = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  if (date == null) return null;

  final TimeOfDay? time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (time == null) return null;

  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}
