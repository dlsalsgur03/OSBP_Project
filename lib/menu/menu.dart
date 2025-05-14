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

class SettingsPopup extends StatefulWidget {
  const SettingsPopup({super.key});

  @override
  _SettingsPopupState createState() => _SettingsPopupState();
}

class _SettingsPopupState extends State<SettingsPopup> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.2,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text(
                "설정",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(thickness: 2.0),
            ListTile(
              title: const Center(
                child: Text(
                  "개발자",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const DeveloperInfoPopup();
                  },
                );
              },
            ),
            const Divider(thickness: 2.0),
            ListTile(
              title: const Center(
                child: Text(
                  "알림",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const NotificationSettingsPopup();
                  },
                );
              },
            ),
            const Divider(thickness: 2.0),
            ListTile(
              title: const Center(
                child: Text(
                  "오류 신고",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("오류 신고"),
                      content: const Text(
                        "juwankim03@gmail.com\n문의 시 빠른 시일 내에 답변 드리겠습니다.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "닫기",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const Divider(thickness: 2.0),
            ListTile(
              title: const Center(
                child: Text(
                  "공지사항",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("공지사항"),
                      content: const Text(
                        "공지사항이 없습니다.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "닫기",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const Divider(thickness: 2.0),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "닫기",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeveloperInfoPopup extends StatelessWidget {
  const DeveloperInfoPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("민혁의 카피바라들"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text("인민혁"),
          Text("김주완"),
          Text("김윤태"),
          Text("박민석"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("닫기"),
        ),
      ],
    );
  }
}

class NotificationSettingsPopup extends StatefulWidget {
  const NotificationSettingsPopup({super.key});

  @override
  _NotificationSettingsPopupState createState() =>
      _NotificationSettingsPopupState();
}

class _NotificationSettingsPopupState extends State<NotificationSettingsPopup> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("알림 설정"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
            title: const Text("더 이상 알림을 받지 않음"),
            value: !notificationsEnabled,
            onChanged: (bool? value) {
              setState(() {
                notificationsEnabled = !(value ?? true);
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            "닫기",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}