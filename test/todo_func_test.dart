import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:OBSP_Project/calendar/dateInfo/todolist/todo_func.dart';
import 'package:OBSP_Project/calendar/dateInfo/todolist/todo_modal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Todo SharedPreferences Tests', () {
    final testDate = DateTime(2025, 6, 5);

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('saveTodos and loadTodos work correctly', () async {
      final todos = [Todo(task: 'Task 1'), Todo(task: 'Task 2', done: true)];
      await saveTodos(testDate, todos);

      final loadedTodos = await loadTodos(testDate);
      expect(loadedTodos.length, 2);
      expect(loadedTodos[0].task, 'Task 1');
      expect(loadedTodos[1].done, true);
    });

    test('addTodo adds a new todo', () async {
      final todo = Todo(task: 'New Task');
      await addTodo(testDate, todo);

      final loadedTodos = await loadTodos(testDate);
      expect(loadedTodos.length, 1);
      expect(loadedTodos[0].task, 'New Task');
    });

    test('removeTodo removes the correct todo', () async {
      final todos = [
        Todo(task: 'A'),
        Todo(task: 'B'),
        Todo(task: 'C')
      ];
      await saveTodos(testDate, todos);
      await removeTodo(testDate, 1);

      final loadedTodos = await loadTodos(testDate);
      expect(loadedTodos.length, 2);
      expect(loadedTodos[0].task, 'A');
      expect(loadedTodos[1].task, 'C');
    });

    test('updateTodo toggles the done status', () async {
      final todos = [Todo(task: 'Do something', done: false)];
      await saveTodos(testDate, todos);
      await updateTodo(testDate, 0, true);

      final loadedTodos = await loadTodos(testDate);
      expect(loadedTodos[0].done, true);
    });

    test('loadTodos returns empty list if no data', () async {
      final todos = await loadTodos(testDate);
      expect(todos, isEmpty);
    });
  });
}
