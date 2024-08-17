class ToDo {
  String id;
  String toDoText;
  bool isDone;
  String? description;
  DateTime? deadline;
  // adicionar lista a que pertence (as listas podem ser string e guardadas em uma lista de string)
  // adicionar possivel data limite "DateTime?"
  // adicionar descrição
  ToDo({required this.id, required this.toDoText, this.isDone = false, this.description, this.deadline});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'toDoText': toDoText,
      'isDone': isDone,
      'description': description,
      'deadline': deadline?.toIso8601String(),
    };
  }

  factory ToDo.fromJson(Map<String, dynamic> json) {
    return ToDo(
      id: json['id'],
      toDoText: json['toDoText'],
      isDone: json['isDone'],
      description: json['description'],
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
    );
  }
}
