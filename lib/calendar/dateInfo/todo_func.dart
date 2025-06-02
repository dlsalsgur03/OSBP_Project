import 'todo_modal.dart';
import 'package:intl/intl.dart';

final Map<String, List<Todo>> _todoStorage = {};

String _formatDateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

Future<List<Todo>> getTodoList(DateTime date) async {
  final key = _formatDateKey(date);
  await Future.delayed(Duration(milliseconds: 200));
  return _todoStorage[key]?.toList() ?? [];
}

void addTodoToStorage(DateTime date, Todo todo) {
  final key = _formatDateKey(date);
  _todoStorage[key] = (_todoStorage[key] ?? [])..add(todo);
}

void updateTodoInStorage(DateTime date, int index, bool done) {
  final key = _formatDateKey(date);
  if (_todoStorage.containsKey(key) && index < _todoStorage[key]!.length) {
    _todoStorage[key]![index].done = done;
  }
}

void removeTodoFromStorage(DateTime date, int index) {
  final key = _formatDateKey(date);
  if (_todoStorage.containsKey(key) && index < _todoStorage[key]!.length) {
    _todoStorage[key]!.removeAt(index);
  }
}