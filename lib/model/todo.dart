class ToDo
{
  String? id;
  String? toDoText;
  bool isDone;

  ToDo({
    required this.id,
    required this.toDoText,
    this.isDone = false
  });

  static List<ToDo> toDoList()
  {
    return [
      ToDo(id: '01', toDoText: 'Morning Exercise', isDone: true),
      ToDo(id: '02', toDoText: 'Buy groceries', isDone: true),
      ToDo(id: '03', toDoText: 'Check mails'),
      ToDo(id: '04', toDoText: 'Team meeting'),
      ToDo(id: '05', toDoText: 'Work on mobile app'),
    ];
  }
}