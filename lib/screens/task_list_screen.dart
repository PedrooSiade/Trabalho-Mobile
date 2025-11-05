import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gerenciador_tarefas/models/task_model.dart';
import 'package:gerenciador_tarefas/providers/task_provider.dart';
import 'package:gerenciador_tarefas/widgets/task_form_dialog.dart'; // O pop-up de formulário
import 'package:gerenciador_tarefas/widgets/task_tile.dart';       // O item da lista

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Assiste a mudanças no provider. Qualquer mudança no provider
    // fará esta tela ser redesenhada.
    final taskProvider = context.watch<TaskProvider>();

    // Pega a lista de tarefas. O getter 'tasks' no provider
    // já retorna a lista filtrada.
    final tasks = taskProvider.tasks;

    return Scaffold(
      appBar: AppBar(
        title: Text("Gerenciador de Tarefas"),
        centerTitle: true,
        actions: [
          // Botão para alternar a exibição de tarefas concluídas
          Tooltip(
            message: taskProvider.showCompleted ? "Ocultar Concluídas" : "Mostrar Concluídas",
            child: IconButton(
              icon: Icon(taskProvider.showCompleted
                  ? Icons.check_box_outlined
                  : Icons.check_box_outline_blank),
              onPressed: () {
                // Chama o método no provider para trocar o filtro
                taskProvider.toggleShowCompleted();
              },
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // --- Barra de Busca e Filtros ---
          _buildFilterBar(context, taskProvider),

          // --- Lista de Tarefas ---
          Expanded(
            child: tasks.isEmpty
                ? Center(
              child: Text(
                "Nenhuma tarefa encontrada.",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80), // Espaço para o FAB
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];

                // Usamos o TaskTile (que criaremos depois)
                // para exibir cada item
                return TaskTile(
                  task: task,
                  onChanged: (value) => taskProvider.toggleTaskCompletion(task),
                  onDelete: () => taskProvider.deleteTask(task),
                  onTap: () {
                    // Abre o diálogo para EDITAR
                    showDialog(
                      context: context,
                      builder: (context) => TaskFormDialog(taskToEdit: task),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: "Adicionar Tarefa",
        onPressed: () {
          // Abre o diálogo para CRIAR uma nova tarefa
          showDialog(
            context: context,
            builder: (context) => TaskFormDialog(),
          );
        },
      ),
    );
  }

  // Widget auxiliar privado para construir a barra de filtros
  Widget _buildFilterBar(BuildContext context, TaskProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // --- Campo de Busca (Search) ---
          TextField(
            decoration: InputDecoration(
              labelText: 'Buscar por título ou descrição...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
            ),
            onChanged: (value) {
              // Atualiza o provider com o novo termo de busca
              provider.setSearchQuery(value);
            },
          ),
          SizedBox(height: 8),

          // --- Filtros de Categoria e Prioridade ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Dropdown de Categoria
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: DropdownButton<Category?>(
                      isExpanded: true,
                      value: provider.filterCategory,
                      hint: Text("Categoria"),
                      items: [
                        DropdownMenuItem(child: Text("Todas Categorias"), value: null),
                        ...Category.values.map((c) => DropdownMenuItem(
                          child: Text(c.toString().split('.').last.toUpperCase()),
                          value: c,
                        ))
                      ],
                      onChanged: (value) {
                        provider.setCategoryFilter(value);
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              // Dropdown de Prioridade
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: DropdownButton<Priority?>(
                      isExpanded: true,
                      value: provider.filterPriority,
                      hint: Text("Prioridade"),
                      items: [
                        DropdownMenuItem(child: Text("Todas Prioridades"), value: null),
                        ...Priority.values.map((p) => DropdownMenuItem(
                          child: Text(p.toString().split('.').last.toUpperCase()),
                          value: p,
                        ))
                      ],
                      onChanged: (value) {
                        provider.setPriorityFilter(value);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}