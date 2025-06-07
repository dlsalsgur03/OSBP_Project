import 'package:flutter_test/flutter_test.dart';

import 'package:OBSP_Project/calendar/dateInfo/todolist/todo_modal.dart';

void main() {
  group('Todo Modal Tests', () {
    final Map<String, dynamic> sampleJson = {
      'task' : 'Task1',
      'done' : false,
    };

    final sampleTodo = Todo(task: 'Task1', done: false);

    test('fromJson - 유효한 JSON으로부터 Todo 객체를 생성해야 함', () {
      final todo = Todo.fromJson(sampleJson);
      expect(todo.task, "Task1");
      expect(todo.done, false);
    });

    test('toJson - Todo 객체로부터 유효한 JSON Map을 생성해야 한다', () {
      final jsonMap = sampleTodo.toJson();
      expect(jsonMap['task'], 'Task1');
      expect(jsonMap['done'], false);
      expect(jsonMap.containsKey('task'), isTrue);
      expect(jsonMap.containsKey('done'), isTrue);
    });

    test('기본 생성자 - done 필드의 기본값은 false여야 한다', () {
      final todoWithDefaultDone = Todo(task: 'New Task');
      expect(todoWithDefaultDone.task, 'New Task');
      expect(todoWithDefaultDone.done, false);
    });
  });
}