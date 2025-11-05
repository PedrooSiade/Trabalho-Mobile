import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'models/task_model.dart';
import 'providers/task_provider.dart';
import 'screens/task_list_screen.dart';

void main() async {
  // 1. Garantir que os Widgets do Flutter estão inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Obter o diretório de documentos do app
  final appDocumentDir = await getApplicationDocumentsDirectory();

  // 3. Inicializar o Hive nesse diretório
  await Hive.initFlutter(appDocumentDir.path);

  // 4. Registrar os adaptadores gerados
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  Hive.registerAdapter(CategoryAdapter());

  // 5. Abrir a "box" (tabela) de tarefas
  await Hive.openBox<Task>('tasks');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 6. Configurar o Provider
    return ChangeNotifierProvider(
      create: (context) => TaskProvider()..loadTasks(), // Carrega as tarefas na inicialização
      child: MaterialApp(
        title: 'Gerenciador de Tarefas',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark, // Opcional: Um tema escuro fica legal
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: TaskListScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}