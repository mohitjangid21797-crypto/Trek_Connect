import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/local_storage.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    // Load bookings from local storage
    final bookings = await LocalStorage.getBookings();
    if (mounted) {
      setState(() {
        _bookings = bookings;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trek Bookings'),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Bookings',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor.withValues(alpha: 0.1), Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Summary Cards
            _buildSummaryCards(),
            // Bookings List
            Expanded(child: _buildBookingsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    int totalBookings = _bookings.length;
    int confirmedBookings = _bookings
        .where((b) => b['status'] == 'Confirmed')
        .length;
    int pendingBookings = _bookings
        .where((b) => b['status'] == 'Pending')
        .length;
    double totalRevenue = _bookings
        .where((b) => b['paymentStatus'] == 'Paid')
        .fold(0.0, (sum, b) {
          String amountStr = b['totalAmount']
              .replaceAll('₹', '')
              .replaceAll(',', '');
          return sum + (double.tryParse(amountStr) ?? 0.0);
        });

    return Container(
      padding: EdgeInsets.all(defaultPadding),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Bookings',
              totalBookings.toString(),
              Icons.book_online,
              Colors.blue,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'Confirmed',
              confirmedBookings.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'Pending',
              pendingBookings.toString(),
              Icons.pending,
              Colors.orange,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'Revenue',
              '₹${totalRevenue.toInt()}',
              Icons.attach_money,
              Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500),
      builder: (context, animationValue, child) {
        return Transform.scale(
          scale: animationValue,
          child: Opacity(
            opacity: animationValue,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    Icon(icon, color: color, size: 20),
                    SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      title,
                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookingsList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: defaultPadding),
      itemCount: _bookings.length,
      itemBuilder: (context, index) {
        final booking = _bookings[index];
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Container(
                  margin: EdgeInsets.only(bottom: 12),
                  child: _buildBookingCard(booking),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    Color statusColor;
    switch (booking['status']) {
      case 'Confirmed':
        statusColor = Colors.green;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showBookingDetails(booking),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with ID and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Booking ${booking['id']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      booking['status'],
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Trek Name
              Text(
                booking['trekName'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: 8),

              // Customer Info
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      booking['customerName'],
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),

              // Trek Date and Participants
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    'Trek: ${booking['trekDate']}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    '${booking['participants']} participants',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Amount and Payment Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    booking['totalAmount'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: booking['paymentStatus'] == 'Paid'
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      booking['paymentStatus'],
                      style: TextStyle(
                        color: booking['paymentStatus'] == 'Paid'
                            ? Colors.green
                            : Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 16),
            _buildDetailRow('Booking ID', booking['id']),
            _buildDetailRow('Trek', booking['trekName']),
            _buildDetailRow('Customer', booking['customerName']),
            _buildDetailRow('Email', booking['customerEmail']),
            _buildDetailRow('Phone', booking['customerPhone']),
            _buildDetailRow('Booking Date', booking['bookingDate']),
            _buildDetailRow('Trek Date', booking['trekDate']),
            _buildDetailRow('Participants', booking['participants'].toString()),
            _buildDetailRow('Total Amount', booking['totalAmount']),
            _buildDetailRow('Status', booking['status']),
            _buildDetailRow('Payment', booking['paymentStatus']),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Handle contact customer
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Contacting ${booking['customerName']}...',
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.call),
                    label: Text('Contact'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Handle update status
                      Navigator.pop(context);
                      _showStatusUpdateDialog(booking);
                    },
                    icon: Icon(Icons.edit),
                    label: Text('Update Status'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: textColor)),
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(Map<String, dynamic> booking) {
    String selectedStatus = booking['status'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Booking Status'),
        content: DropdownButtonFormField<String>(
          initialValue: selectedStatus,
          decoration: InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(),
          ),
          items: ['Confirmed', 'Pending', 'Cancelled']
              .map(
                (status) =>
                    DropdownMenuItem(value: status, child: Text(status)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              selectedStatus = value;
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Update booking status (in real app, this would call an API)
              setState(() {
                booking['status'] = selectedStatus;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Booking status updated to $selectedStatus'),
                ),
              );
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Bookings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: Text('Confirmed'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: Text('Pending'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: Text('Cancelled'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Apply'),
          ),
        ],
      ),
    );
  }
}
