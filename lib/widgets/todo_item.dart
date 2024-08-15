import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo_list/constants/colors.dart';

import '../controllers/home_controller.dart';
import '../model/todo.dart';

class ToDoItem extends StatelessWidget {
  final ToDo todo;

  ToDoItem({
    super.key,
    required this.todo,
  });
  final HomeController controller = Get.find<HomeController>();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ListTile(
        onTap: () {
          controller.changeToDoStatus(todo);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        tileColor: Colors.white,
        leading: Icon(
          todo.isDone ? Icons.check_box : Icons.check_box_outline_blank,
          color: tdBlue,
        ),
        title: Text(
          todo.toDoText,
          style: TextStyle(
              fontSize: 16,
              color: tdBlack,
              decoration: todo.isDone ? TextDecoration.lineThrough : null),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(0),
          margin: const EdgeInsets.symmetric(vertical: 8),
          height: 35,
          width: 35,
          decoration: BoxDecoration(
              color: tdRed, borderRadius: BorderRadius.circular(5)),
          child: IconButton(
            color: Colors.white,
            iconSize: 18,
            icon: const Icon(Icons.delete),
            onPressed: () {
              controller.deleteToDo(todo.id);
            },
          ),
        ),
      ),
    );
  }
}
