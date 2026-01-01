import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class MapOverlay extends StatefulWidget {
  const MapOverlay({super.key});

  @override
  State<MapOverlay> createState() => _MapOverlayState();
}

class _MapOverlayState extends State<MapOverlay> {
  bool _geofencingEnabled = true;
  final List<Map<String, dynamic>> _participants = [
    {'name': 'John Doe', 'lat': 27.9881, 'lng': 86.9250, 'status': 'safe'},
    {'name': 'Sarah', 'lat': 27.9885, 'lng': 86.9255, 'status': 'safe'},
    {'name': 'Mike', 'lat': 27.9875, 'lng': 86.9245, 'status': 'warning'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mapOverlayTitle),
        backgroundColor: primaryColor,
        actions: [
          Switch(
            value: _geofencingEnabled,
            onChanged: (value) {
              setState(() {
                _geofencingEnabled = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Geofencing ${value ? 'enabled' : 'disabled'}'),
                  backgroundColor: primaryColor,
                ),
              );
            },
            activeThumbColor: primaryColor,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map placeholder
          Container(
            color: Colors.grey[300],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 80, color: primaryColor),
                  SizedBox(height: 20),
                  Text(
                    'Interactive Map View',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Showing participant locations and geofences',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          // Participants overlay
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              width: 200,
              padding: EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(defaultBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Participants',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  ..._participants.map(
                    (participant) => _buildParticipantItem(participant),
                  ),
                ],
              ),
            ),
          ),

          // Geofencing status
          if (_geofencingEnabled)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(defaultPadding),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(defaultBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: primaryColor),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Geofencing Active: Monitoring participant locations',
                        style: TextStyle(color: textColor),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.warning, color: Colors.orange),
                      onPressed: () {
                        // Show geofence alerts
                        _showGeofenceAlerts();
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildParticipantItem(Map<String, dynamic> participant) {
    Color statusColor;
    IconData statusIcon;

    switch (participant['status']) {
      case 'safe':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'warning':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      case 'danger':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              participant['name'],
              style: TextStyle(color: textColor, fontSize: 14),
            ),
          ),
          Text(
            '${participant['lat'].toStringAsFixed(4)}, ${participant['lng'].toStringAsFixed(4)}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showGeofenceAlerts() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(defaultBorderRadius),
          topRight: Radius.circular(defaultBorderRadius),
        ),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Geofence Alerts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 20),
              ..._participants.where((p) => p['status'] != 'safe').map((
                participant,
              ) {
                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: participant['status'] == 'warning'
                        ? Colors.orange[50]
                        : Colors.red[50],
                    borderRadius: BorderRadius.circular(defaultBorderRadius),
                    border: Border.all(
                      color: participant['status'] == 'warning'
                          ? Colors.orange
                          : Colors.red,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        participant['status'] == 'warning'
                            ? Icons.warning
                            : Icons.error,
                        color: participant['status'] == 'warning'
                            ? Colors.orange
                            : Colors.red,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${participant['name']} is ${participant['status'] == 'warning' ? 'near geofence boundary' : 'outside safe zone'}',
                          style: TextStyle(color: textColor),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}
