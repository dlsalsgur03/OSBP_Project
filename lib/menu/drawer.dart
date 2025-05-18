import 'package:flutter/material.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.settings),
            hoverColor: Color(0xffdee2e6),
            title: Text("설정"),
            onTap: () {},
            trailing: Icon(Icons.navigate_next),
          ),
          ListTile(
            leading: Icon(Icons.people),
            hoverColor: Color(0xffdee2e6),
            title: Text("만든 사람들"),
            onTap: () {},
            trailing: Icon(Icons.navigate_next),
          ),
          ListTile(
            leading: Icon(Icons.report),
            hoverColor: Color(0xffdee2e6),
            title: Text("오류 신고"),
            onTap: () {},
            trailing: Icon(Icons.navigate_next),
          ),
          ListTile(
            leading: Icon(Icons.newspaper),
            hoverColor: Color(0xffdee2e6),
            title: Text("공지사항"),
            onTap: () {},
            trailing: Icon(Icons.navigate_next),
          ),
        ],
      ),
    );
  }
}

