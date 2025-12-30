import 'dart:async';
import 'dart:io';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  bool _isInitialized = false;
  bool _isScanning = false;
  bool _isConnected = false;

  final StreamController<String> _messageController =
      StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _deviceController =
      StreamController.broadcast();

  Stream<String> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get deviceStream => _deviceController.stream;

  bool get isInitialized => _isInitialized;
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Simulate Bluetooth initialization
    await Future.delayed(Duration(seconds: 1));
    _isInitialized = true;
    stdout.write('Bluetooth service initialized');
  }

  Future<void> startScanning() async {
    if (!_isInitialized || _isScanning) return;

    _isScanning = true;
    stdout.write('Started scanning for Bluetooth devices');

    // Simulate finding devices
    Timer.periodic(Duration(seconds: 2), (timer) {
      if (!_isScanning) {
        timer.cancel();
        return;
      }

      // Simulate found device
      final device = {
        'name': 'Trek Device ${DateTime.now().millisecondsSinceEpoch % 100}',
        'id': 'device_${DateTime.now().millisecondsSinceEpoch}',
        'rssi': -50 - (DateTime.now().millisecondsSinceEpoch % 30),
        'timestamp': DateTime.now(),
      };

      _deviceController.add(device);
    });

    // Stop scanning after 10 seconds
    Timer(Duration(seconds: 10), () {
      stopScanning();
    });
  }

  void stopScanning() {
    _isScanning = false;
    stdout.write('Stopped scanning for Bluetooth devices');
  }

  Future<bool> connectToDevice(String deviceId) async {
    if (!_isInitialized) return false;

    // Simulate connection attempt
    await Future.delayed(Duration(seconds: 2));

    // Simulate successful connection (90% success rate)
    bool success = DateTime.now().millisecondsSinceEpoch % 10 != 0;

    if (success) {
      _isConnected = true;
      stdout.write('Connected to device: $deviceId');
    } else {
      stdout.write('Failed to connect to device: $deviceId');
    }

    return success;
  }

  void disconnect() {
    _isConnected = false;
    stdout.write('Disconnected from Bluetooth device');
  }

  void sendMessage(String message) {
    if (!_isConnected) {
      stdout.write('Cannot send message: not connected to device');
      return;
    }

    // Simulate sending message via Bluetooth
    stdout.write('Sent message via Bluetooth: $message');

    // Simulate receiving echo (for testing)
    Timer(Duration(seconds: 1), () {
      final echoMessage = 'Echo: $message';
      _messageController.add(echoMessage);
    });
  }

  void sendEmergencySignal() {
    if (!_isConnected) {
      stdout.write('Cannot send emergency signal: not connected to device');
      return;
    }

    // Simulate sending emergency signal
    stdout.write('Emergency signal sent via Bluetooth');

    // Broadcast emergency to all nearby devices
    final emergencyMessage = 'EMERGENCY: Help needed!';
    _messageController.add(emergencyMessage);
  }

  void sendLocationUpdate(double lat, double lng) {
    if (!_isConnected) return;

    final locationMessage = 'LOCATION_UPDATE:$lat,$lng';
    stdout.write('Sent location update via Bluetooth: $locationMessage');
  }

  void sendSafetyAlert(String alertType, String message) {
    if (!_isConnected) return;

    final alertMessage = 'SAFETY_ALERT:$alertType:$message';
    stdout.write('Sent safety alert via Bluetooth: $alertMessage');
  }

  void dispose() {
    _messageController.close();
    _deviceController.close();
    disconnect();
    stdout.write('Bluetooth service disposed');
  }
}
