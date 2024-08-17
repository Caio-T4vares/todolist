import '../model/todo.dart';

class Group {
  String id;
  String name;
  List<ToDo> myToDos;

  Group({required this.id, required this.name, required this.myToDos});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'myToDos': myToDos.map((todo) => todo.toJson()).toList()
    };
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      myToDos: (json['myToDos'] as List).map((item) => ToDo.fromJson(item)).toList(),
    );
  }
}
