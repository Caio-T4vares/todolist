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
  RxList<Group> groupList = <Group>[].obs; // sao as listas de todo
  var selectedGroup = Group(id: "", name: "").obs;
  List<ToDo> allToDos = <ToDo>[];
  var dropDownOption = ''.obs;
  var filteredTodos = [].obs; // vou usar depois, por enquanto deixe assim
  RxList<ToDo> toDos = <ToDo>[].obs;
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
    loadToDos();
    listenToNotifications();
  }

  Future<String> get _localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get _localTodosFile async {
    final path = await _localPath;
    return File('$path/todos.json');
  }

  Future<File> get _localGroupFile async {
    final path = await _localPath;
    return File('$path/groups.json');
  }

  Future<void> saveGroups() async {
    final file = await _localGroupFile;
    List<Map<String, dynamic>> jsonGroups =
        groupList.map((group) => group.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonGroups));
  }

  Future<void> saveTodos() async {
    final file = await _localTodosFile;
    List<Map<String, dynamic>> jsonGroups =
        allToDos.map((todo) => todo.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonGroups));
  }

  Future<void> loadGroups() async {
    try {
      final file = await _localGroupFile;
      if (file.existsSync()) {
        String jsonString = await file.readAsString();
        List<dynamic> jsonData = jsonDecode(jsonString);
        groupList.value = jsonData.map((item) => Group.fromJson(item)).toList();
      } else {
        groupList.add(Group(id: "AllTodos", name: "All ToDos"));
        groupList.add(Group(id: "concluded", name: "Concluded"));
        saveGroups();
      }
    } catch (e) {
      print("Falha para carregar os grupos: $e");
    }
    // o grupo não é selecionado, o ideal é que ele mostre todas as tasks
    selectedGroup.value = groupList[0];
    toDos.refresh();
    selectedGroup.refresh();
    groupList.refresh();
    update();
  }

  Future<void> loadToDos() async {
    try {
      final file = await _localTodosFile;
      if (file.existsSync()) {
        String jsonString = await file.readAsString();
        List<dynamic> jsonData = jsonDecode(jsonString);
        allToDos = jsonData.map((item) => ToDo.fromJson(item)).toList();
        toDos.value = List.from(allToDos); // copia de um pro outro
      }
    } catch (e) {
      print("Falha para carregar os todos: $e");
    }
    // o grupo não é selecionado, o ideal é que ele mostre todas as tasks
    toDos.refresh();
    selectedGroup.refresh();
    groupList.refresh();
    update();
  }

  void addToDo(ToDo todo) {
    if (todo.toDoText.isNotEmpty) {
      Group? group = groupList.firstWhere((grp) => grp.id == todo.groupId);
      print(group.id);
      print(group.name);
      print(todo.groupId);
      if (group.id == selectedGroup.value.id) toDos.add(todo);
      allToDos.add(todo);
      if (todo.deadline != null) {
        confirmChanges(todo, todo.groupId);
      }
      sortToDos();
      saveTodos();
      saveGroups();
      toDos.refresh();
      selectedGroup.refresh();
      toDoController.clear();
      dropDownOption.value = "";
      update();
    }
  }

  void deleteToDo(String id) {
    if (id.isNotEmpty) {
      allToDos.removeWhere((todo) => todo.id == id);
      toDos.removeWhere((todo) => todo.id == id);
    }
    sortToDos();
    saveGroups();
    toDos.refresh();
    selectedGroup.refresh();
    update();
  }

  void changeToDoStatus(ToDo todo) {
    // if (!groupList.any((grp) => grp.name == todo.previouslyGroupName)) {
    //   // se o grupo anterior não existe mais
    //   Future.delayed(
    //       const Duration(milliseconds: 500), () => deleteToDo(todo.id));
    //   return;
    // }
    // if (selectedGroup.value.name == "Concluded") {
    //   todo.isDone = !todo.isDone;
    //   groupList
    //       .firstWhere((grp) => grp.name == todo.previouslyGroupName)
    //       .myToDos
    //       .add(ToDo(
    //           id: todo.id,
    //           toDoText: todo.toDoText,
    //           deadline: todo.deadline,
    //           description: todo.description,
    //           previouslyGroupName: todo.previouslyGroupName,
    //           isDone: todo.isDone));
    // } else {
    //   todo.isDone = !todo.isDone;
    //   groupList.firstWhere((grp) => grp.name == "Concluded").myToDos.add(ToDo(
    //       id: todo.id,
    //       toDoText: todo.toDoText,
    //       deadline: todo.deadline,
    //       description: todo.description,
    //       previouslyGroupName: todo.previouslyGroupName,
    //       isDone: todo.isDone));
    // }
    // Future.delayed(
    //     const Duration(milliseconds: 500), () => deleteToDo(todo.id));
    // saveGroups();

    // toDos.refresh();
    // selectedGroup.refresh();
    // update();
  }

  void changeGroup(Group group) {
    Group newGrp = groupList.firstWhere((grp) => group.name == grp.name);
    selectedGroup.value = newGrp;
    if (newGrp.name == "All ToDos") {
      toDos.value = List.from(allToDos);
    } else if (newGrp.name == "Concluded") {
      toDos.value = allToDos.where((todo) => todo.isDone).toList();
    } else {
      toDos.value =
          allToDos.where((todo) => todo.groupId == newGrp.id).toList();
    }
    //toDos.value = selectedGroup.value.myToDos;
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
          name: groupName);
      groupList.add(newGroup);
      selectedGroup.value = newGroup;
      toDos.value =
          allToDos.where((todo) => todo.groupId == newGroup.id).toList();

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
          return Group(id: "id", name: "name");
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
      // toDos.value = selectedGroup.value.myToDos.where((todo) {
      //   String str = todo.toDoText.toLowerCase();
      //   return str.contains(RegExp("^$toDosFilterNameLowerCased"));
      // }).toList();
    } else {
      //toDos.value = selectedGroup.value.myToDos;
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

  void confirmChanges(ToDo todo, String groupId) {
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
    allToDos.sort(sortToDoList);
    toDos.sort(sortToDoList);
    toDos.refresh();
    update();
  }

  int sortToDoList(a, b) {
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
  }

  listenToNotifications() {
    print("Listening to notification");
    LocalNotifications.onClickNotification.stream.listen((event) {
      print(event);
      Get.toNamed('/home', arguments: event);
    });
  }
}
