import 'package:flutter/material.dart';
import 'package:gerenciador_tarefas/models/task_model.dart';
import 'package:gerenciador_tarefas/providers/task_provider.dart';
import 'package:provider/provider.dart';

class TaskFormDialog extends StatefulWidget {
  final Task? taskToEdit; // Se for nulo, é uma nova tarefa

  const TaskFormDialog({super.key, this.taskToEdit});

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late Priority _priority;
  late Category _category;

  bool get _isEditing => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    _title = widget.taskToEdit?.title ?? '';
    _description = widget.taskToEdit?.description ?? '';
    _priority = widget.taskToEdit?.priority ?? Priority.medium;
    _category = widget.taskToEdit?.category ?? Category.personal;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Usamos 'listen: false' dentro de callbacks
      final provider = context.read<TaskProvider>();

      if (_isEditing) {
        // Atualiza a tarefa existente
        final updatedTask = widget.taskToEdit!;
        updatedTask.title = _title;
        updatedTask.description = _description;
        updatedTask.priority = _priority;
        updatedTask.category = _category;

        provider.updateTask(updatedTask);
      } else {
        // Cria uma nova tarefa
        final newTask = Task.create(
          title: _title,
          description: _description,
          priority: _priority,
          category: _category,
        );
        provider.addTask(newTask);
      }

      Navigator.of(context).pop(); // Fecha o diálogo
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? "Editar Tarefa" : "Nova Tarefa"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: "Título"),
                validator: (value) =>
                value == null || value.isEmpty ? "Campo obrigatório" : null,
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: "Descrição"),
                onSaved: (value) => _description = value ?? '',
              ),
              SizedBox(height: 16),
              // Dropdown de Categoria
              DropdownButtonFormField<Category>(
                value: _category,
                decoration: InputDecoration(labelText: "Categoria"),
                items: Category.values.map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c.toString().split('.').last),
                )).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              SizedBox(height: 16),
              // Dropdown de Prioridade
              DropdownButtonFormField<Priority>(
                value: _priority,
                decoration: InputDecoration(labelText: "Prioridade"),
                items: Priority.values.map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(p.toString().split('.').last),
                )).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _priority = value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text("Cancelar"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text(_isEditing ? "Salvar" : "Adicionar"),
          onPressed: _submitForm,
        ),
      ],
    );
  }
}