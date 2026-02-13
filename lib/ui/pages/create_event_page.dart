import 'package:event_app/app/configs/colors.dart';
import 'package:event_app/data/category_enum.dart';
import 'package:event_app/data/event_model.dart';
import 'package:event_app/data/organizer_model.dart';
import 'package:event_app/data/ticket_model.dart';
import 'package:event_app/services/api_service.dart';
import 'package:event_app/ui/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({Key? key}) : super(key: key);

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _capacityController = TextEditingController();

  EventCategory _selectedCategory = EventCategory.other;
  bool _isOnline = false;
  bool _isLoading = false;

  // Ticket information
  final List<Map<String, dynamic>> _tickets = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _addTicketType() {
    showDialog(
      context: context,
      builder: (context) => _TicketDialog(
        onAdd: (ticket) {
          setState(() {
            _tickets.add(ticket);
          });
        },
      ),
    );
  }

  void _createEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_tickets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ticket type')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create ticket models
      final ticketModels = _tickets.map((t) => TicketModel(
            id: 'ticket_${DateTime.now().millisecondsSinceEpoch}_${_tickets.indexOf(t)}',
            type: TicketTypeExtension.fromString(t['type']),
            price: t['price'],
            totalAvailable: t['quantity'],
            sold: 0,
          )).toList();

      // Create organizer (mock - should come from logged in user)
      final organizer = OrganizerModel(
        id: _apiService.currentUser?.id ?? 'org_temp',
        name: _apiService.currentUser?.name ?? 'Event Organizer',
        email: _apiService.currentUser?.email ?? 'organizer@email.com',
        phone: _apiService.currentUser?.phone ?? '+1-000-000-0000',
        profileImage: _apiService.currentUser?.profileImage,
        rating: 4.5,
        eventsHosted: 1,
      );

      // Create event model
      final event = EventModel(
        id: 'event_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text,
        description: _descriptionController.text,
        image: _imageUrlController.text.isEmpty
            ? 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800'
            : _imageUrlController.text,
        location: _locationController.text,
        date: _dateController.text,
        category: _selectedCategory,
        organizer: organizer,
        tickets: ticketModels,
        capacity: int.tryParse(_capacityController.text),
        startTime: _startTimeController.text.isEmpty ? null : _startTimeController.text,
        endTime: _endTimeController.text.isEmpty ? null : _endTimeController.text,
        isOnline: _isOnline,
        attendees: 0,
        isFeatured: false,
        createdAt: DateTime.now(),
      );

      // Create event via API
      final success = await _apiService.createEvent(event);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event created successfully!')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating event: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size(0, 0),
        child: CustomAppBar(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _titleController,
                        label: 'Event Title',
                        hint: 'Enter event title',
                        validator: (value) => value?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Describe your event',
                        maxLines: 4,
                        validator: (value) => value?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildCategorySelector(),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _imageUrlController,
                        label: 'Image URL',
                        hint: 'https://example.com/image.jpg',
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _dateController,
                              label: 'Date',
                              hint: '15 Jul',
                              validator: (value) => value?.isEmpty == true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _startTimeController,
                              label: 'Start Time',
                              hint: '14:00',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: _isOnline,
                            onChanged: (value) {
                              setState(() {
                                _isOnline = value ?? false;
                              });
                            },
                            activeColor: AppColors.primaryColor,
                          ),
                          const Text('Online Event'),
                        ],
                      ),
                      if (!_isOnline) ...[
                        _buildTextField(
                          controller: _locationController,
                          label: 'Location',
                          hint: 'Enter venue location',
                          validator: (value) => value?.isEmpty == true ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildTextField(
                        controller: _capacityController,
                        label: 'Capacity',
                        hint: 'Maximum attendees',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tickets',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _addTicketType,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Ticket'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._tickets.map((ticket) => _buildTicketCard(ticket)),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.whiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: AppColors.whiteColor)
                              : const Text(
                                  'Create Event',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.whiteColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Create Event',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.whiteColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<EventCategory>(
            value: _selectedCategory,
            isExpanded: true,
            underline: const SizedBox(),
            items: EventCategory.values.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text('${category.icon} ${category.displayName}'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedCategory = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket['type'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${ticket['quantity']} tickets',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.greyTextColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            ticket['price'] == 0 ? 'Free' : '\$${ticket['price']}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                _tickets.remove(ticket);
              });
            },
          ),
        ],
      ),
    );
  }
}

class _TicketDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;

  const _TicketDialog({required this.onAdd});

  @override
  State<_TicketDialog> createState() => _TicketDialogState();
}

class _TicketDialogState extends State<_TicketDialog> {
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  String _selectedType = 'Regular';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Ticket Type'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: const InputDecoration(labelText: 'Type'),
            items: ['Free', 'Regular', 'VIP', 'Early Bird']
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
                if (_selectedType == 'Free') {
                  _priceController.text = '0';
                }
              });
            },
          ),
          TextField(
            controller: _priceController,
            decoration: const InputDecoration(labelText: 'Price'),
            keyboardType: TextInputType.number,
            enabled: _selectedType != 'Free',
          ),
          TextField(
            controller: _quantityController,
            decoration: const InputDecoration(labelText: 'Quantity'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onAdd({
              'type': _selectedType,
              'price': double.tryParse(_priceController.text) ?? 0,
              'quantity': int.tryParse(_quantityController.text) ?? 0,
            });
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

