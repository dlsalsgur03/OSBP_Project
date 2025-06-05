import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import '../reservation/transportation_popup.dart';
import '../reservation/reading_json.dart';
import 'location_search.dart';

class ScheduleBottomSheetContent extends StatefulWidget {
  final ScrollController scrollController;

  const ScheduleBottomSheetContent({super.key, required this.scrollController});

  @override
  State<ScheduleBottomSheetContent> createState() => _ScheduleBottomSheetContentState();
}

class _ScheduleBottomSheetContentState extends State<ScheduleBottomSheetContent> {
  DateTime? startDate;
  DateTime? endDate;

  final titleController = TextEditingController();
  final locationController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final memoController = TextEditingController();
  final emojiController = TextEditingController();

  void initState() {
    super.initState();

    startDate = DateTime.now();
    endDate = startDate!.add(const Duration(hours: 1));

    startDateController.text = formatDateTime(startDate!);
    endDateController.text = formatDateTime(endDate!);
  }

  String formatDate(DateTime dt) => "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  String formatDateTime(DateTime dt) => "${formatDate(dt)} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: ListView(
        controller: widget.scrollController,
        children: [
          SizedBox(height: 10,),
          const Text("일정 추가", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          Divider(),
          SizedBox(height: 10,),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: "일정 제목"),
          ),
          SizedBox(height: 10,),
          TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: "장소"),
              onTap: () async {
                final result = await showAddressSearchModal(context);
                if(result != null) {
                  locationController.text = result['address'] ?? '';
                }
              }
          ),
          SizedBox(height: 10,),
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
                  startDateController.text = formatDateTime(pickedDate);
                });
              }
            },
          ),
          SizedBox(height: 10,),
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
                  endDateController.text = formatDateTime(pickedDate);
                });
              }
            },
          ),
          SizedBox(height: 10,),
          TextField(
            controller: memoController,
            decoration: const InputDecoration(
              labelText: "메모",
            ),
          ),
          SizedBox(height: 10,),
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
          ),
          const SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: const Text('취소'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                  child: const Text("다음"),
                  onPressed: () async {
                    final titleText = titleController.text.trim().isEmpty
                      ? '제목 없음'
                      : titleController.text.trim();

                    if (startDate == null || endDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('시작일과 종료일을 모두 선택해주세요.')),
                      );
                      return;
                    }
                    await save_schedule_web(
                      title: titleText,
                      location: locationController.text,
                      firstdate: startDate,
                      lastdate: endDate,
                      emoji: emojiController.text,
                      memo: memoController.text,
                    );
                    read_data();
                    getSchedule(startDate!);

                    Navigator.of(context).pop(true); // 바텀시트 닫기
                    showBookingOptions(context, titleController.text, startDate!, endDate!);
                  }
              )
            ],
          )
        ],
      ),
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
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: const DatePickerThemeData(
              backgroundColor: Color(0xFFF5F7FA),         // 밝은 회백색 배경
              surfaceTintColor: Colors.transparent,       // 불필요한 잔상 제거
            ),
          ),
          child: child!,
        );
      }
  );

  if (date == null) return null;

  final TimeOfDay? time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: Theme.of(context).copyWith(
          timePickerTheme: TimePickerThemeData(
            backgroundColor: Colors.grey[200], // ✅ 팝업 배경색
          ),
        ),
        child: child!,
      );
    },
  );

  if (time == null) return null;

  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}
