import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Uygulaması',
      home: TodoListScreen(),
      debugShowCheckedModeBanner: false, // Debug logosunu kaldırır
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final dbHelper = DatabaseHelper();
  final TextEditingController _controller = TextEditingController(); // Text alanını kontrol etmek için kullanılır
  List<Map<String, dynamic>> _todos = [];

  @override
  void initState() {
    super.initState();
    _queryAll();
  }

  Future<void> _queryAll() async {
    final allRows = await dbHelper.queryAllRows();
    setState(() {
      _todos = allRows;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Todo Listesi')), // Başlığı ortalar
      ),
      body: _buildTodoList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTodoDialog(context); // Yeni görev ekleme diyalogunu gösterir
        },
        tooltip: 'Todo Ekle',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodoList() {
    return _todos.isEmpty
        ? Center(
            child: Text(
              'Hiçbir görev yok.',
              style: TextStyle(fontSize: 18.0),
            ),
          )
        : ListView.builder(
            itemCount: _todos.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  _todos[index]['title'],
                  style: TextStyle(fontSize: 16.0),
                ),
                // Açıklamayı da gösterebilirsiniz, eğer varsa
                subtitle: Text(_todos[index]['description'] ?? ''),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteTodoDialog(context, _todos[index]['id']);
                  },
                ),
              );
            },
          );
  }

  void _showAddTodoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Yeni Görev Ekle'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Yapılacak iş'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                _addTodoItem(_controller.text);
                _controller.clear();
                Navigator.of(context).pop();
              },
              child: Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  void _addTodoItem(String title) async {
    if (title.isNotEmpty) {
      Map<String, dynamic> row = {
        'title': title,
        'description': '', // İsterseniz burada açıklama ekleyebilirsiniz
      };
      await dbHelper.insert(row);
      _queryAll(); // Liste güncellemesi için veritabanını tekrar sorgula
    }
  }

  void _showDeleteTodoDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Görevi Sil'),
          content: Text('Bu görevi silmek istediğinize emin misiniz?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                _deleteTodoItem(id);
                Navigator.of(context).pop();
              },
              child: Text('Sil'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTodoItem(int id) async {
    await dbHelper.delete(id);
    _queryAll(); // Liste güncellemesi için veritabanını tekrar sorgula
  }
}
