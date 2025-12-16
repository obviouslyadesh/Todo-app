import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:my_todo_app/models/task.dart';

class DatabaseService {
  static const String _tasksBox = 'tasksBox';
  static Box<Task>? _tasks;

  static Future<void> init() async {
    final appDocumentDirectory = 
        await path_provider.getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }
    
    // Open boxes
    _tasks = await Hive.openBox<Task>(_tasksBox);
  }

  static Box<Task> get tasksBox {
    if (_tasks == null) {
      throw Exception('Database not initialized');
    }
    return _tasks!;
  }

  static Future<void> addTask(Task task) async {
    await tasksBox.put(task.id, task);
  }

  static Future<void> updateTask(Task task) async {
    await task.save();
  }

  static Future<void> deleteTask(String taskId) async {
    await tasksBox.delete(taskId);
  }

  static List<Task> getAllTasks() {
    return tasksBox.values.toList();
  }

  static List<Task> getCompletedTasks() {
    return tasksBox.values.where((task) => task.isCompleted).toList();
  }

  static List<Task> getPendingTasks() {
    return tasksBox.values.where((task) => !task.isCompleted).toList();
  }

  static Future<void> clearAllTasks() async {
    await tasksBox.clear();
  }
}