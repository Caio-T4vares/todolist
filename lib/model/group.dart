import '../model/todo.dart';

class Group {
  String id;
  String name;
  List<ToDo> myToDos;

  Group({required this.id, required this.name, required this.myToDos});
}
