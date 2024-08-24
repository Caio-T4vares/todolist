import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../constants/colors.dart';
import '../model/group.dart';
import '../model/todo.dart';
import '../widgets/todo_item.dart';

import '../controllers/home_controller.dart';

class Home extends StatelessWidget {
  Home({super.key});
  final controller = Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: AppBar(backgroundColor: tdBGColor, elevation: 0),
      drawer: sideBar(),
      body: Column(
        children: [
          Container(
            color: tdBGColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Column(
              children: [
                searchBar(),
                const SizedBox(
                  height: 20,
                ),
                Obx(
                  () => Text(
                    controller.selectedGroup.value.name,
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemBuilder: (context, index) {
                  final ToDo todo = controller.toDos[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ToDoItem(todo: todo),
                  );
                },
                itemCount: controller.toDos.length,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin:
                        const EdgeInsets.only(bottom: 20, right: 20, left: 20),
                  ),
                ),
                Obx(() => Container(
                    margin: const EdgeInsets.only(bottom: 20, right: 20),
                    child: controller.selectedGroup.value.name != "Concluded"
                        ? ElevatedButton(
                            onPressed: () {
                              _showAddToDoModal();
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: tdBlue,
                                minimumSize: const Size(60, 60),
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6))),
                            child: const Text('+',
                                style: TextStyle(
                                    fontSize: 40, color: Colors.white)),
                          )
                        : const Text(""))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddToDoModal() {
    controller.toDoNameController.text = "";
    controller.toDoDescriptionController.text = "";
    controller.toDoDateController.text = "";

    Get.dialog(PopScope(
        onPopInvoked: (didPop) async {
          if (didPop) {
            controller.dropDownOption.value = "";
          }
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
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'ToDo name',
                    ),
                    controller: controller.toDoNameController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Description',
                    ),
                    controller: controller.toDoDescriptionController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
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
                    onTap: () async {
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
                      if (pickedDate != null) {
                        controller.toDoDateController.text =
                            DateFormat("dd-MM-yyyy")
                                .format(pickedDate)
                                .toString();
                        controller.choosedDate = pickedDate;
                      }
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Obx(() {
                    return DropdownButton<String>(
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
                        print(value);
                        controller.dropDownOption.value = value!;
                      },
                    );
                  }),
                ),
                Obx(() => TextButton(
                    onPressed: controller.dropDownOption.value.isEmpty
                        ? null
                        : () {
                            if (controller.choosedDate != null) {
                              ToDo todo = ToDo(
                                  id: DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                                  toDoText: controller.toDoNameController.text,
                                  description:
                                      controller.toDoDescriptionController.text,
                                  deadline: controller.choosedDate,
                                  groupId: controller.dropDownOption.value);
                              controller.addToDo(todo);
                              Get.back();
                            } else {
                              ToDo todo = ToDo(
                                  id: DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                                  toDoText: controller.toDoNameController.text,
                                  description:
                                      controller.toDoDescriptionController.text,
                                  groupId: controller.dropDownOption.value);
                              controller.addToDo(todo);
                              Get.back();
                            }
                          },
                    child: const Text("Confirm")))
              ],
            ),
          ),
        )));
  }

  void _confirmDeleteGroupModal(Group group) {
    Get.dialog(AlertDialog(
      title: const Text('Delete Group'),
      content:
          Text('Are you sure you want to delete the group "${group.name}"?'),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Get.back();
          },
        ),
        TextButton(
          child: const Text('Delete'),
          onPressed: () {
            controller.deleteGroup(group);
            Get.back();
          },
        ),
      ],
    ));
  }

  Drawer sideBar() {
    return Drawer(
      child: Obx(() => ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.grey),
                  child: Text('Menu',
                      style: TextStyle(color: Colors.white, fontSize: 24))),
              for (Group group in controller.groupList)
                ListTile(
                  leading: const Icon(Icons.group),
                  title: Text(group.name),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      _confirmDeleteGroupModal(group);
                    },
                  ),
                  onTap: () {
                    controller.changeGroup(group);
                    Get.back();
                  },
                ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Create new group'),
                onTap: () {
                  _showCreateGroupModal();
                },
              ),
            ],
          )),
    );
  }

  void _showCreateGroupModal() {
    Get.dialog(AlertDialog(
      title: const Text('Create new group'),
      content: TextField(
        controller: controller.groupController,
        decoration: const InputDecoration(hintText: 'Group Name'),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Get.back();
          },
        ),
        TextButton(
          child: const Text('Create'),
          onPressed: () {
            controller.addGroup(controller.groupController.text);
            Get.back();
          },
        )
      ],
    ));
  }

  AppBar buildAppBar() {
    return AppBar(
        backgroundColor: tdBGColor,
        elevation: 0,
        title:
            const Row(children: [Icon(Icons.menu, color: tdBlack, size: 30)]));
  }

  Widget searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: TextField(
        onChanged: (value) => controller.filterToDos(value),
        decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(0),
            prefixIcon: Icon(
              Icons.search,
              color: tdBlack,
              size: 20,
            ),
            prefixIconConstraints: BoxConstraints(maxHeight: 20, minWidth: 25),
            border: InputBorder.none,
            hintText: 'Search',
            hintStyle: TextStyle(color: tdGrey)),
      ),
    );
  }
}

extension OffsetExtension on Offset {
  Animation<Offset> mapToOffset() {
    return Tween<Offset>(
      begin: this,
      end: this,
    ).animate(CurvedAnimation(
      parent: const AlwaysStoppedAnimation<double>(1.0),
      curve: Curves.linear,
    ));
  }
}
