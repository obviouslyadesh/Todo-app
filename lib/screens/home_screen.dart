import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_todo_app/models/task.dart';
import 'package:my_todo_app/services/database.dart';
import 'package:my_todo_app/widgets/add_task_dialog.dart';
import 'package:my_todo_app/widgets/task_tile.dart';
import 'package:my_todo_app/utils/colors.dart';
import 'package:my_todo_app/utils/theme_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // 0: All, 1: Pending, 2: Completed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskFlow Pro'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        actions: [
          // Theme toggle button
          IconButton(
            onPressed: () {
              Provider.of<ThemeManager>(context, listen: false).toggleTheme();
            },
            icon: Icon(
              Provider.of<ThemeManager>(context).isDarkMode 
                  ? Icons.light_mode 
                  : Icons.dark_mode,
            ),
          ),
          // Notification icon with custom badge
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  final pendingCount = DatabaseService.getPendingTasks().length;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '$pendingCount pending task${pendingCount != 1 ? "s" : ""}',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications),
              ),
              if (DatabaseService.getPendingTasks().isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      DatabaseService.getPendingTasks().length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Clear all button
          if (DatabaseService.getAllTasks().isNotEmpty)
            IconButton(
              onPressed: _showClearAllDialog,
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear All Tasks',
            ),
        ],
      ),
      body: Column(
        children: [
          // Segmented Control
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTabButton('All', 0),
                  _buildTabButton('Pending', 1),
                  _buildTabButton('Completed', 2),
                ],
              ),
            ),
          ),
          // Task List
          Expanded(
            child: _buildTaskList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    List<Task> tasks;
    
    switch (_selectedIndex) {
      case 0:
        tasks = DatabaseService.getAllTasks();
        break;
      case 1:
        tasks = DatabaseService.getPendingTasks();
        break;
      case 2:
        tasks = DatabaseService.getCompletedTasks();
        break;
      default:
        tasks = [];
    }

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedIndex == 2 ? Icons.check_circle_outline : Icons.list,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedIndex == 0
                  ? 'No tasks yet!\nTap + to add your first task'
                  : _selectedIndex == 1
                      ? 'No pending tasks!'
                      : 'No completed tasks yet!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskTile(
          task: task,
          onToggleComplete: (task) {
            setState(() {
              task.isCompleted = !task.isCompleted;
              DatabaseService.updateTask(task);
            });
          },
          onDelete: (task) {
            _deleteTask(task);
          },
          onEdit: (task) {
            _showEditTaskDialog(task);
          },
        );
      },
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        onSave: (task) async {
          await DatabaseService.addTask(task);
          setState(() {});
        },
      ),
    );
  }

  void _showEditTaskDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        taskToEdit: task,
        onSave: (task) async {
          await DatabaseService.updateTask(task);
          setState(() {});
        },
      ),
    );
  }

  void _deleteTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              DatabaseService.deleteTask(task.id);
              setState(() {});
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Tasks'),
        content: const Text('Are you sure you want to delete all tasks?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              DatabaseService.clearAllTasks();
              setState(() {});
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}