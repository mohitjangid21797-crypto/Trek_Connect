import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

class SafetyAlerts {
  static final SafetyAlerts _instance = SafetyAlerts._internal();
  factory SafetyAlerts() => _instance;
  SafetyAlerts._internal();

  Timer? _beepTimer;
  bool _isAlertActive = false;
  final StreamController<Map<String, dynamic>> _alertController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get alertStream => _alertController.stream;

  bool get isAlertActive => _isAlertActive;

  void triggerGeofenceAlert(String participantName, String alertType) {
    if (_isAlertActive) return;

    _isAlertActive = true;

    final alert = {
      'type': 'geofence',
      'participant': participantName,
      'alertType': alertType, // 'boundary' or 'outside'
      'timestamp': DateTime.now(),
      'message': alertType == 'boundary'
          ? '$participantName is near the geofence boundary'
          : '$participantName has left the safe zone',
    };

    _alertController.add(alert);
    _startBeeping();
    // print('Geofence alert triggered: ${alert['message']}');
  }

  void triggerEmergencyAlert(String participantName, String emergencyType) {
    if (_isAlertActive) return;

    _isAlertActive = true;

    final alert = {
      'type': 'emergency',
      'participant': participantName,
      'alertType': emergencyType, // 'medical', 'lost', 'weather', etc.
      'timestamp': DateTime.now(),
      'message': 'Emergency alert from $participantName: $emergencyType',
    };

    _alertController.add(alert);
    _startBeeping();
    // print('Emergency alert triggered: ${alert['message']}');
  }

  void triggerWeatherAlert(String weatherCondition, String severity) {
    if (_isAlertActive) return;

    _isAlertActive = true;

    final alert = {
      'type': 'weather',
      'condition': weatherCondition,
      'severity': severity, // 'low', 'medium', 'high'
      'timestamp': DateTime.now(),
      'message': 'Weather alert: $weatherCondition ($severity severity)',
    };

    _alertController.add(alert);
    _startBeeping();
     stdout.write('Weather alert triggered: ${alert['message']}');
  }

  void _startBeeping() {
    // Simulate beeping sound every 2 seconds
    _beepTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      // In a real app, this would play an actual beep sound
       stdout.write('BEEP! Safety alert active');
    });
  }

  void stopAlert() {
    _isAlertActive = false;
    _beepTimer?.cancel();
    _beepTimer = null;
    stdout.write('Safety alert stopped');
  }

  void acknowledgeAlert() {
    stopAlert();
    final ackAlert = {
      'type': 'acknowledged',
      'timestamp': DateTime.now(),
      'message': 'Alert acknowledged by user',
    };
    _alertController.add(ackAlert);
  }

  // Check if participant is within geofence bounds
  bool isWithinGeofence(
    double lat,
    double lng,
    double centerLat,
    double centerLng,
    double radiusKm,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    double dLat = _degreesToRadians(lat - centerLat);
    double dLng = _degreesToRadians(lng - centerLng);

    double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(centerLat) *
            math.cos(lat) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    double distance = earthRadius * c;
    return distance <= radiusKm;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.141592653589793 / 180);
  }

  // Monitor participant locations and trigger alerts if needed
  void monitorParticipant(String participantName, double lat, double lng) {
    // Define geofence center (e.g., trek starting point)
    const double geofenceCenterLat = 27.9881; // Everest Base Camp area
    const double geofenceCenterLng = 86.9250;
    const double geofenceRadius = 5.0; // 5km radius

    bool withinGeofence = isWithinGeofence(
      lat,
      lng,
      geofenceCenterLat,
      geofenceCenterLng,
      geofenceRadius,
    );

    if (!withinGeofence) {
      triggerGeofenceAlert(participantName, 'outside');
    } else {
      // Check if near boundary (within 500m of edge)
      bool nearBoundary = isWithinGeofence(
        lat,
        lng,
        geofenceCenterLat,
        geofenceCenterLng,
        geofenceRadius - 0.5,
      );
      if (!nearBoundary) {
        triggerGeofenceAlert(participantName, 'boundary');
      }
    }
  }

  void dispose() {
    _beepTimer?.cancel();
    _alertController.close();
  }
}
