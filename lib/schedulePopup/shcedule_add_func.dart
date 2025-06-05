import 'package:flutter/material.dart';

import 'schedule_add.dart';

Future<bool?> showScheduleBottomSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return ScheduleBottomSheetContent(
        scrollController: ScrollController(),
      );
    },
  );
}
