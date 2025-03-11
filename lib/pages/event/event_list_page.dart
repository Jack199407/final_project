import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import 'event_form_page.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({Key? key}) : super(key: key);

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await DatabaseHelper.instance.queryAll('events');
    setState(() {
      _events = events;
    });
  }

  Future<void> _deleteEvent(int id) async {
    await DatabaseHelper.instance.delete('events', id);
    _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Events")),
      body: ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return ListTile(
            title: Text(event['name']),
            subtitle: Text("${event['date']} at ${event['time']}"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventFormPage(event: event),
                ),
              ).then((_) => _loadEvents());
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteEvent(event['id']),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EventFormPage()),
          ).then((_) => _loadEvents());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
