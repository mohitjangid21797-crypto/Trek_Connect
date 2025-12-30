import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../shared_widgets/custom_text_field.dart';
import '../services/bluetooth_service.dart';
import '../services/safety_alerts.dart';
import 'map_overlay.dart';

class MessengerScreen extends StatefulWidget {
  final String roomCode;

  const MessengerScreen({super.key, required this.roomCode});

  @override
  State<MessengerScreen> createState() => _MessengerScreenState();
}

class _MessengerScreenState extends State<MessengerScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final BluetoothService _bluetoothService = BluetoothService();
  final SafetyAlerts _safetyAlerts = SafetyAlerts();

  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'Guide',
      'message': 'Welcome to the track! Stay safe and follow instructions.',
      'timestamp': DateTime.now().subtract(Duration(minutes: 5)),
      'isMe': false,
    },
    {
      'sender': 'You',
      'message': 'Thanks! Ready for the adventure.',
      'timestamp': DateTime.now().subtract(Duration(minutes: 3)),
      'isMe': true,
    },
  ];

  bool _isConnected = true;
  bool _isEmergencyMode = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() {
    // Initialize Bluetooth for offline communication
    _bluetoothService.initialize();

    // Listen to safety alerts
    _safetyAlerts.alertStream.listen((alert) {
      if (mounted) {
        _showAlertDialog(alert);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$messengerTitle - ${widget.roomCode}'),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.wifi : Icons.wifi_off),
            onPressed: () {
              // Toggle connection status
              setState(() {
                _isConnected = !_isConnected;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.map),
            onPressed: () {
              // Navigate to map overlay
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapOverlay()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection status bar
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: defaultPadding,
              vertical: 8,
            ),
            color: _isConnected ? Colors.green[100] : Colors.red[100],
            child: Row(
              children: [
                Icon(
                  _isConnected ? Icons.check_circle : Icons.error,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
                SizedBox(width: 8),
                Text(
                  _isConnected
                      ? 'Connected to group'
                      : 'Offline mode - Bluetooth active',
                  style: TextStyle(
                    color: _isConnected ? Colors.green[800] : Colors.red[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(defaultPadding),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Emergency button
          if (_isEmergencyMode)
            Container(
              padding: EdgeInsets.all(defaultPadding),
              color: Colors.red[50],
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'EMERGENCY MODE ACTIVE',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.cancel, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _isEmergencyMode = false;
                      });
                      _safetyAlerts.stopAlert();
                    },
                  ),
                ],
              ),
            ),

          // Message input
          Container(
            padding: EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _messageController,
                    labelText: 'Type a message...',
                    hintText: 'Enter your message',
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: primaryColor),
                  onPressed: _sendMessage,
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.warning, color: Colors.red),
                  onPressed: _triggerEmergency,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    bool isMe = message['isMe'];
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMe ? primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(defaultBorderRadius),
            topRight: Radius.circular(defaultBorderRadius),
            bottomLeft: isMe
                ? Radius.circular(defaultBorderRadius)
                : Radius.zero,
            bottomRight: isMe
                ? Radius.zero
                : Radius.circular(defaultBorderRadius),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message['sender'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isMe ? Colors.white : textColor,
                  fontSize: 12,
                ),
              ),
            Text(
              message['message'],
              style: TextStyle(color: isMe ? Colors.white : textColor),
            ),
            SizedBox(height: 4),
            Text(
              _formatTimestamp(message['timestamp']),
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey[600],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'sender': 'You',
        'message': _messageController.text.trim(),
        'timestamp': DateTime.now(),
        'isMe': true,
      });
    });

    _messageController.clear();
    _scrollToBottom();

    // Send via Bluetooth if offline
    if (!_isConnected) {
      _bluetoothService.sendMessage(_messageController.text.trim());
    }
  }

  void _triggerEmergency() {
    setState(() {
      _isEmergencyMode = true;
    });

    _safetyAlerts.triggerEmergencyAlert('You', 'general');

    // Send emergency signal via Bluetooth
    _bluetoothService.sendEmergencySignal();
  }

  void _showAlertDialog(Map<String, dynamic> alert) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            alert['type'] == 'emergency' ? 'Emergency Alert!' : 'Safety Alert',
            style: TextStyle(color: Colors.red),
          ),
          content: Text(alert['message']),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _safetyAlerts.acknowledgeAlert();
              },
              child: Text('Acknowledge'),
            ),
          ],
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _bluetoothService.dispose();
    _safetyAlerts.dispose();
    super.dispose();
  }
}
