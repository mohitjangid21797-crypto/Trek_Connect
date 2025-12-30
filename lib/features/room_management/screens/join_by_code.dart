import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/local_storage.dart';
import '../../../shared_widgets/custom_text_field.dart';
import '../../../shared_widgets/custom_button.dart';
import '../services/bluetooth_service.dart';
import 'messenger_screen.dart';

class JoinByCode extends StatefulWidget {
  const JoinByCode({super.key});

  @override
  State<JoinByCode> createState() => _JoinByCodeState();
}

class _JoinByCodeState extends State<JoinByCode> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  final BluetoothService _bluetoothService = BluetoothService();

  // Simulated active room database
  final List<String> _activeRoomCodes = ['ABC123', 'XYZ456', 'TREK789'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(joinByCodeTitle),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Room Code',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Ask the trek organizer for the room code to join the group.',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            SizedBox(height: 32),
            CustomTextField(
              controller: _codeController,
              labelText: 'Write Code',
              hintText: 'Enter 6-digit code',
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a room code';
                }
                if (value.length != 6) {
                  return 'Room code must be 6 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 32),
            CustomButton(
              text: 'Join Room',
              onPressed: _joinRoom,
              isLoading: _isLoading,
            ),
            SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Back to Options',
                  style: TextStyle(color: primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _joinRoom() async {
    String code = _codeController.text.trim().toUpperCase();

    if (code.isEmpty || code.length != 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid 6-digit room code'),
            backgroundColor: errorColor,
          ),
        );
      }
      return;
    }

    // Validate against active room database
    if (!_activeRoomCodes.contains(code)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid room code. Please check with the organizer.',
            ),
            backgroundColor: errorColor,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Retrieve user's name from local storage
    String? userName = await LocalStorage.getUserName();
    userName ??= 'Anonymous'; // Fallback if no name stored

    // Initialize Bluetooth for offline location sharing
    _bluetoothService.initialize();

    // Simulate joining room
    await Future.delayed(Duration(seconds: 2));

    // Associate user's name with the room session (store in local storage)
    await LocalStorage.saveCompanyName(code);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully joined room: $code as $userName'),
          backgroundColor: primaryColor,
        ),
      );

      // Navigate to messenger screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MessengerScreen(roomCode: code),
        ),
      );
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
