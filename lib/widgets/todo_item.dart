import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_todo_list/constants/colors.dart';
import 'package:intl/intl.dart';
import '../controllers/home_controller.dart';
import '../model/group.dart';
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
        onTap: () => _showToDoDetails(todo),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        tileColor: Colors.white,
        leading: IconButton(
          onPressed: () => controller.changeToDoStatus(todo),
          icon: Icon(
              todo.isDone ? Icons.check_box : Icons.check_box_outline_blank),
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
        subtitle: todo.deadline == null
            ? null
            : Text(
                formatDate(todo.deadline!),
                style: const TextStyle(color: tdBlue),
              ),
        titleAlignment: ListTileTitleAlignment.center,
      ),
    );
  }

  String formatDate(DateTime date) {
    return DateFormat("dd-MM-yyyy").format(date).toString();
  }

  void _showToDoDetails(ToDo todo) {
    controller.dropDownOption.value = todo.groupId;
    controller.toDoNameController.text = todo.toDoText;
    controller.toDoDescriptionController.text =
        todo.description == null ? "" : todo.description!;
    controller.toDoDateController.text =
        todo.deadline == null ? "" : formatDate(todo.deadline!);
    Get.dialog(PopScope(
      onPopInvoked: (didPop) {
        if (didPop) controller.dropDownOption.value = "";
      },
      child: Dialog(
        alignment: Alignment.center,
        child: SizedBox(
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'ToDo name',
                  ),
                  controller: controller.toDoNameController,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  controller: controller.toDoDescriptionController,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  decoration: const InputDecoration(
                      labelText: "Date",
                      filled: true,
                      prefixIcon: Icon(Icons.calendar_today),
                      enabledBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: tdBlue))),
                  readOnly: true,
                  controller: controller.toDoDateController,
                  onTap: () => controller.selectDate(todo),
                ),
              ),
              Obx(() => Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: DropdownButton<String>(
                      hint: Text(controller.dropDownOption.value.isEmpty
                          ? 'Selected Group'
                          : controller.dropDownOption.value),
                      value: controller.dropDownOption.value.isEmpty
                          ? null
                          : controller.dropDownOption.value,
                      items: controller.groupList.where((group) {
                        if (group.name == "All ToDos" ||
                            group.name == "Concluded") {
                          return false;
                        } else {
                          return true;
                        }
                      }).map((Group group) {
                        return DropdownMenuItem<String>(
                          value: group.id,
                          child: Text(group.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        print("valor: $value");
                        controller.dropDownOption.value = value!;
                      },
                    ),
                  )),
              TextButton(
                  onPressed: () {
                    if (controller.toDoNameController.text != "") {
                      controller.confirmChanges(todo);
                    }
                    Get.back();
                  },
                  child: const Text("Confirm"))
            ],
          ),
        ),
      ),
    ));
  }
}
