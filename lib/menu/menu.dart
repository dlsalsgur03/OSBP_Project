import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu), // 햄버거 메뉴 아이콘
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const SettingsPopup();
          },
        );
      },
    );
  }
}
