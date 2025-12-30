import 'package:flutter/material.dart';
import '../core/constants.dart';

class RoomPopup extends StatelessWidget {
  final VoidCallback onCodePressed;
  final VoidCallback onQRPressed;

  const RoomPopup({
    super.key,
    required this.onCodePressed,
    required this.onQRPressed,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'code') {
          onCodePressed();
        } else if (value == 'qr') {
          onQRPressed();
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'code',
          child: Row(
            children: [
              Icon(Icons.code, color: primaryColor),
              SizedBox(width: 8),
              Text('Join by Code'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'qr',
          child: Row(
            children: [
              Icon(Icons.qr_code_scanner, color: primaryColor),
              SizedBox(width: 8),
              Text('Scan QR Code'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
        child: Icon(Icons.add, color: Colors.white, size: 24),
      ),
    );
  }
}
