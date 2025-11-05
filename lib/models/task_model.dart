import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

// Importe esta parte gerada após rodar o build_runner
part 'task_model.g.dart'; // Será gerado

@HiveType(typeId: 1)
enum Priority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}

@HiveType(typeId: 2)
enum Category {
  @HiveField(0)
  personal,
  @HiveField(1)
  work,
  @HiveField(2)
  study,
}

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  Priority priority;

  @HiveField(5)
  Category category;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.priority = Priority.medium,
    this.category = Category.personal,
  });

  // Um construtor "factory" para criar novas tarefas com um ID único
  factory Task.create({
    required String title,
    String description = '',
    Priority priority = Priority.medium,
    Category category = Category.personal,
  }) {
    return Task(
      id: Uuid().v4(), // Gera um ID único
      title: title,
      description: description,
      priority: priority,
      category: category,
    );
  }
}