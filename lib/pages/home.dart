import 'package:flutter/material.dart';
import 'package:my_todo_list/constants/colors.dart';
import 'package:my_todo_list/model/todo.dart';
import 'package:my_todo_list/widgets/todo_item.dart';

class Home extends StatefulWidget
{
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final toDosList = ToDo.toDoList();
  List<ToDo> _foundToDo = [];
  final _toDoController = TextEditingController();

  @override
  void initState() {
    _foundToDo = toDosList;
    super.initState();
  }

  @override
  Widget build(BuildContext context)
  {
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
                        child: (const Text('All ToDos', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),)),
                      ),
                      
                      for(ToDo loopToDo in _foundToDo)
                        ToDoItem(
                          todo: loopToDo,
                          onToDoChanged: _handleToDoChange,
                          onDeleteItem: _handleDeleteItem,
                        )
                    ],
                  ),
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
                    margin: EdgeInsets.only(bottom: 20, right: 20, left: 20),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0,0.0),
                        blurRadius: 10.0,
                        spreadRadius: 0.0
                      )],
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: TextField(
                      controller: _toDoController,
                      decoration: InputDecoration(
                        hintText: 'Add new item',
                        border: InputBorder.none
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 20, right: 20),
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
                        borderRadius: BorderRadius.circular(6)
                      ) 
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleToDoChange(ToDo todo)
  {
    setState(() {
      todo.isDone = !todo.isDone;
    });
  }

  void _handleDeleteItem(String id)
  {
    setState(() {
      toDosList.removeWhere((item) => item.id == id);
    });
  }

  void _addToDoItem(String todo)
  {
    setState(() {
      if(todo.isNotEmpty)
      {
        toDosList.add(ToDo(id: DateTime.now().microsecondsSinceEpoch.toString(), toDoText: todo));
      }
    });

    _toDoController.clear();
  }

  void _runFilter(String enteredKeyWord)
  {
    List<ToDo> results = [];
    if(enteredKeyWord.isEmpty)
    {
      results = toDosList;
    }
    else
    {
      results = toDosList.where((item) => item.toDoText!.toLowerCase().contains(enteredKeyWord.toLowerCase())).toList();
    }

    setState(() {
      _foundToDo = results;
    });
  }

  Widget searchBar()
  {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20)
      ),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(Icons.search, color: tdBlack, size: 20,),
          prefixIconConstraints: BoxConstraints(maxHeight: 20, minWidth: 25),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: tdGrey)
        ),
        ),
    );
  }

  AppBar _buildAppBar() 
  {
    return AppBar(
      backgroundColor: tdBGColor,
      elevation: 0,
    );
  }

  Drawer _sideBar()
  {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.grey),
            child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24),)
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}