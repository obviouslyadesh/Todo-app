import 'package:hive/hive.dart';

part 'task.g.dart'; // This will be generated

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  bool isCompleted;
  
  @HiveField(4)
  DateTime createdAt;
  
  @HiveField(5)
  DateTime? dueDate;
  
  @HiveField(6)
  String category;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    this.category = 'General',
  });

  Task.create({
    required this.title,
    this.description = '',
    this.category = 'General',
    this.dueDate,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString(),
       createdAt = DateTime.now(),
       isCompleted = false;
}