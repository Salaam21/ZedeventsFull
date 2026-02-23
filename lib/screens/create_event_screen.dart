import 'package:flutter/material.dart';
import 'package:event_app/data/category_enum.dart';
import 'package:event_app/data/event_model.dart';
import 'package:event_app/data/organizer_model.dart';
import 'package:event_app/data/ticket_model.dart';
import 'package:event_app/services/api_service.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _organizerController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  EventCategory _selectedCategory = EventCategory.other;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _organizerController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submitEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final event = EventModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      image: 'https://picsum.photos/300/200?event',
      date: 'Today',
      location: _locationController.text.trim(),
      description: 'Created from app',
      category: _selectedCategory,
      organizer: OrganizerModel(
        id: 'org_${DateTime.now().millisecondsSinceEpoch}',
        name: _organizerController.text.trim(),
        email: 'organizer@zedevents.com',
        phone: 'N/A',
      ),
      tickets: [
        TicketModel(
          id: 'ticket_${DateTime.now().millisecondsSinceEpoch}',
          type: TicketType.regular,
          price: double.tryParse(_priceController.text.trim()) ?? 0,
          totalAvailable: 100,
          sold: 0,
          currency: 'ZMW',
        ),
      ],
      tags: const ['user-created'],
      isFeatured: false,
      createdAt: DateTime.now(),
    );

    await _apiService.createEvent(event);

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context, event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Event Title'),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Title is required' : null,
                ),
                TextFormField(
                  controller: _organizerController,
                  decoration: const InputDecoration(labelText: 'Organizer'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Organizer is required'
                      : null,
                ),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Location is required' : null,
                ),
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Price (ZMW)'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Price is required';
                    }
                    if (double.tryParse(value.trim()) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<EventCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: EventCategory.values
                      .map(
                        (category) => DropdownMenuItem<EventCategory>(
                          value: category,
                          child: Text(category.displayName),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isSaving ? null : _submitEvent,
                  child: Text(_isSaving ? 'Saving...' : 'Create Event'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}