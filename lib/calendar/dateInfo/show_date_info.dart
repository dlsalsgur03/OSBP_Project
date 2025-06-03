import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../reservation/reading_json.dart';
import '../../weather/weather.dart';
import './todolist/todo_modal.dart';
import './todolist/todo_func.dart';

DateTime today = DateTime.now();
DateTime yesterday = today.subtract(const Duration(days: 1));

final WeatherService weatherService = WeatherService();

void showBottomSheetModal(BuildContext context, DateTime selectedDate) async {

  List<Schedule> schedules = await getSchedule(selectedDate);
  List<Todo> todos = await loadTodos(selectedDate);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final TextEditingController todoController = TextEditingController();

          void addTodoHandler(){
            final text = todoController.text.trim();
            if (text.isNotEmpty){
              final newTodo = Todo(task: text);
              setState(() {
                todos.add(newTodo);
                addTodo(selectedDate, newTodo);
              });
              todoController.clear();
            }
          }

          void removeTodoHandler(int index) {
            setState((){
              todos.removeAt(index);
              removeTodo(selectedDate, index);
            });
          }

          void toggleDone(int index, bool? val) {
            setState((){
              todos[index].done = val ?? false;
              updateTodo(selectedDate, index, val ?? false);
            });
          }

          return DraggableScrollableSheet(
            expand: false, // 드래그로 확장 가능
            builder: (context, scrollController) {
              return Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color(0XffFFFFFF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(selectedDate),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Divider(),
                    Expanded(
                      child: ListView(
                        controller: scrollController, // 스크롤 가능하게 설정
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("To Do List", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                                Divider(),
                                // To Do Add Section
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: todoController,
                                        decoration: InputDecoration(
                                          hintText: "새 할 일 입력",
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        ),
                                        onSubmitted: (_) => addTodoHandler(),
                                      )
                                    ),
                                    SizedBox(width: 8,),
                                    ElevatedButton(onPressed: addTodoHandler, child: Text("추가")),
                                  ],
                                ),
                                SizedBox(height: 10,),
                                if(todos.isNotEmpty)
                                  for (int i = 0; i < todos.length; i++)
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 4.0),
                                      child: Row(
                                        children: [
                                          Checkbox(
                                            value: todos[i].done,
                                            onChanged: (val) => toggleDone(i, val),
                                          ),
                                          Expanded(
                                            child: Text(
                                              todos[i].task,
                                              style: TextStyle(
                                                fontSize: 16,
                                                decoration: todos[i].done ? TextDecoration.lineThrough : null,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                              onPressed: () => removeTodoHandler(i),
                                              icon: Icon(Icons.delete_outline_rounded, color: Colors.red,)
                                          )
                                        ],
                                      ),
                                    )
                                else
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 4.0),
                                    child: Text("To Do 항목이 없습니다."),
                                  ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20),

                          Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("일정", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                                Divider(),
                                if (schedules.isNotEmpty)
                                  for (Schedule schedule in schedules)
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 4.0),
                                      child: Container(
                                        width: double.infinity,
                                        constraints: BoxConstraints(
                                          minHeight: 75,
                                          maxHeight: 75,
                                        ),
                                        decoration: BoxDecoration(
                                            color: Color(0xffF2F2F2),
                                            borderRadius: BorderRadius.circular(5.0),
                                            border: Border.all(color: Color(0xffF2F2F2), width: 1.0)
                                        ),
                                        padding: EdgeInsets.all(10),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          '${schedule.emoji.isNotEmpty ? '${schedule.emoji} ' : ''}${schedule.title}',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    )
                                else
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 4.0),
                                    child: Container(
                                      width: double.infinity,
                                      constraints: BoxConstraints(
                                        minHeight: 75,
                                        maxHeight: 75,
                                      ),
                                      decoration: BoxDecoration(
                                          color: Color(0xffF2F2F2),
                                          borderRadius: BorderRadius.circular(5.0),
                                          border: Border.all(color: Color(0xffF2F2F2), width: 1.0)
                                      ),
                                      child: Text("일정이 없습니다."),
                                    ),
                                  )
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TextButton(
                                    onPressed: () {
                                      if (selectedDate.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text("준비물"),
                                            content: const Text("과거는 지원하지 않습니다."),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text("닫기"),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        fetchWeatherOrRecommendation(context, selectedDate);
                                      }
                                    },
                                    child: const Text("준비물", style: TextStyle(color: Color(0xff2D2D2D)),),
                                    style: TextButton.styleFrom(
                                      backgroundColor: Color(0xffF2F2F2),
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                    )
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      );
    }
  );
}

void fetchWeatherOrRecommendation(BuildContext context, DateTime selectedDay) {
  if (selectedDay.difference(DateTime.now()).inDays > 4) {
    weatherService.showRecommendationByMonth(context, selectedDay);
  } else {
    weatherService.fetchWeather(context, selectedDay);
  }
}