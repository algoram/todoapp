import 'package:flutter/material.dart';

import 'database.dart';
import 'task.dart';

class TaskList extends StatefulWidget {
  const TaskList({Key? key}) : super(key: key);

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  List<Task> taskList = [];

  @override
  void initState() {
    super.initState();

    _updateTaskList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do'),
        actions: [
          IconButton(
            onPressed: () => showLicensePage(
              context: context,
              applicationVersion: '1.0.0',
            ),
            icon: Icon(Icons.info),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_task),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => _buildAlertDialog(),
          );
        },
      ),
      body: _buildTaskList(),
    );
  }

  _buildTaskList() {
    return ListView.separated(
      itemBuilder: (context, index) {
        final name = taskList[index].name;
        final description = taskList[index].description;

        return ListTile(
          title: Text(name),
          subtitle: description != null ? Text(description) : null,
          onLongPress: () {
            showDialog(
              context: context,
              builder: (context) => _buildDeleteDialog(taskList[index].id),
            );
          },
        );
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
      itemCount: taskList.length,
    );
  }

  _updateTaskList() async {
    final result = await getTasks();

    print("Task ricevuti: ${result.length}");
    result.forEach((element) {
      print(
          element.name + " " + (element.description ?? "Nessuna descrizione"));
    });

    setState(() {
      taskList = result;
    });
  }

  _buildDeleteDialog(int id) {
    return AlertDialog(
      title: Text("Do you really wanna delete this task?"),
      actions: [
        ElevatedButton(
          onPressed: () {
            deleteTask(id);

            Navigator.of(context).pop();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Task deleted"),
              ),
            );

            _updateTaskList();
          },
          child: Text("Yes"),
        ),
      ],
    );
  }

  _buildAlertDialog() {
    print("Costruisco l'alert dialog");

    final formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    return AlertDialog(
      title: Text("Create a new task"),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Task name cannot be empty';
                }

                return null;
              },
            ),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          child: Text("Create"),
          onPressed: () {
            if (formKey.currentState!.validate()) {
              insertTask(nameController.text, descriptionController.text);

              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Inserted a new task"),
                ),
              );

              _updateTaskList();
            }
          },
        ),
      ],
    );
  }
}
