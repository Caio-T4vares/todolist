import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:flutter/material.dart';
import 'package:my_todo_list/model/group.dart';
import '../model/todo.dart';

class HomeController extends GetxController {
  // List<ToDo> todosList = <ToDo>[]; // são as todos exibidas
  RxList<Group> groupList = <Group>[].obs; // sao as listas de todo
  var selectedGroup = Group(id: "id", name: "name", myToDos: []).obs;
  var toDos = [].obs;
  final toDoController = TextEditingController();
  final groupController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    groupList = [
      Group(id: "1", name: "Work", myToDos: []),
      Group(id: "2", name: "Personal", myToDos: [])
    ].obs;
    selectedGroup.value = groupList[0];
    toDos.value = selectedGroup.value.myToDos;
  }

  void addToDo(String text) {
    if (text.isNotEmpty) {
      selectedGroup.value.myToDos.add(ToDo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          toDoText: text));
    }
    toDos.refresh();
    selectedGroup.refresh();
    toDoController.clear();
    update();
  }

  void deleteToDo(String id) {
    if (id.isNotEmpty) {
      selectedGroup.value.myToDos.removeWhere((todo) => todo.id == id);
    }
    toDos.refresh();
    selectedGroup.refresh();
    update();
  }

  void changeToDoStatus(ToDo todo) {
    todo.isDone = !todo.isDone;
    toDos.refresh();
    selectedGroup.refresh();
    update();
  }

  void changeGroup(Group group) {
    Group newGrp = groupList.firstWhere((grp) => group.name == grp.name);
    selectedGroup.value = newGrp;
    toDos.value = selectedGroup.value.myToDos;
    toDos.refresh();
    selectedGroup.refresh();
    groupList.refresh();
    update();
  }

  void addGroup(String groupName) {
    if (groupName.isNotEmpty) {
      Group newGroup = Group(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: groupName,
          myToDos: []);
      groupList.add(newGroup);
      selectedGroup.value = newGroup;
      toDos.refresh();
      groupController.clear();
      groupList.refresh();
    }
  }

  void deleteGroup(Group removedGroup) {
    if (removedGroup.id == selectedGroup.value.id) {
      selectedGroup.value =
          groupList.firstWhere((grp) => grp.id != removedGroup.id);
    }
    groupList.removeWhere((grp) => grp.id == removedGroup.id);
    selectedGroup.refresh();
    toDos.refresh();
    update();
  }

  void filterToDos(String toDosFilterName) {
    if (toDosFilterName.isNotEmpty) {
      toDos.value = selectedGroup.value.myToDos
          .where((todo) => todo.toDoText.contains(RegExp("^$toDosFilterName")))
          .toList();
    } else {
      toDos.value = selectedGroup.value.myToDos;
    }
    toDos.refresh();
    update();
  }
}
