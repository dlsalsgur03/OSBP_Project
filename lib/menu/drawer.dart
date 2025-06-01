import 'package:flutter/material.dart';

final List<String> _errorReports = []; //오류들 저장할 리스트 리스트가 초기화 되지 않게 밖으로 빼놨습니다.

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
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
            onTap: () {
              Navigator.of(context).pop(); // Drawer 닫기
              Future.delayed(Duration(milliseconds: 300), () {
                showGeneralDialog(
                  context: context,
                  barrierDismissible: true,
                  barrierLabel: "설정",
                  transitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.25
                        , // 화면의 75% 너비
                        height: double.infinity,
                        color: Colors.white,
                        child: const SettingsPanel(), // 설정 내용 위젯
                      ),
                    );
                  },
                  transitionBuilder: (context, animation, secondaryAnimation, child) {
                    final offsetAnimation = Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation);
                    return SlideTransition(position: offsetAnimation, child: child);
                  },
                );
              });
            },
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

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("설정"),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
      body: const Center(
        child: Text("  "), //앞으로 여기에 설정 기능들을 추가할 예정
      ),
    );
  }
}
