import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerScreen extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final Function(double lat, double lng, String address) onLocationSelected;

  const LocationPickerScreen({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
    required this.onLocationSelected,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late LatLng _selectedLocation;
  String _selectedAddress = '';
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = LatLng(widget.initialLatitude, widget.initialLongitude);
    _getAddressFromCoordinates();
  }

  Future<void> _getAddressFromCoordinates() async {
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _selectedLocation.latitude,
        _selectedLocation.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address = [
          placemark.locality,
          placemark.subLocality,
          placemark.thoroughfare,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
        
        setState(() {
          _selectedAddress = address;
          _isLoadingAddress = false;
        });
      } else {
        setState(() {
          _selectedAddress = 'Adres bulunamadı';
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress = 'Adres alınamadı';
        _isLoadingAddress = false;
      });
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedLocation = point;
    });
    _getAddressFromCoordinates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Konum Seç',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              widget.onLocationSelected(
                _selectedLocation.latitude,
                _selectedLocation.longitude,
                _selectedAddress,
              );
              Navigator.of(context).pop();
            },
            child: const Text(
              'Seç',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Adres bilgisi
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.red[600], size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Seçilen Konum:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _isLoadingAddress
                          ? const Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 8),
                                Text('Adres alınıyor...'),
                              ],
                            )
                          : Text(
                              _selectedAddress.isNotEmpty
                                  ? _selectedAddress
                                  : 'Haritaya tıklayarak konum seçin',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Harita
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _selectedLocation,
                initialZoom: 15,
                onTap: _onMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.stayzi_ui',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation,
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(blurRadius: 8, color: Colors.black26),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Alt bilgi
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: const Text(
              'Haritaya tıklayarak konumunuzu seçin',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
} 