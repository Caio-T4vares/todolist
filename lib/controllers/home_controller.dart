import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_todo_list/model/group.dart';
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
    loadGroups();
  }

  Future<String> get _localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/groups.json');
  }

  Future<void> saveGroups() async {
    final file = await _localFile;
    List<Map<String, dynamic>> jsonGroups =
        groupList.map((group) => group.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonGroups));
  }

  Future<void> loadGroups() async {
    try {
      final file = await _localFile;

      if (file.existsSync()) {
        String jsonString = await file.readAsString();
        List<dynamic> jsonData = jsonDecode(jsonString);

        groupList.value = jsonData.map((item) => Group.fromJson(item)).toList();
        if (groupList.isEmpty) {
          groupList.add(Group(
              id: DateTime.now().millisecond.toString(),
              name: "Work",
              myToDos: []));
          groupList.add(Group(
              id: DateTime.now().millisecond.toString(),
              name: "Personal",
              myToDos: []));
          saveGroups();
          selectedGroup.value = groupList[0];
          toDos.value = selectedGroup.value.myToDos;
        } else {
          selectedGroup.value = groupList[0];
          toDos.value = selectedGroup.value.myToDos;
        }
      }
    } catch (e) {
      print("Falha para carregar os grupos: $e");
    }
  }

  void addToDo(String text) {
    if (text.isNotEmpty) {
      selectedGroup.value.myToDos.add(ToDo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          toDoText: text));
    }
    saveGroups();
    toDos.refresh();
    selectedGroup.refresh();
    toDoController.clear();
    update();
  }

  void deleteToDo(String id) {
    if (id.isNotEmpty) {
      selectedGroup.value.myToDos.removeWhere((todo) => todo.id == id);
    }
    //saveGroups();
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
      toDos.value = selectedGroup.value.myToDos;
      saveGroups();
      toDos.refresh();
      groupController.clear();
      groupList.refresh();
    }
  }

  void deleteGroup(Group removedGroup) {
    if (removedGroup.id == selectedGroup.value.id) {
      selectedGroup.value =
          groupList.firstWhere((grp) => grp.id != removedGroup.id, orElse: () {
        toDos.value = [];
        return Group(id: "id", name: "name", myToDos: []);
      });
    }
    groupList.removeWhere((grp) => grp.id == removedGroup.id);
    saveGroups();
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
    todo.deadline = choosedDate;
    todo.description = toDoDescriptionController.text;
    todo.toDoText = toDoNameController.text;
    selectedGroup.refresh();
    toDos.refresh();
    update();
  }
}
