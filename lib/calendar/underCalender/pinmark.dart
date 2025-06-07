import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../LatLng/findLatLng.dart';

class LocationMap extends StatefulWidget {
  final String locationName; // 예: "스타벅스 충북대학교병원점"

  const LocationMap({super.key, required this.locationName});

  @override
  State<LocationMap> createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  LatLng? markerPosition;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final coordinates = await getCoordinatesFromLocation(widget.locationName);
    print('요청 주소: ${widget.locationName}');
    print('받은 좌표: $coordinates}');
    if (coordinates != null) {
      setState(() {
        markerPosition = coordinates;
      });
    } else {
      setState(() {
        markerPosition = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (markerPosition == null) {
      return const Center(child: Text('위치를 찾을 수 없습니다.'));
    }
    return SizedBox(
      height: 200, // 바텀시트에서 보여질 높이
      child: markerPosition == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
        options: MapOptions(
          initialCenter: markerPosition!,
          initialZoom: 17,
        ),
        children: [
          TileLayer(
            urlTemplate:
            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 40,
                height: 40,
                point: markerPosition!,
                child: const Icon(Icons.location_on,
                    color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
