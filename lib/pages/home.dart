import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Column(
              children: [
                searchBar(),
                SizedBox(height: 20,),
                Obx(() => 
                  Text(
                    controller.selectedGroup.value.name != 'name'
                        ? controller.selectedGroup.value.name
                        : 'No Groups',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(height: 20,)
              ],
            ),
          ),
          Expanded(
            child: Obx(() =>
              ListView.builder(
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
                    margin: EdgeInsets.only(bottom: 20, right: 20, left: 20),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 0.0),
                          blurRadius: 10.0,
                          spreadRadius: 0.0
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: controller.toDoController,
                      decoration: const InputDecoration(hintText: 'Add new Item', border: InputBorder.none),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20, right: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      controller.addToDo(controller.toDoController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:  tdBlue,
                      minimumSize: const Size(60,60),
                      elevation: 10,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))
                    ),
                    child: const Text('+', style: TextStyle(fontSize: 40, color: Colors.white)),
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
