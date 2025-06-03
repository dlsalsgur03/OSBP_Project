import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'todo_modal.dart';

String _formatDate(DateTime date) {
  return '${date.year}-${date.month}-${date.day}';
}

Future<void> saveTodos(DateTime date, List<Todo> todos) async {
  final prefs = await SharedPreferences.getInstance();
  final key = _formatDate(date);
  final jsonString = jsonEncode(todos.map((todo) => todo.toJson()).toList());
  await prefs.setString(key, jsonString);
}

Future<List<Todo>> loadTodos(DateTime date) async {
  final prefs = await SharedPreferences.getInstance();
  final key = _formatDate(date);
  final jsonString = prefs.getString(key);

  if (jsonString == null) return [];

  final List<dynamic> jsonList = jsonDecode(jsonString);
  return jsonList.map((json) => Todo.fromJson(json)).toList();
}

Future<void> addTodo(DateTime date, Todo todo) async {
  final todos = await loadTodos(date);
  todos.add(todo);
  await saveTodos(date, todos);
}

Future<void> removeTodo(DateTime date, int index) async {
  final todos = await loadTodos(date);
  if (index >= 0 && index < todos.length) {
    todos.removeAt(index);
    await saveTodos(date, todos);
  }
}

Future<void> updateTodo(DateTime date, int index, bool done) async {
  final todos = await loadTodos(date);
  if (index >= 0 && index < todos.length) {
    todos[index].done = done;
    await saveTodos(date, todos);
  }
}
