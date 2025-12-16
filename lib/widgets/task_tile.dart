import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:my_todo_app/models/task.dart';
import 'package:my_todo_app/utils/colors.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final Function(Task) onToggleComplete;
  final Function(Task) onDelete;
  final Function(Task) onEdit;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => onEdit(task),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
            ),
            SlidableAction(
              onPressed: (context) => onDelete(task),
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (value) => onToggleComplete(task),
              activeColor: AppColors.primary,
            ),
            title: Text(
              task.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                decoration: task.isCompleted 
                    ? TextDecoration.lineThrough 
                    : TextDecoration.none,
                color: task.isCompleted 
                    ? AppColors.textSecondary 
                    : AppColors.textPrimary,
              ),
            ),
            subtitle: task.description.isNotEmpty
                ? Text(
                    task.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      decoration: task.isCompleted 
                          ? TextDecoration.lineThrough 
                          : TextDecoration.none,
                    ),
                  )
                : null,
            trailing: task.dueDate != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${task.dueDate!.day}/${task.dueDate!.month}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        ),
      ),
    );
  }
}