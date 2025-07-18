import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class KonumBilgisi extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final String? locationName;

  const KonumBilgisi({
    super.key,
    this.latitude,
    this.longitude,
    this.locationName,
  });

  bool _isValidCoordinate(double? lat, double? lng) {
    return lat != null &&
        lng != null &&
        !lat.isNaN &&
        !lng.isNaN &&
        !lat.isInfinite &&
        !lng.isInfinite;
  }

  @override
  Widget build(BuildContext context) {
    if (_isValidCoordinate(latitude, longitude)) {
      return _buildMap(LatLng(latitude!, longitude!));
    }

    if (locationName != null && locationName!.isNotEmpty) {
      return FutureBuilder<List<Location>>(
        future: locationFromAddress(locationName!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Konum bulunamadı",
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          } else {
            final loc = snapshot.data!.first;
            return _buildMap(LatLng(loc.latitude, loc.longitude));
          }
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildMap(LatLng center) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade300),
        ),
        clipBehavior: Clip.antiAlias,
        child: FlutterMap(
          options: MapOptions(initialCenter: center, initialZoom: 15),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.stayzi_ui',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: center,
                  width: 40,
                  height: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(blurRadius: 4, color: Colors.black26),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
