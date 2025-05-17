import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController startDateController = TextEditingController();
    final TextEditingController endDateController = TextEditingController();
    final TextEditingController memoController = TextEditingController();
    final TextEditingController emojiController = TextEditingController();

    return AlertDialog(
      title: const Text("일정 추가"),
      content: SizedBox(
        width: 300,
        height: 350,
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
              onTap: () async{
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if(pickedDate != null){
                  startDate = pickedDate; //선택한 날짜를 Datetime 변수로 저장
                  startDateController.text = "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
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
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if(pickedDate != null){
                  endDate = pickedDate; //선택한 날짜를 Datetime 변수로 저장
                  endDateController.text = "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
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
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // 팝업창 닫기
          },
          child: const Text("취소"),
        ),
        TextButton(
          onPressed: () async {
            // 입력 데이터 처리 로직
            //print("제목: ${titleController.text}");
            final String title = titleController.text;
            print("장소: ${locationController.text}");
            final String location = locationController.text;
            print("일정 시작: ${startDateController.text}");
            final String firstdate = startDateController.text;
            print("일정 종료: ${endDateController.text}");
            final String lastdate = endDateController.text;
            print("메모: ${titleController.text}");

            await save_schedule_web(
              title : title,
              location : location,
              firstdate : firstdate,
              lastdate : lastdate,
              emoji: '',
            );
            read_data();
            getSchedule(firstdate);

            Navigator.of(context).pop(); // 팝업창 닫기
            showBookingOptions(context);
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
        return GridView.count(
          crossAxisCount: 5,
          padding: const EdgeInsets.all(8.0),
          children: List.generate(emojiList.length, (index) {
            return IconButton(
              onPressed: () {
                controller.text = emojiList[index];
                Navigator.pop(context);
              },
              icon: Text(emojiList[index], style: const TextStyle(fontSize: 24)),
            );
          }),
        );
      },
    );
  }

  final List<String> emojiList = ["🌟"]; // 이모티콘란. 향후 더 추가 예정
}