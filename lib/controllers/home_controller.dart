import 'dart:convert';

import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_todo_list/model/group.dart';
import '../local_notifications.dart';
import '../model/todo.dart';

class HomeController extends GetxController {
  // List<ToDo> todosList = <ToDo>[]; // são as todos exibidas
  RxList<Group> groupList = <Group>[].obs; // sao as listas de todo
  var selectedGroup = Group(id: "id", name: "name", myToDos: []).obs;
  var toDos = [].obs;
  DateTime? choosedDate;
  final toDoController = TextEditingController();
  final groupController = TextEditingController();
  final toDoNameController = TextEditingController();
  final toDoDescriptionController = TextEditingController();
  final toDoDateController = TextEditingController();
  @override
  void onInit() {
    super.onInit();
    groupList = [
      Group(id: "1", name: "Work", myToDos: []),
      Group(id: "2", name: "Personal", myToDos: [])
    ].obs;
    selectedGroup.value = groupList[0];
    toDos.value = selectedGroup.value.myToDos;
    listenToNotifications();
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
      String toDosFilterNameLowerCased = toDosFilterName.toLowerCase();
      toDos.value = selectedGroup.value.myToDos
          .where((todo) =>
              todo.toDoText.contains(RegExp("^$toDosFilterNameLowerCased")))
          .toList();
    } else {
      toDos.value = selectedGroup.value.myToDos;
    }
    toDos.refresh();
    update();
  }

  Future<void> selectDate(ToDo todo) async {
    DateTime? pickedDate = await showDatePicker(
        context: Get.context!,
        firstDate: DateTime.now(),
        lastDate: DateTime(2028),
        helpText: "Select the deadline for you ToDo.",
        cancelText: "Cancel",
        confirmText: "Chose deadline",
        fieldHintText: "Day/Month/Year",
        errorFormatText: "Enter valid date",
        errorInvalidText: "Enter valid range date");
    if (pickedDate != null && pickedDate != todo.deadline) {
      toDoDateController.text =
          DateFormat("dd-MM-yyyy").format(pickedDate).toString();
      choosedDate = pickedDate;
    }
    selectedGroup.refresh();
    toDos.refresh();
    update();
  }

  void confirmChanges(ToDo todo) {
    if (choosedDate != null) {
      int daysUntilDeadline = choosedDate!.difference(DateTime.now()).inDays;
      Duration timeToNotify = Duration(
          days: daysUntilDeadline,
          seconds:
              5); // os segundos são só para o caso de a task ser no mesmo dia.
      LocalNotifications.showScheduleNotification(
          title: "The deadline of your ToDo '${todo.toDoText}' is coming.",
          body: "Your ToDo expires today",
          payload: "payload",
          dayToNotify: timeToNotify);
    }
    todo.deadline = choosedDate;
    todo.description = toDoDescriptionController.text;
    todo.toDoText = toDoNameController.text;
    selectedGroup.refresh();
    toDos.refresh();
    update();
  }

  listenToNotifications() {
    print("Listening to notification");
    LocalNotifications.onClickNotification.stream.listen((event) {
      print(event);
      Get.toNamed('/home', arguments: event);
    });
  }
}
