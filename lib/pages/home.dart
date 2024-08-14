import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../constants/colors.dart';
import '../model/group.dart';
import '../model/todo.dart';
import '../widgets/todo_item.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<ToDo> toDosList = [];
  List<ToDo> _foundToDo = [];
  List<Group> groupsList = [];
  final _toDoController = TextEditingController();
  final _groupNameController = TextEditingController();
  Group? _selectedGroup;

  @override
  void initState() {
    groupsList = [
      Group(id: '1', name: 'Work', myToDos: ToDo.toDoList()),
      Group(id: '2', name: 'Personal', myToDos: [])
    ];
    _selectedGroup = groupsList[0];
    _foundToDo = _selectedGroup!.myToDos!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: _buildAppBar(),
      drawer: _sideBar(),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              children: [
                searchBar(),
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 50, bottom: 20),
                        child: (Text(
                          '${_selectedGroup!.name} ToDos',
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
                        )),
                      ),
                      for (ToDo loopToDo in _foundToDo)
                        ToDoItem(
                          todo: loopToDo,
                          onToDoChanged: _handleToDoChange,
                          onDeleteItem: _handleDeleteItem,
                        )
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 5, right: 5, left: 5),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0.0, 0.0),
                                    blurRadius: 10.0,
                                    spreadRadius: 0.0)
                              ],
                              borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            controller: _toDoController,
                            decoration: InputDecoration(
                                hintText: 'Add new item',
                                border: InputBorder.none),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 20, left: 5, right: 15, top: 15),
                        child: ElevatedButton(
                          child: Text('+', style: TextStyle(fontSize: 40, color: Colors.white)),
                          onPressed: () {
                            _addToDoItem(_toDoController.text);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: tdBlue,
                              minimumSize: Size(60, 60),
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6))),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleToDoChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
  }

  void _handleDeleteItem(String id) {
    setState(() {
      _selectedGroup!.myToDos!.removeWhere((item) => item.id == id);
    });
  }

  void _addToDoItem(String todo) {
    setState(() {
      if (todo.isNotEmpty) {
        _selectedGroup!.myToDos!.add(ToDo(id: DateTime.now().millisecondsSinceEpoch.toString(), toDoText: todo));
      }
    });

    _toDoController.clear();
  }

  void _changeGroup(Group group) {
    setState(() {
      _selectedGroup = group;
      _foundToDo = _selectedGroup!.myToDos!;
    });
  }

  void _runFilter(String enteredKeyWord) {
    List<ToDo> results = [];
    if (enteredKeyWord.isEmpty) {
      results = _selectedGroup!.myToDos!;
    } else {
      results = _selectedGroup!.myToDos!.where((item) => item.toDoText!.toLowerCase().contains(enteredKeyWord.toLowerCase())).toList();
    }

    setState(() {
      _foundToDo = results;
    });
  }

  void _createNewGroup(String groupName) {
    if(groupName.isNotEmpty) {
      setState(() {
        final newGroup = Group(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: groupName,
          myToDos: []
        );
        groupsList.add(newGroup);
        _selectedGroup = newGroup;
        _foundToDo = _selectedGroup!.myToDos!;
      });
      _groupNameController.clear();
      Navigator.of(context).pop();
    }
  }

  void _deleteGroup(Group group) {
    setState(() {
      groupsList.remove(group);
      if (_selectedGroup == group && groupsList.isNotEmpty) {
        _selectedGroup = groupsList[0];
        _foundToDo = _selectedGroup!.myToDos!;
      } 
      else if (groupsList.isEmpty) {
        _selectedGroup = null;
        _foundToDo = [];
      }
    });
  }

  void _confirmDeleteGroupModal(Group group) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Group'),
          content: Text('Are you sure you want to delete the group "${group.name}"?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deleteGroup(group);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showCreateGroupModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create new group'),
          content: TextField(
            controller: _groupNameController,
            decoration: InputDecoration(hintText: 'Group Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {Navigator.of(context).pop();},
            ),
            TextButton(
              child: Text('Create'),
              onPressed: () {
                _createNewGroup(_groupNameController.text);
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Widget searchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        decoration: InputDecoration(
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

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: tdBGColor,
      elevation: 0,
    );
  }

  Drawer _sideBar() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
              decoration: BoxDecoration(color: Colors.grey),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24))
          ),
          for(Group group in groupsList)
            ListTile(
              leading: Icon(Icons.group),
              title: Text(group.name),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red,),
                onPressed: () {
                  _confirmDeleteGroupModal(group);
                },
              ),
              onTap: () {
                _changeGroup(group);
                Navigator.of(context).pop();
              },
            ),
          Divider(),
          ListTile(
            leading: Icon(Icons.add),
            title: Text('Create new group'),
            onTap: () {
              _showCreateGroupModal();
            },
          ),
        ],
      ),
    );
  }
}
