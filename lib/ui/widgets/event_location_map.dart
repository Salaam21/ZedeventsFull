import 'package:event_app/app/configs/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class EventLocationMap extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String locationName;

  const EventLocationMap({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  }) : super(key: key);

  @override
  State<EventLocationMap> createState() => _EventLocationMapState();
}

class _EventLocationMapState extends State<EventLocationMap> {
  GoogleMapController? _mapController;
  
  @override
  Widget build(BuildContext context) {
    final LatLng eventLocation = LatLng(widget.latitude, widget.longitude);

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyColor.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: eventLocation,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('event_location'),
                  position: eventLocation,
                  infoWindow: InfoWindow(title: widget.locationName),
                ),
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: ElevatedButton.icon(
                onPressed: () => _openInMaps(),
                icon: const Icon(Icons.directions, size: 18),
                label: const Text('Get Directions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.whiteColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openInMaps() async {
    final lat = widget.latitude;
    final lng = widget.longitude;
    final label = Uri.encodeComponent(widget.locationName);

    // Try Google Maps first (Android)
    final googleUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    
    // Try Apple Maps (iOS)
    final appleUrl = Uri.parse(
        'https://maps.apple.com/?q=$label&ll=$lat,$lng');
    
    // Generic maps URL that works on most devices
    final genericUrl = Uri.parse(
        'geo:$lat,$lng?q=$lat,$lng($label)');

    try {
      if (await canLaunchUrl(googleUrl)) {
        await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(appleUrl)) {
        await launchUrl(appleUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(genericUrl)) {
        await launchUrl(genericUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps')),
        );
      }
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

