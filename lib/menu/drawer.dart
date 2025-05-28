import 'package:flutter/material.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  final List<String> _errorReports = []; //오류들 저장할 리스트
  final TextEditingController _textController = TextEditingController();

  void _showReportDialog(BuildContext context) { //오류신고 팝업창
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateInsideDialog) {
          return AlertDialog(
        backgroundColor: const Color(0xFFFFF8E1),
        title: Text('오류 신고'),
        content: SizedBox(
          height: 300,
          width: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _errorReports.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("• ${_errorReports[index]}"), // 한 줄씩 오류 내용 출력
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              // 오류 내용을 입력하는 입력창
              TextField(
                controller: _textController, // 입력값을 읽기 위해 사용
                decoration: const InputDecoration(
                  hintText: '오류 내용을 입력하세요',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final newText = _textController.text.trim();
              if (newText.isNotEmpty) {
                setState(() {
                  _errorReports.add(newText);
                  _textController.clear();
                });
                setStateInsideDialog(() {});
              }
            },
            child: const Text('추가'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
            ),
          ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xffFFFFFF),
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
            onTap: () => _showReportDialog(context),//팝업창 띄우기
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