import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../database/database_helper.dart';
import 'event_form_page.dart';
import '../../localization/app_localizations.dart'; // localization

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

  Future<void> _refreshEvents() async {
    final data = await DatabaseHelper.instance.queryAll('events');
    setState(() {
      _eventList = data;
    });
  }

  void _showHelpDialog() {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.translate('howToUse')),
        content: Text(
          '${loc.translate('howToUseInstruction1')}\n'
          '${loc.translate('howToUseInstruction2')}\n'
          '${loc.translate('howToUseInstruction3')}\n'
          '${loc.translate('howToUseInstruction4')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.translate('ok')),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEvent(int id, String name) async {
    final loc = AppLocalizations.of(context);
    await DatabaseHelper.instance.delete('events', id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${loc.translate('eventDeletedMessage').replaceAll('{name}', name)}')),
    );
    _refreshEvents();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('eventPlanner')),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: _eventList.isEmpty
          ? Center(child: Text(loc.translate('noEventsMessage')))
          : ListView.builder(
              itemCount: _eventList.length,
              itemBuilder: (context, index) {
                final event = _eventList[index];
                return ListTile(
                  title: Text(event['name']),
                  subtitle: Text('${event['date']} ${loc.translate('at')} ${event['time']}'),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventFormPage(event: event),
                      ),
                    );
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
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EventFormPage()),
          );
          if (result == true) {
            _refreshEvents();
          }
        },
      ),
    );
  }
}



