import 'dart:convert';

import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:get/get.dart';
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
    loadGroups();
    listenToNotifications();
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
        if (groupList.isNotEmpty) {
          selectedGroup.value = groupList[0];
          toDos.value = selectedGroup.value.myToDos;
        }
      } else {
        groupList.add(Group(id: "general", name: "General", myToDos: []));
        groupList.add(Group(id: "concluded", name: "Concluded", myToDos: []));
        selectedGroup.value = groupList[0];
        toDos.value = selectedGroup.value.myToDos;
        saveGroups();
      }
    } catch (e) {
      print("Falha para carregar os grupos: $e");
    }
    toDos.refresh();
    selectedGroup.refresh();
    groupList.refresh();
    update();
  }

  void addToDo(String text) {
    if (text.isNotEmpty && selectedGroup.value.name != "Concluded") {
      selectedGroup.value.myToDos.add(ToDo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          toDoText: text,
          previouslyGroupName: selectedGroup.value.name));
    }
    sortToDos();
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
    sortToDos();
    saveGroups();
    toDos.refresh();
    selectedGroup.refresh();
    update();
  }

  void changeToDoStatus(ToDo todo) {
    if (!groupList.any((grp) => grp.name == todo.previouslyGroupName)) {
      // se o grupo anterior não existe mais
      Future.delayed(
          const Duration(milliseconds: 500), () => deleteToDo(todo.id));
      return;
    }
    if (selectedGroup.value.name == "Concluded") {
      todo.isDone = !todo.isDone;
      groupList
          .firstWhere((grp) => grp.name == todo.previouslyGroupName)
          .myToDos
          .add(ToDo(
              id: todo.id,
              toDoText: todo.toDoText,
              deadline: todo.deadline,
              description: todo.description,
              previouslyGroupName: todo.previouslyGroupName,
              isDone: todo.isDone));
    } else {
      todo.isDone = !todo.isDone;
      groupList.firstWhere((grp) => grp.name == "Concluded").myToDos.add(ToDo(
          id: todo.id,
          toDoText: todo.toDoText,
          deadline: todo.deadline,
          description: todo.description,
          previouslyGroupName: todo.previouslyGroupName,
          isDone: todo.isDone));
    }
    Future.delayed(
        const Duration(milliseconds: 500), () => deleteToDo(todo.id));
    saveGroups();

    toDos.refresh();
    selectedGroup.refresh();
    update();
  }

  void changeGroup(Group group) {
    Group newGrp = groupList.firstWhere((grp) => group.name == grp.name);
    selectedGroup.value = newGrp;
    toDos.value = selectedGroup.value.myToDos;
    sortToDos();
    toDos.refresh();
    selectedGroup.refresh();
    groupList.refresh();
    update();
  }

  void addGroup(String groupName) {
    print(groupList.any((el) => el.name == groupName));
    if (groupName.isNotEmpty && !groupList.any((el) => el.name == groupName)) {
      // n pode add de mesmo nome
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
    if (removedGroup.name != "Concluded") {
      if (removedGroup.id == selectedGroup.value.id) {
        selectedGroup.value = groupList
            .firstWhere((grp) => grp.id != removedGroup.id, orElse: () {
          toDos.value = [];
          return Group(id: "id", name: "name", myToDos: []);
        });
      }
      groupList.removeWhere((grp) => grp.id == removedGroup.id);
    }
    saveGroups();
    groupList.refresh();
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
      int daysUntilDeadline = choosedDate!.day - DateTime.now().day;
      int hoursUntilMidnight = 24 - DateTime.now().hour;
      if (daysUntilDeadline == 0) {
        Duration timeToNotify = const Duration(
            seconds:
                5); // os segundos são só para o caso de a task ser no mesmo dia.
        LocalNotifications.showScheduleNotification(
            title: "The deadline of your ToDo '${todo.toDoText}' is coming.",
            body: "Your ToDo expires today",
            payload: "payload",
            dayToNotify: timeToNotify,
            id: todo.id.substring(3, 7));
      } else {
        Duration timeToNotify = Duration(
            days: daysUntilDeadline - 1,
            hours: hoursUntilMidnight,
            seconds:
                5); // os segundos são só para o caso de a task ser no mesmo dia.
        LocalNotifications.showScheduleNotification(
            title: "The deadline of your ToDo '${todo.toDoText}' is coming.",
            body: "Your ToDo expires today",
            payload: "payload",
            dayToNotify: timeToNotify,
            id: todo.id.substring(3, 7));
      }
    }
    todo.deadline = choosedDate;
    choosedDate = null;
    todo.description = toDoDescriptionController.text;
    todo.toDoText = toDoNameController.text;
    sortToDos();
    selectedGroup.refresh();
    toDos.refresh();
    update();
  }

  void sortToDos() {
    List<ToDo> newList = List.from(toDos);
    newList.sort((a, b) {
      if (a.deadline == null && b.deadline == null) {
        return 0; // Se ambos são nulos, são iguais
      } else if (a.deadline == null) {
        return 1; // Se 'a' é nulo, ele vai para o final
      } else if (b.deadline == null) {
        return -1; // Se 'b' é nulo, 'a' vem antes
      } else {
        return a.deadline!
            .compareTo(b.deadline!); // Comparar os valores não nulos
      }
    });
    selectedGroup.value.myToDos = List.from(newList);
    toDos.value = selectedGroup.value.myToDos;
  }

  listenToNotifications() {
    print("Listening to notification");
    LocalNotifications.onClickNotification.stream.listen((event) {
      print(event);
      Get.toNamed('/home', arguments: event);
    });
  }
}
