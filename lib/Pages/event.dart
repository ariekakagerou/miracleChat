import 'package:flutter/material.dart';

class Event {
  String title;
  DateTime date;

  Event({required this.title, required this.date});
}

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final List<Event> _events = [];
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedDate;

  void _addEvent() {
    if (_titleController.text.isNotEmpty && _selectedDate != null) {
      setState(() {
        _events.add(Event(
          title: _titleController.text,
          date: _selectedDate!,
        ));
        _titleController.clear();
        _selectedDate = null;
      });
      Navigator.of(context).pop();
      _showSparkleEffect(); // Trigger the sparkle effect
    }
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Acara 🎤'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Judul Acara Idol',
                  icon: Icon(Icons.music_note, color: Colors.pinkAccent),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
                child: Text(
                  _selectedDate == null
                      ? 'Pilih Tanggal'
                      : 'Tanggal: ${_selectedDate!.toLocal()}'.split(' ')[0],
                ),
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
              onPressed: _addEvent,
              child: Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  void _showSparkleEffect() {
    // This function will be used to trigger sparkle effect animation.
    // For simplicity, we can just show a small notification or animation.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✨ Acara berhasil ditambahkan! ✨'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _events.length,
            itemBuilder: (context, index) {
              final event = _events[index];
              final daysLeft = event.date.difference(DateTime.now()).inDays;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Icon(
                    Icons.star,
                    color: Colors.pinkAccent,
                    size: 30,
                  ),
                  title: Text(event.title, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Tanggal: ${event.date.toLocal().toString().split(' ')[0]}\n'
                      'Countdown: ${daysLeft >= 0 ? '$daysLeft hari lagi' : 'Sudah Lewat'}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      setState(() {
                        _events.removeAt(index);
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: _showAddEventDialog,
            child: Text(
              'Tambah Acara  🎉',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
