import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  MenuButton({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings), // 햄버거 메뉴 아이콘
      onPressed: () {
        scaffoldKey.currentState?.openDrawer();
      },
    );
  }
}