import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // If simulating encrypted storage
import '../../../database/database_helper.dart';
import 'event_form_page.dart';

/// Displays a list of events from the 'events' table.
/// Allows adding, viewing, editing, and deleting events.
class EventListPage extends StatefulWidget {
  const EventListPage({Key? key}) : super(key: key);

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Map<String, dynamic>> _eventList = [];

  @override
  void initState() {
    super.initState();
    _refreshEvents();
  }

  /// Queries the 'events' table and updates [_eventList] with the result.
  Future<void> _refreshEvents() async {
    final data = await DatabaseHelper.instance.queryAll('events');
    setState(() {
      _eventList = data;
    });
  }

  /// Displays an AlertDialog with instructions on how to use the event list page.
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('How to use'),
        content: const Text(
          '1. Click the "+" button to add a new event.\n'
          '2. Tap an event to edit its details.\n'
          '3. Tap the delete icon to remove an event.\n'
          '4. Enjoy!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Deletes an event by its [id] and refreshes the list.
  /// Shows a Snackbar notification upon successful deletion.
  Future<void> _deleteEvent(int id, String name) async {
    await DatabaseHelper.instance.delete('events', id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted "$name" successfully!')),
    );
    _refreshEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: _eventList.isEmpty
          ? const Center(child: Text('No events yet. Tap + to add one!'))
          : ListView.builder(
              itemCount: _eventList.length,
              itemBuilder: (context, index) {
                final event = _eventList[index];
                return ListTile(
                  title: Text(event['name']),
                  subtitle: Text('${event['date']} at ${event['time']}'),
                  onTap: () async {
                    // Navigate to the form page to edit the event.
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventFormPage(event: event),
                      ),
                    );
                    // If the form page returns true, refresh the list.
                    if (result == true) {
                      _refreshEvents();
                    }
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteEvent(event['id'], event['name']),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // Navigate to the form page to create a new event.
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EventFormPage()),
          );
          // If the form page returns true, refresh the list.
          if (result == true) {
            _refreshEvents();
          }
        },
      ),
    );
  }
}
