class Todo {
  final String task;
  bool done;

  Todo({
    required this.task,
    this.done = false,
  });

  Map<String, dynamic> toJson() => {
    'task': task,
    'done': done,
  };

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    task: json['task'],
    done: json['done'],
  );
}
