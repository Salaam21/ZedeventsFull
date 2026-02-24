import 'package:event_app/app/configs/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class EventLocationMap extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String locationName;

  const EventLocationMap({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });

  @override
  State<EventLocationMap> createState() => _EventLocationMapState();
}

class _EventLocationMapState extends State<EventLocationMap> {
  @override
  Widget build(BuildContext context) {
    final LatLng eventLocation = LatLng(widget.latitude, widget.longitude);

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyColor.withValues(alpha: 0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: eventLocation,
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.event_app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: eventLocation,
                      width: 36,
                      height: 36,
                      child: const Icon(
                        Icons.place,
                        color: AppColors.primaryColor,
                        size: 36,
                      ),
                    ),
                  ],
                ),
              ],
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
    final lat = widget.latitude.toStringAsFixed(6);
    final lng = widget.longitude.toStringAsFixed(6);
    final label = Uri.encodeComponent(widget.locationName);

    final googleUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );
    final appleUrl = Uri.parse(
      'https://maps.apple.com/?q=$label&ll=$lat,$lng',
    );
    final genericUrl = Uri.parse(
      'geo:$lat,$lng?q=$lat,$lng($label)',
    );

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
}
