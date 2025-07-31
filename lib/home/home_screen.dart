import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:testpro/resources/theme.dart';

class TodoScreen extends StatefulWidget {
  static String route = "/todoScreen";
  @override
  TodoScreenState createState() => TodoScreenState();
}

class TodoScreenState extends State<TodoScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String filter = 'All';
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  DateTime? selectedDate;

  Future<void> addTask() async {
    if (titleController.text.isEmpty || selectedDate == null) return;

    await firestore.collection('tasks').add({
      'title': titleController.text,
      'description': descController.text,
      'dueDate': selectedDate,
      'isCompleted': false,
      'userId': auth.currentUser?.uid,
    });

    Navigator.pop(context);
    clearFields();
  }

  Future<void> updateTask(String id, bool isCompleted) async {
    await firestore
        .collection('tasks')
        .doc(id)
        .update({'isCompleted': isCompleted});
  }

  Future<void> deleteTask(String id) async {
    await firestore.collection('tasks').doc(id).delete();
  }

  void clearFields() {
    titleController.clear();
    descController.clear();
    selectedDate = null;
  }

  void openTaskDialog(
      {String? taskId, String? title, String? desc, DateTime? dueDate}) {
    titleController.text = title ?? '';
    descController.text = desc ?? '';
    selectedDate = dueDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(taskId == null ? "Add Task" : "Update Task"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: "Title")),
              TextField(
                  controller: descController,
                  decoration: InputDecoration(labelText: "Description")),
              SizedBox(height: 10),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(AppTheme.primaryColor),
                ),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => selectedDate = date);
                },
                child: Text(
                  selectedDate == null
                      ? "Select Due Date"
                      : "Due: ${DateFormat.yMMMd().format(selectedDate!)}",
                  style: TextStyle(color: AppTheme.whiteColor),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(AppTheme.primaryColor),
            ),
            onPressed: () async {
              if (taskId == null) {
                await addTask();
              } else {
                await firestore.collection('tasks').doc(taskId).update({
                  'title': titleController.text,
                  'description': descController.text,
                  'dueDate': selectedDate,
                });
                Navigator.pop(context);
                clearFields();
              }
            },
            child: Text(
              taskId == null ? "Add" : "Update",
              style: TextStyle(color: AppTheme.whiteColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("To-Do List", style: TextStyle(color: AppTheme.whiteColor)),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          PopupMenuButton<String>(
            color: AppTheme.whiteColor,
            iconColor: AppTheme.whiteColor,
            onSelected: (value) => setState(() => filter = value),
            itemBuilder: (context) => [
              PopupMenuItem(value: "All", child: Text("All")),
              PopupMenuItem(value: "Completed", child: Text("Completed")),
              PopupMenuItem(value: "Pending", child: Text("Pending")),
            ],
          )
        ],
      ),
      body: user == null
          ? Center(child: Text("User not logged in"))
          : StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection('tasks')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('dueDate')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No tasks found"));
                }

                final tasks = snapshot.data!.docs.where((task) {
                  final data = task.data() as Map<String, dynamic>;
                  if (filter == 'Completed') return data['isCompleted'] == true;
                  if (filter == 'Pending') return data['isCompleted'] == false;
                  return true;
                }).toList();

                if (tasks.isEmpty) {
                  return Center(child: Text("No tasks match the filter"));
                }

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final data = task.data() as Map<String, dynamic>;

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: Checkbox(
                          value: data['isCompleted'],
                          onChanged: (val) => updateTask(task.id, val!),
                          activeColor: AppTheme.primaryColor,
                        ),
                        title: Text(
                          data['title'],
                          style: TextStyle(
                            decoration: data['isCompleted']
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(
                          "${data['description']}\nDue: ${DateFormat.yMMMd().format((data['dueDate'] as Timestamp).toDate())}",
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: AppTheme.blueColor),
                              onPressed: () => openTaskDialog(
                                taskId: task.id,
                                title: data['title'],
                                desc: data['description'],
                                dueDate:
                                    (data['dueDate'] as Timestamp).toDate(),
                              ),
                            ),
                            IconButton(
                              icon:
                                  Icon(Icons.delete, color: AppTheme.redColor),
                              onPressed: () => deleteTask(task.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openTaskDialog(),
        backgroundColor: AppTheme.primaryColor,
        child: Icon(Icons.add, color: AppTheme.whiteColor),
      ),
    );
  }
}
