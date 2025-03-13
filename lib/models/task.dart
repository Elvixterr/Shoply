class Task {
  final String id;
  late final String title;
  final bool isCompleted;

  Task({required this.id, required this.title, this.isCompleted = false});
}
