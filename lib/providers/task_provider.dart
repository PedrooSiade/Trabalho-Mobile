import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gerenciador_tarefas/models/task_model.dart';

// Usamos 'with ChangeNotifier' para que esta classe possa notificar os 'listeners' (widgets)
// sobre mudanças.
class TaskProvider with ChangeNotifier {

  // A "box" (tabela) do Hive onde as tarefas são armazenadas.
  final Box<Task> _taskBox = Hive.box<Task>('tasks');

  // A lista completa de tarefas em memória.
  List<Task> _tasks = [];

  // --- Estado dos Filtros ---
  String _searchQuery = '';
  Category? _filterCategory;
  Priority? _filterPriority;
  bool _showCompleted = true; // Por padrão, mostramos as tarefas concluídas

  // Getter para a UI saber se deve mostrar concluídas (para o ícone do AppBar)
  bool get showCompleted => _showCompleted;

  // Getters para a UI saber qual filtro está selecionado (para os Dropdowns)
  Category? get filterCategory => _filterCategory;
  Priority? get filterPriority => _filterPriority;


  // --- O GETTER PRINCIPAL ---
  // Este é o 'getter' público que a TaskListScreen vai usar.
  // Ele aplica todos os filtros e ordenação em tempo real.
  List<Task> get tasks {
    // 1. Começa com uma cópia da lista principal
    List<Task> filteredTasks = List<Task>.from(_tasks);

    // 2. Aplica o filtro de "Mostrar Concluídas"
    if (!_showCompleted) {
      filteredTasks = filteredTasks.where((task) => !task.isCompleted).toList();
    }

    // 3. Aplica o filtro de Categoria
    if (_filterCategory != null) {
      filteredTasks = filteredTasks.where((task) => task.category == _filterCategory).toList();
    }

    // 4. Aplica o filtro de Prioridade
    if (_filterPriority != null) {
      filteredTasks = filteredTasks.where((task) => task.priority == _filterPriority).toList();
    }

    // 5. Aplica o filtro de Busca (Search)
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredTasks = filteredTasks.where((task) =>
      task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query)
      ).toList();
    }

    // 6. Opcional: Ordenar a lista
    // Coloca as tarefas de prioridade Alta no topo.
    filteredTasks.sort((a, b) {
      // Concluídas vão para o final
      if (a.isCompleted && !b.isCompleted) return 1;
      if (!a.isCompleted && b.isCompleted) return -1;

      // Ordena por prioridade (maior primeiro)
      return b.priority.index.compareTo(a.priority.index);
    });

    return filteredTasks;
  }

  // --- Métodos para Atualizar os Filtros ---
  // A UI chamará estes métodos quando o usuário interagir com os filtros.

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners(); // Avisa a UI que a lista precisa ser redesenhada
  }

  void setCategoryFilter(Category? category) {
    _filterCategory = category;
    notifyListeners();
  }

  void setPriorityFilter(Priority? priority) {
    _filterPriority = priority;
    notifyListeners();
  }

  void toggleShowCompleted() {
    _showCompleted = !_showCompleted;
    notifyListeners();
  }

  // --- Métodos de CRUD (Create, Read, Update, Delete) ---

  // R: Read (Carregar tarefas do Hive para a lista em memória)
  void loadTasks() {
    _tasks = _taskBox.values.toList();
    notifyListeners();
  }

  // C: Create (Adicionar nova tarefa)
  Future<void> addTask(Task task) async {
    // Salva no banco de dados Hive. O 'id' é a chave.
    await _taskBox.put(task.id, task);

    // Adiciona na lista em memória
    _tasks.add(task);

    // Notifica a UI
    notifyListeners();
  }

  // U: Update (Atualizar uma tarefa existente)
  Future<void> updateTask(Task task) async {
    // Como 'Task' estende 'HiveObject', podemos apenas chamar .save()
    // O Hive encontra a tarefa pela sua chave e a atualiza.
    await task.save();

    // Atualiza a tarefa na lista em memória
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  // D: Delete (Remover uma tarefa)
  Future<void> deleteTask(Task task) async {
    // Remove do Hive
    await task.delete();

    // Remove da lista em memória
    _tasks.removeWhere((t) => t.id == task.id);

    // Notifica a UI
    notifyListeners();
  }

  // Método 'helper' para marcar/desmarcar tarefa como concluída
  Future<void> toggleTaskCompletion(Task task) async {
    task.isCompleted = !task.isCompleted;
    await updateTask(task); // Reutiliza o método de update
  }
}