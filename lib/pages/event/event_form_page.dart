import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../database/database_helper.dart';
import '../../localization/app_localizations.dart';
import '../../widgets/app_ui.dart';

/// A page to create or edit an event.
/// If [event] is provided, the form is in edit mode.
class EventFormPage extends StatefulWidget {
  final Map<String, dynamic>? event;

  /// Constructor for [EventFormPage].
  /// If [event] is provided, the form is pre-filled for editing.
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

  /// Whether the form is in edit mode (based on presence of [widget.event]).
  bool get _isEditMode => widget.event != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.event?['name'] ?? '');
    _dateController = TextEditingController(text: widget.event?['date'] ?? '');
    _timeController = TextEditingController(text: widget.event?['time'] ?? '');
    _locationController = TextEditingController(text: widget.event?['location'] ?? '');
    _descriptionController = TextEditingController(text: widget.event?['description'] ?? '');

    // Prompt user to copy the last saved event if in create mode.
    if (!_isEditMode) {
      _askToCopyLastEvent();
    }
  }

  /// Shows a dialog asking if the user wants to copy the last saved event.
  Future<void> _askToCopyLastEvent() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('lastEvent_name') ?? '';
    final savedDate = prefs.getString('lastEvent_date') ?? '';
    final savedTime = prefs.getString('lastEvent_time') ?? '';
    final savedLocation = prefs.getString('lastEvent_location') ?? '';
    final savedDescription = prefs.getString('lastEvent_description') ?? '';

    if (savedName.isEmpty && savedDate.isEmpty) return;

    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.translate('copyPreviousEvent')),
        content: Text(loc.translate('copyPreviousEventQuestion')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.translate('no')),
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
            child: Text(loc.translate('yes')),
          ),
        ],
      ),
    );
  }

  /// Saves the event data to shared preferences.
  Future<void> _saveEventToPrefs(Map<String, dynamic> eventData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastEvent_name', eventData['name'] ?? '');
    await prefs.setString('lastEvent_date', eventData['date'] ?? '');
    await prefs.setString('lastEvent_time', eventData['time'] ?? '');
    await prefs.setString('lastEvent_location', eventData['location'] ?? '');
    await prefs.setString('lastEvent_description', eventData['description'] ?? '');
  }

  /// Handles saving the form data to the database.
  Future<void> _onSubmit() async {
    final loc = AppLocalizations.of(context);

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
          SnackBar(content: Text(loc.translate('eventUpdated'))),
        );
      } else {
        final id = await DatabaseHelper.instance.insert('events', eventData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.translate('eventCreated')} (ID=$id)')),
        );
        await _saveEventToPrefs({...eventData, 'id': id});
      }

      Navigator.pop(context, true);
    }
  }

  /// Handles deleting the current event from the database.
  Future<void> _onDelete() async {
    if (!_isEditMode) return;
    final loc = AppLocalizations.of(context);
    final eventId = widget.event!['id'] as int;
    await DatabaseHelper.instance.delete('events', eventId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.translate('eventDeleted'))),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppUI.buildAppBar(
        title: _isEditMode
            ? loc.translate('editEvent')
            : loc.translate('newEvent'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: loc.translate('eventName')),
                validator: (value) =>
                    value == null || value.isEmpty ? loc.translate('nameRequired') : null,
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: loc.translate('dateFormat')),
                validator: (value) =>
                    value == null || value.isEmpty ? loc.translate('dateRequired') : null,
              ),
              TextFormField(
                controller: _timeController,
                decoration: InputDecoration(labelText: loc.translate('timeFormat')),
                validator: (value) =>
                    value == null || value.isEmpty ? loc.translate('timeRequired') : null,
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: loc.translate('location')),
                validator: (value) =>
                    value == null || value.isEmpty ? loc.translate('locationRequired') : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: loc.translate('description')),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? loc.translate('descriptionRequired') : null,
              ),
              const SizedBox(height: 20),
              AppUI.buildButton(
                label: _isEditMode ? loc.translate('updateEvent') : loc.translate('createEvent'),
                onPressed: _onSubmit,
              ),
              if (_isEditMode)
                AppUI.buildOutlinedButton(
                  label: loc.translate('deleteEvent'),
                  onPressed: _onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}







