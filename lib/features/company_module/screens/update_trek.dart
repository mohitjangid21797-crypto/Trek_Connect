import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../core/local_storage.dart';
import '../../../shared_widgets/custom_text_field.dart';
import '../trek_data.dart';

class UpdateTrek extends StatefulWidget {
  const UpdateTrek({super.key});

  @override
  State<UpdateTrek> createState() => _UpdateTrekState();
}

class _UpdateTrekState extends State<UpdateTrek> with TickerProviderStateMixin {
  List<Map<String, dynamic>> _treks = [];
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _loadTreks();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadTreks() async {
    _treks = List.from(TrekData.addedTreks);
    setState(() {});
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        // ignore: use_build_context_synchronously
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _selectedDateTime ?? DateTime.now(),
        ),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _showEditDialog(BuildContext outerContext, int index) {
    final trek = _treks[index];
    final nameController = TextEditingController(text: trek['name'] ?? '');
    final companyController = TextEditingController(
      text: trek['companyName'] ?? '',
    );
    final locationController = TextEditingController(
      text: trek['location'] ?? '',
    );
    final durationController = TextEditingController(
      text: trek['duration'] ?? '',
    );
    final difficultyController = TextEditingController(
      text: trek['difficulty'] ?? '',
    );
    final priceController = TextEditingController(text: trek['price'] ?? '');
    final ratingController = TextEditingController(
      text: trek['rating']?.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: trek['description'] ?? '',
    );
    final trekTimingController = TextEditingController(
      text: trek['trekTiming'] ?? '',
    );
    final essentialsController = TextEditingController(
      text: trek['essentials'] ?? '',
    );
    final contactNumberController = TextEditingController(
      text: trek['contactNumber'] ?? '',
    );
    final costController = TextEditingController(text: trek['cost'] ?? '');
    final participantsController = TextEditingController(
      text: trek['participants']?.toString() ?? '',
    );
    final statusController = TextEditingController(text: trek['status'] ?? '');
    final revenueController = TextEditingController(
      text: trek['revenue'] ?? '',
    );

    // Initialize selectedDateTime from existing trekDate
    _selectedDateTime = trek['trekDate'] != null && trek['trekDate'].isNotEmpty
        ? DateTime.tryParse(trek['trekDate'])
        : null;

    List<String> images = List<String>.from(trek['images'] ?? []);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.edit, color: primaryColor),
              SizedBox(width: 8),
              Text('Edit Trek', style: TextStyle(color: primaryColor)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(defaultBorderRadius),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Basic Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 12),
                      CustomTextField(
                        controller: nameController,
                        labelText: 'Trek Name',
                        prefixIcon: Icons.hiking,
                      ),
                      SizedBox(height: 12),
                      CustomTextField(
                        controller: companyController,
                        labelText: 'Company Name',
                        prefixIcon: Icons.business,
                      ),
                      SizedBox(height: 12),
                      CustomTextField(
                        controller: locationController,
                        labelText: 'Location',
                        prefixIcon: Icons.location_on,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: secondaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(defaultBorderRadius),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Trek Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: durationController,
                              labelText: 'Duration',
                              prefixIcon: Icons.access_time,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: CustomTextField(
                              controller: difficultyController,
                              labelText: 'Difficulty',
                              prefixIcon: Icons.terrain,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: priceController,
                              labelText: 'Price',
                              prefixIcon: Icons.attach_money,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: CustomTextField(
                              controller: ratingController,
                              labelText: 'Rating',
                              prefixIcon: Icons.star,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedDateTime != null
                                  ? DateFormat(
                                      'yyyy-MM-dd HH:mm',
                                    ).format(_selectedDateTime!)
                                  : 'Select Date & Time',
                              style: TextStyle(
                                fontSize: 16,
                                color: _selectedDateTime != null
                                    ? textColor
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.calendar_today,
                              color: primaryColor,
                            ),
                            onPressed: () => _selectDateTime(context),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      CustomTextField(
                        controller: descriptionController,
                        labelText: 'Description',
                        prefixIcon: Icons.description,
                      ),
                      SizedBox(height: 12),
                      CustomTextField(
                        controller: trekTimingController,
                        labelText: 'Trek Timing',
                        prefixIcon: Icons.access_time,
                      ),
                      SizedBox(height: 12),
                      CustomTextField(
                        controller: essentialsController,
                        labelText: 'Essentials to Carry',
                        prefixIcon: Icons.backpack,
                      ),
                      SizedBox(height: 12),
                      CustomTextField(
                        controller: contactNumberController,
                        labelText: 'Contact Number',
                        prefixIcon: Icons.phone,
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: costController,
                              labelText: 'Cost (₹)',
                              prefixIcon: Icons.attach_money,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: CustomTextField(
                              controller: participantsController,
                              labelText: 'Participants',
                              prefixIcon: Icons.people,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: statusController,
                              labelText: 'Status',
                              prefixIcon: Icons.info,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: CustomTextField(
                              controller: revenueController,
                              labelText: 'Revenue',
                              prefixIcon: Icons.money,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(defaultBorderRadius),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Quad View Images (up to 4)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: 4,
                        itemBuilder: (context, imgIndex) {
                          return GestureDetector(
                            onTap: () async {
                              final picker = ImagePicker();
                              final pickedFile = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (pickedFile != null) {
                                setState(() {
                                  if (imgIndex < images.length) {
                                    images[imgIndex] = pickedFile.path;
                                  } else {
                                    images.add(pickedFile.path);
                                  }
                                });
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.3),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                              ),
                              child:
                                  imgIndex < images.length &&
                                      images[imgIndex].isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(images[imgIndex]),
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo,
                                          color: primaryColor,
                                          size: 32,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Add Image',
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Close the dialog first
                Navigator.pop(context);

                // Update trek
                final updatedTrek = {
                  'name': nameController.text,
                  'companyName': companyController.text,
                  'location': locationController.text,
                  'duration': durationController.text,
                  'difficulty': difficultyController.text,
                  'price': priceController.text,
                  'rating': double.tryParse(ratingController.text) ?? 0.0,
                  'trekDate': _selectedDateTime != null
                      ? DateFormat(
                          'yyyy-MM-dd HH:mm',
                        ).format(_selectedDateTime!)
                      : '',
                  'description': descriptionController.text,
                  'trekTiming': trekTimingController.text,
                  'essentials': essentialsController.text,
                  'contactNumber': contactNumberController.text,
                  'cost': costController.text,
                  'participants':
                      int.tryParse(participantsController.text) ?? 0,
                  'status': statusController.text,
                  'revenue': revenueController.text,
                  'images': images,
                };

                TrekData.addedTreks[index] = updatedTrek;
                await LocalStorage.saveTreks(TrekData.addedTreks);
                _loadTreks();
                // Show success popup
                showDialog(
                  // ignore: use_build_context_synchronously
                  context: outerContext,
                  builder: (context) => AlertDialog(
                    title: Text('Success'),
                    content: Text('Changes are made successfully'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Treks'),
        backgroundColor: primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundColor, Colors.white, backgroundColor],
          ),
        ),
        child: _treks.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.hiking, size: 64, color: primaryColor),
                    SizedBox(height: 16),
                    Text(
                      'No treks to update',
                      style: TextStyle(fontSize: 18, color: textColor),
                    ),
                  ],
                ),
              )
            : FadeTransition(
                opacity: _fadeAnimation,
                child: ListView.builder(
                  padding: EdgeInsets.all(defaultPadding),
                  itemCount: _treks.length,
                  itemBuilder: (context, index) {
                    final trek = _treks[index];
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: EdgeInsets.only(bottom: 16),
                      child: Card(
                        elevation: defaultElevation,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            defaultBorderRadius,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child:
                                        trek['images'] != null &&
                                            (trek['images'] as List).isNotEmpty
                                        ? Image.file(
                                            File(trek['images'][0]),
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: 80,
                                            height: 80,
                                            color: accentColor,
                                            child: Icon(
                                              Icons.image,
                                              color: primaryColor,
                                              size: 40,
                                            ),
                                          ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          trek['name'] ?? 'Unknown Trek',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 16,
                                              color: primaryColor,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              trek['location'] ??
                                                  'Unknown Location',
                                              style: TextStyle(
                                                color: textColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              size: 16,
                                              color: Colors.amber,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              '${trek['rating']?.toStringAsFixed(1) ?? '0.0'}',
                                              style: TextStyle(
                                                color: textColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  ScaleTransition(
                                    scale: Tween<double>(begin: 1.0, end: 1.1)
                                        .animate(
                                          CurvedAnimation(
                                            parent: _fadeController,
                                            curve: Curves.easeInOut,
                                          ),
                                        ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: primaryColor,
                                      ),
                                      onPressed: () =>
                                          _showEditDialog(context, index),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: primaryColor,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        trek['duration'] ?? 'N/A',
                                        style: TextStyle(color: textColor),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.terrain,
                                        size: 16,
                                        color: primaryColor,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        trek['difficulty'] ?? 'N/A',
                                        style: TextStyle(color: textColor),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '\$${trek['price'] ?? '0'}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
