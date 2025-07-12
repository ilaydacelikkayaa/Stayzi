import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class KonumBilgisi extends StatelessWidget {
  final double? latitude;
  final double? longitude;

  const KonumBilgisi({super.key, this.latitude, this.longitude});

  @override
  Widget build(BuildContext context) {
    if (latitude == null ||
        longitude == null ||
        latitude!.isNaN ||
        longitude!.isNaN ||
        latitude!.isInfinite ||
        longitude!.isInfinite) {
      debugPrint('Geçersiz konum: latitude=$latitude, longitude=$longitude');
      return const SizedBox.shrink();
    }

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
          options: MapOptions(
            initialCenter: LatLng(latitude!, longitude!),
            initialZoom: 15,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.stayzi_ui',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(latitude!, longitude!),
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
