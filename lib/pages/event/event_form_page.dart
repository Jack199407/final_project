import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../database/database_helper.dart';

/// A page for creating or editing an event.
/// 
/// If [event] is null, the page operates in "create" mode;
/// otherwise, it operates in "edit" mode with an existing event.
class EventFormPage extends StatefulWidget {
  final Map<String, dynamic>? event;

  const EventFormPage({Key? key, this.event}) : super(key: key);

  @override
  _EventFormPageState createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;

  /// Returns true if the page is in edit mode.
  bool get _isEditMode => widget.event != null;

  @override
  void initState() {
    super.initState();
    // Initialize form fields with existing event data if available.
    _nameController = TextEditingController(text: widget.event?['name'] ?? '');
    _dateController = TextEditingController(text: widget.event?['date'] ?? '');
    _timeController = TextEditingController(text: widget.event?['time'] ?? '');
    _locationController = TextEditingController(text: widget.event?['location'] ?? '');
    _descriptionController =
        TextEditingController(text: widget.event?['description'] ?? '');

    // If creating a new event, ask whether to copy the previous event's details.
    if (!_isEditMode) {
      _askToCopyLastEvent();
    }
  }

  /// Prompts the user to copy the details from the last saved event in SharedPreferences.
  Future<void> _askToCopyLastEvent() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('lastEvent_name') ?? '';
    final savedDate = prefs.getString('lastEvent_date') ?? '';
    final savedTime = prefs.getString('lastEvent_time') ?? '';
    final savedLocation = prefs.getString('lastEvent_location') ?? '';
    final savedDescription = prefs.getString('lastEvent_description') ?? '';

    // If no saved data exists, do not show the dialog.
    if (savedName.isEmpty && savedDate.isEmpty) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Copy previous event?'),
        content: const Text('Do you want to copy details from the last event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _nameController.text = savedName;
                _dateController.text = savedDate;
                _timeController.text = savedTime;
                _locationController.text = savedLocation;
                _descriptionController.text = savedDescription;
              });
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  /// Saves the current event details to SharedPreferences for future use.
  Future<void> _saveEventToPrefs(Map<String, dynamic> eventData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastEvent_name', eventData['name'] ?? '');
    await prefs.setString('lastEvent_date', eventData['date'] ?? '');
    await prefs.setString('lastEvent_time', eventData['time'] ?? '');
    await prefs.setString('lastEvent_location', eventData['location'] ?? '');
    await prefs.setString('lastEvent_description', eventData['description'] ?? '');
  }

  /// Validates the form and submits the event data to the database.
  /// 
  /// In edit mode, updates the existing event; in create mode, inserts a new event.
  Future<void> _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      final eventData = {
        'name': _nameController.text,
        'date': _dateController.text,
        'time': _timeController.text,
        'location': _locationController.text,
        'description': _descriptionController.text,
      };

      if (_isEditMode) {
        final eventId = widget.event!['id'] as int;
        await DatabaseHelper.instance.update('events', eventData, eventId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event updated successfully!')),
        );
      } else {
        final id = await DatabaseHelper.instance.insert('events', eventData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event created (ID=$id) successfully!')),
        );
        await _saveEventToPrefs({...eventData, 'id': id});
      }

      // Return to the previous page and indicate that a change occurred.
      Navigator.pop(context, true);
    }
  }

  /// Deletes the current event from the database (available only in edit mode).
  Future<void> _onDelete() async {
    if (!_isEditMode) return;
    final eventId = widget.event!['id'] as int;
    await DatabaseHelper.instance.delete('events', eventId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event deleted successfully!')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Event' : 'New Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Event Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Name is required' : null,
              ),
              // Date
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Date is required' : null,
              ),
              // Time
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Time (HH:MM)'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Time is required' : null,
              ),
              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Location is required' : null,
              ),
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 20),
              // Submit button (Create or Update)
              ElevatedButton(
                onPressed: _onSubmit,
                child: Text(_isEditMode ? 'Update Event' : 'Create Event'),
              ),
              // Delete button (only in edit mode)
              if (_isEditMode)
                OutlinedButton(
                  onPressed: _onDelete,
                  child: const Text('Delete Event'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}



