class ToDo {
  String id;
  String toDoText;
  bool isDone;
  String? description;
  DateTime? deadline;
  String groupId;
  // adicionar lista a que pertence (as listas podem ser string e guardadas em uma lista de string)
  // adicionar possivel data limite "DateTime?"
  // adicionar descrição
  ToDo(
      {required this.id,
      required this.toDoText,
      this.isDone = false,
      this.description,
      this.deadline,
      required this.groupId});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'toDoText': toDoText,
      'isDone': isDone,
      'description': description,
      'deadline': deadline?.toIso8601String(),
      'groupId': groupId,
    };
  }

  factory ToDo.fromJson(Map<String, dynamic> json) {
    return ToDo(
      id: json['id'],
      toDoText: json['toDoText'],
      isDone: json['isDone'],
      description: json['description'],
      groupId: json['groupId'],
      deadline:
          json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
    );
  }
}
