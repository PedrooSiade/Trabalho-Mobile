import 'package:flutter/material.dart';
import 'package:gerenciador_tarefas/models/task_model.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final Function(bool?) onChanged;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const TaskTile({
    super.key,
    required this.task,
    required this.onChanged,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        onTap: onTap, // Para editar
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: onChanged,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(task.description.isEmpty ? "Sem descrição" : task.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(label: Text(task.category.toString().split('.').last)),
            SizedBox(width: 4),
            _buildPriorityIcon(task.priority),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityIcon(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Icon(Icons.arrow_upward, color: Colors.red);
      case Priority.medium:
        return Icon(Icons.arrow_forward, color: Colors.orange);
      case Priority.low:
        return Icon(Icons.arrow_downward, color: Colors.green);
    }
  }
}