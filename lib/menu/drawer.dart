import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

final List<String> _errorReports = []; //오류들 저장할 리스트 리스트가 초기화 되지 않게 밖으로 빼놨습니다.
Color _selectedColor = Colors.blue; // 색을 저장할 변수

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key,required this.onColorChanged});
  final Function(Color) onColorChanged;
  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  final TextEditingController _textController = TextEditingController();
  Color tempColor = _selectedColor;

  void _showColorPickerDialog(BuildContext context) {
    final List<Color> colors = [
      Colors.red,
      Colors.redAccent,
      Colors.red.shade200,
      Colors.red.shade100,
      Colors.red.shade50,

      Colors.orange,
      Colors.orangeAccent,
      Colors.orange.shade200,
      Colors.orange.shade100,
      Colors.orange.shade50,

      Colors.yellow,
      Colors.yellowAccent,
      Colors.yellow.shade200,
      Colors.yellow.shade100,
      Colors.yellow.shade50,

      Colors.green,
      Colors.greenAccent,
      Colors.green.shade200,
      Colors.green.shade100,
      Colors.green.shade50,

      Colors.blue,
      Colors.blueAccent,
      Colors.blue.shade200,
      Colors.blue.shade100,
      Colors.blue.shade50,

      Colors.indigo,
      Colors.indigoAccent,
      Colors.indigo.shade200,
      Colors.indigo.shade100,
      Colors.indigo.shade50,

      Colors.purple,
      Colors.purpleAccent,
      Colors.purple.shade200,
      Colors.purple.shade100,
      Colors.purple.shade50,

      Colors.black,
      Colors.grey.shade800,
      Colors.grey.shade600,
      Colors.grey.shade400,
      Colors.grey.shade200,
    ];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('색상 선택'),
          content: SizedBox(
            width: 300,
            height: 400, // 좀 더 높게
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: colors.length,
              itemBuilder: (context, index) {
                final color = colors[index];
                return GestureDetector(
                  onTap: () {
                    print('선택된 색상: $color');
                    setState(() {
                      _selectedColor = color; // 내부 상태도 업데이트
                    });
                    widget.onColorChanged(color);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black26),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }


  void _showReportDialog(BuildContext context) {
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
            onTap: () => _showNoticeDialog(context),
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
void _showNoticeDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.5,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.announcement, color: Colors.orange, size: 30),
                SizedBox(width: 8),
                Text('공지사항', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      );
    },
  );
}