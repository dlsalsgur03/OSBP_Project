import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

final List<String> _errorReports = []; //오류들 저장할 리스트 리스트가 초기화 되지 않게 밖으로 빼놨습니다.
Color _selectedColor = Colors.blue; // 색을 저장할 변수

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  final TextEditingController _textController = TextEditingController();
  Color tempColor = _selectedColor;

  void _showColorPickerDialog(BuildContext context) {
    final List<Color> colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.black,
    ];

  }


  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('색상 선택'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: tempColor,
            onColorChanged: (color) {
              tempColor = color;
            },
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            child: const Text('취소'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('확인'),
            onPressed: () {
              setState(() {
                _selectedColor = tempColor;
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateInsideDialog) {
          return AlertDialog(
        backgroundColor: const Color(0xFFFFF8E1),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('오류 신고'),
                Icon(Icons.report),
              ],
            ),
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
            leading: Icon(Icons.people),
            hoverColor: Color(0xffdee2e6),
            title: Text("만든 사람들"),
            onTap: () {},
            trailing: Icon(Icons.navigate_next),
          ),
          ListTile(
            leading: Icon(Icons.report, color: Colors.red, size: 24),
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
          ListTile(
            leading: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple],
                  tileMode: TileMode.mirror,
                ).createShader(bounds);
              },
              child: Icon(Icons.palette, size: 24, color: Colors.white),
            ),
            hoverColor: Color(0xffdee2e6),
            title: Text("색상 변경"),
            onTap: () => _showColorPickerDialog(context),
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
