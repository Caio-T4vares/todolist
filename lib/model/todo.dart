class ToDo {
  String id;
  String toDoText;
  bool isDone;
  String? description;
  DateTime? deadline;
  // adicionar lista a que pertence (as listas podem ser string e guardadas em uma lista de string)
  // adicionar possivel data limite "DateTime?"
  // adicionar descrição
  ToDo({required this.id, required this.toDoText, this.isDone = false});
}
