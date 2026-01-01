import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants.dart';
import '../../../core/local_storage.dart';
import '../services/bluetooth_service.dart';

import 'messenger_screen.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  MobileScannerController? _controller;
  bool _isScanning = false;
  String _scannedCode = '';
  bool _hasPermission = false;
  final BluetoothService _bluetoothService = BluetoothService();

  // Simulated active room database
  final List<String> _activeRoomCodes = ['ABC123', 'XYZ456', 'TREK789'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(qrScannerTitle),
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: _hasPermission
                ? MobileScanner(
                    controller: _controller ??= MobileScannerController(),
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        if (barcode.rawValue != null &&
                            barcode.rawValue!.isNotEmpty &&
                            !_isScanning) {
                          _processScannedCode(barcode.rawValue!);
                        }
                      }
                    },
                  )
                : Container(
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 100,
                            color: primaryColor,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Camera permission required',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _requestCameraPermission,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                            ),
                            child: Text('Grant Permission'),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          Container(
            padding: EdgeInsets.all(defaultPadding),
            color: Colors.white,
            child: Column(
              children: [
                if (_scannedCode.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(defaultBorderRadius),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Code: $_scannedCode',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isScanning ? null : _startScanning,
                        icon: Icon(_isScanning ? Icons.stop : Icons.play_arrow),
                        label: Text(
                          _isScanning ? 'Stop Scanning' : 'Start Scanning',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back),
                      label: Text('Back'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _requestCameraPermission() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
      });
      _startScanning();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera permission denied'),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  void _startScanning() async {
    if (!_hasPermission) {
      _requestCameraPermission();
      return;
    }

    setState(() {
      _isScanning = true;
      _scannedCode = '';
    });

    // Camera is already active via QRView
  }

  void _processScannedCode(String code) async {
    String trimmedCode = code.trim().toUpperCase();

    setState(() {
      _isScanning = false;
      _scannedCode = trimmedCode;
    });

    // Validate against active room database
    if (!_activeRoomCodes.contains(trimmedCode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid QR code. Please scan a valid room code.'),
          backgroundColor: errorColor,
        ),
      );
      return;
    }

    // Retrieve user's name from local storage
    String? userName = await LocalStorage.getUserName();
    userName ??= 'Anonymous'; // Fallback if no name stored

    // Initialize Bluetooth for offline location sharing
    await _bluetoothService.initialize();

    // Store room association in local storage
    await LocalStorage.saveCompanyName(trimmedCode);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully joined room: $trimmedCode as $userName'),
          backgroundColor: primaryColor,
        ),
      );

      // Navigate directly to messenger screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MessengerScreen(roomCode: trimmedCode),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
