import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:flutter/material.dart';
import '../model/todo.dart';

class HomeController extends GetxController {
  final todosList = [].obs;

  final toDoController = TextEditingController();

  void addToDo(String text) {
    if (text.isNotEmpty) {
      todosList.add(ToDo(id: DateTime.now().toString(), toDoText: text));
    }
    toDoController.clear();
    update();
  }

  void deleteToDo(String id) {
    if (id.isNotEmpty) {
      todosList.removeWhere((el) => el.id == id);
    }
    update();
  }

  void changeToDoStatus(ToDo todo) {
    todo.isDone = !todo.isDone;
    todosList.refresh();
    update();
  }
}
