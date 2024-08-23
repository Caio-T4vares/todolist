import '../model/todo.dart';

class Group {
  String id;
  String name;

  Group({required this.id, required this.name});

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(id: json['id'], name: json['name']);
  }
}
