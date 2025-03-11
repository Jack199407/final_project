import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class EventFormPage extends StatefulWidget {
  final Map<String, dynamic>? event;
  const EventFormPage({Key? key, this.event}) : super(key: key);

  @override
  _EventFormPageState createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _nameController.text = widget.event!['name'];
      _dateController.text = widget.event!['date'];
      _timeController.text = widget.event!['time'];
      _locationController.text = widget.event!['location'];
      _descriptionController.text = widget.event!['description'];
    }
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      final event = {
        'name': _nameController.text,
        'date': _dateController.text,
        'time': _timeController.text,
        'location': _locationController.text,
        'description': _descriptionController.text,
      };

      if (widget.event == null) {
        await DatabaseHelper.instance.insert('events', event);
      } else {
        await DatabaseHelper.instance.update('events', event, widget.event!['id']);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Event Form")),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: "Event Name")),
            ElevatedButton(onPressed: _saveEvent, child: const Text("Save"))
          ],
        ),
      ),
    );
  }
}
