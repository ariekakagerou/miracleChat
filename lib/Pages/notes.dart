import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Note {
  String content;
  Uint8List? imageBytes;

  Note({
    required this.content,
    this.imageBytes,
  });
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final List<Note> _notes = [];
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  void _addNote() {
    if (_contentController.text.isNotEmpty) {
      setState(() {
        _notes.add(Note(
          content: _contentController.text,
        ));
        _contentController.clear();
      });
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final Uint8List imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _notes.add(Note(
          content: _contentController.text,
          imageBytes: imageBytes,
        ));
        _contentController.clear();
      });
      Navigator.of(context).pop();
    }
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Catatan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Isi Catatan'),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: _pickImage,
                child: Text('Tambahkan Foto'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: _addNote,
              child: Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _notes.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(_notes[index].content),
                  subtitle: _notes[index].imageBytes != null
                      ? Image.memory(_notes[index].imageBytes!)
                      : null,
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _notes.removeAt(index);
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: _showAddNoteDialog,
            child: Text('Tambah Catatan'),
          ),
        ),
      ],
    );
  }
}
