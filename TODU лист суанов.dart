import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      theme: ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          elevation: 0, // 
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), 
            ),
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false, 
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<TodoItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? itemsString = prefs.getString('todo_items');
    if (itemsString != null) {
      final List<dynamic> itemsJson = json.decode(itemsString);
      setState(() {
        _items.addAll(itemsJson.map((json) => TodoItem.fromJson(json)).toList());
      });
    }
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String itemsString = json.encode(_items);
    await prefs.setString('todo_items', itemsString);
  }

  void _addItem(String task) {
    setState(() {
      _items.add(TodoItem(task: task));
      _saveItems();
    });
  }

  void _toggleItemComplete(TodoItem item) {
    setState(() {
      item.isComplete = !item.isComplete;
      _saveItems();
    });
  }

  void _removeItem(TodoItem item) {
    setState(() {
      _items.remove(item);
      _saveItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeItems = _items.where((item) => !item.isComplete).toList();
    final completedItems = _items.where((item) => item.isComplete).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('To-Do List'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Активные задачи'),
              Tab(text: 'Выполненные задачи'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTaskList(activeItems),
            _buildTaskList(completedItems),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddItemDialog(context),
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildTaskList(List<TodoItem> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), 
          ),
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          elevation: 0, 
          child: ListTile(
            contentPadding: EdgeInsets.zero, 
            leading: Checkbox(
              value: item.isComplete,
              onChanged: (value) => _toggleItemComplete(item),
            ),
            title: Text(
              item.task,
              style: TextStyle(
                decoration: item.isComplete ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _removeItem(item),
            ),
          ),
        );
      },
    );
  }

  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),           ),
          elevation: 0, 
          child: AddItemDialog(onAdd: _addItem),
        );
      },
    );
  }
}

class TodoItem {
  final String task;
  bool isComplete;

  TodoItem({required this.task, this.isComplete = false});

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      task: json['task'],
      isComplete: json['isComplete'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task': task,
      'isComplete': isComplete,
    };
  }
}

class AddItemDialog extends StatefulWidget {
  final Function(String) onAdd;

  AddItemDialog({required this.onAdd});

  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    final task = _controller.text;
    if (task.isNotEmpty) {
      widget.onAdd(task);
      _controller.clear();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Добавить задачу',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Введите задачу',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30), 
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submit,
            child: Text('Добавить'),
          ),
        ],
      ),
    );
  }
}
