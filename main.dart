import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notes App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: NotesScreen(),
    );
  }
}

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> notes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes')),
      body: notes.isEmpty
          ? Center(child: Text('No notes available'))
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    notes[index]['title'],
                    style: TextStyle(
                      fontSize: notes[index]['fontSize'],
                      fontWeight: notes[index]['fontStyle'] == 'bold'
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontStyle: notes[index]['fontStyle'] == 'italic'
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                  subtitle: Text(
                    notes[index]['content'].length > 30
                        ? notes[index]['content'].substring(0, 30) + "..."
                        : notes[index]['content'],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateNoteScreen(
                          note: notes[index],
                          onSave: (updatedNote) {
                            setState(() {
                              int i = notes.indexOf(notes[index]);
                              notes[i] = updatedNote;
                            });
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateNoteScreen(
                onSave: (newNote) {
                  setState(() {
                    notes.add(newNote);
                  });
                },
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class CreateNoteScreen extends StatefulWidget {
  final Map<String, dynamic>? note;
  final Function(Map<String, dynamic>) onSave;

  CreateNoteScreen({this.note, required this.onSave});

  @override
  _CreateNoteScreenState createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  double fontSize = 14.0;
  String fontStyle = 'normal';
  DateTime? deadline;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      titleController.text = widget.note!['title'];
      contentController.text = widget.note!['content'];
      fontSize = widget.note!['fontSize'];
      fontStyle = widget.note!['fontStyle'];
      deadline = widget.note!['deadline'];
    }
  }

  void saveNote() {
    if (titleController.text.isEmpty || contentController.text.isEmpty) return;

    widget.onSave({
      'title': titleController.text,
      'content': contentController.text,
      'fontSize': fontSize,
      'fontStyle': fontStyle,
      'deadline': deadline,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Create Note' : 'Edit Note'),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: saveNote),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: 5,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight:
                    fontStyle == 'bold' ? FontWeight.bold : FontWeight.normal,
                fontStyle:
                    fontStyle == 'italic' ? FontStyle.italic : FontStyle.normal,
              ),
            ),
            Row(
              children: [
                Text('Font Size: ${fontSize.toStringAsFixed(1)}'),
                Slider(
                  value: fontSize,
                  min: 10,
                  max: 30,
                  onChanged: (value) {
                    setState(() => fontSize = value);
                  },
                ),
              ],
            ),
            Row(
              children: [
                Text('Font Style: '),
                DropdownButton<String>(
                  value: fontStyle,
                  items: ['normal', 'bold', 'italic']
                      .map((style) =>
                          DropdownMenuItem(child: Text(style), value: style))
                      .toList(),
                  onChanged: (value) {
                    setState(() => fontStyle = value!);
                  },
                ),
              ],
            ),
            Row(
              children: [
                Text('Deadline: ${deadline != null ? DateFormat('yMMMd').format(deadline!) : "Not set"}'),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      setState(() => deadline = picked);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
