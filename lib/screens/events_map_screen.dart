import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:event_app/data/event_model.dart';
import 'package:event_app/services/api_service.dart';
import 'package:event_app/utils/calendar_helper.dart';

/// Snapchat-style map: events appear as pins on the physical map.
/// Tap a pin to see event card with image, details, directions, and add to calendar.
class EventsMapScreen extends StatefulWidget {
  const EventsMapScreen({super.key});

  @override
  State<EventsMapScreen> createState() => _EventsMapScreenState();
}

class _EventsMapScreenState extends State<EventsMapScreen> {
  final ApiService _api = ApiService();
  List<EventModel> _events = [];
  EventModel? _selectedEvent;
  bool _loading = true;
  static const LatLng _zambiaCenter = LatLng(-13.1339, 27.8493);

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final list = await _api.getAllEvents();
    if (!mounted) return;
    setState(() {
      _events = list.where((e) => e.latitude != null && e.longitude != null).toList();
      _loading = false;
    });
  }

  Set<Marker> _buildMarkers() {
    return {
      for (final e in _events)
        Marker(
          markerId: MarkerId(e.id),
          position: LatLng(e.latitude!, e.longitude!),
          infoWindow: InfoWindow(title: e.title, snippet: e.location),
          onTap: () => setState(() => _selectedEvent = e),
        ),
    };
  }

  Future<void> _openDirections(EventModel event) async {
    if (event.latitude == null || event.longitude == null) return;
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${event.latitude},${event.longitude}&travelmode=driving',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events on the map'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF9C27B0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SizedBox.expand(
              child: Stack(
                children: [
                  Container(
                    color: Colors.grey.shade300,
                    child: GoogleMap(
                      initialCameraPosition: const CameraPosition(target: _zambiaCenter, zoom: 6),
                      markers: _buildMarkers(),
                      myLocationEnabled: true,
                      mapType: MapType.normal,
                      onTap: (_) => setState(() => _selectedEvent = null),
                      onMapCreated: (_) => setState(() {}),
                    ),
                  ),
                  Positioned(
                  top: 8,
                  left: 12,
                  right: 12,
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text(
                        'Tap a pin to see what\'s on',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                      ),
                    ),
                  ),
                ),
                if (_selectedEvent != null) _buildEventCard(_selectedEvent!),
                ],
              ),
            ),
    );
  }

  /// Snapchat-style card: event thumbnail + title + quick actions.
  Widget _buildEventCard(EventModel e) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 16,
      child: Material(
        elevation: 12,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showEventDetail(e),
          borderRadius: BorderRadius.circular(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: Theme.of(context).cardColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16)),
                        child: Image.network(
                          e.image,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.event, size: 40),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                e.location,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                e.date,
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _openDirections(e),
                            icon: const Icon(Icons.directions, size: 18),
                            label: const Text('Directions'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _showEventDetail(e),
                            icon: const Icon(Icons.info_outline, size: 18),
                            label: const Text('View event'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEventDetail(EventModel e) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  e.image,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.event, size: 64),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                e.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(e.date, style: TextStyle(color: Colors.grey.shade700)),
                  if (e.startTime != null) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(e.startTime!, style: TextStyle(color: Colors.grey.shade700)),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.place, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(e.location, style: TextStyle(color: Colors.grey.shade700)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                e.description,
                style: TextStyle(fontSize: 14, height: 1.4, color: Colors.grey.shade800),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _openDirections(e);
                      },
                      icon: const Icon(Icons.directions, size: 20),
                      label: const Text('Get directions'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        final added = await addEventToCalendar(e);
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(added ? 'Added to calendar' : 'Could not parse date'),
                            backgroundColor: added ? Colors.green : null,
                          ),
                        );
                      },
                      icon: const Icon(Icons.event, size: 20),
                      label: const Text('Add to calendar'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() => _selectedEvent = null);
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.grey.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
