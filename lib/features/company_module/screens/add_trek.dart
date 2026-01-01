import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../core/constants.dart';
import '../../../core/local_storage.dart';
import '../../../shared_widgets/custom_text_field.dart';
import '../trek_data.dart';

class AddTrek extends StatefulWidget {
  const AddTrek({super.key});

  @override
  State<AddTrek> createState() => _AddTrekState();
}

class _AddTrekState extends State<AddTrek> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mountainNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _trekDateController = TextEditingController();
  final TextEditingController _trekTimingController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _essentialsController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _difficultyController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();

  final List<File?> _quadImages = List.filled(4, null);

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
    _loadTreks();
    _loadCompanyData();
  }

  Future<void> _loadTreks() async {
    if (TrekData.addedTreks.isEmpty) {
      TrekData.addedTreks.addAll(await LocalStorage.getTreks());
    }
  }

  Future<void> _loadCompanyData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _companyNameController.text = prefs.getString('company_name') ?? '';
      _contactNumberController.text = prefs.getString('business_phone') ?? '';
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mountainNameController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    _trekDateController.dispose();
    _trekTimingController.dispose();
    _locationController.dispose();
    _essentialsController.dispose();
    _durationController.dispose();
    _difficultyController.dispose();
    _companyNameController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(int index) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _quadImages[index] = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () {
                openAppSettings();
              },
            ),
          ),
        );
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _mountainNameController.clear();
    _descriptionController.clear();
    _costController.clear();
    _trekDateController.clear();
    _trekTimingController.clear();
    _locationController.clear();
    _essentialsController.clear();
    _durationController.clear();
    _difficultyController.clear();
    setState(() {
      _quadImages.fillRange(0, 4, null);
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_quadImages.every((image) => image == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select at least one image')),
        );
        return;
      }

      // Copy images to app documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String trekImagesDir = path.join(appDir.path, 'trek_images');
      await Directory(trekImagesDir).create(recursive: true);

      List<String> copiedImagePaths = [];
      for (int i = 0; i < _quadImages.length; i++) {
        if (_quadImages[i] != null) {
          final String fileName =
              'trek_${DateTime.now().millisecondsSinceEpoch}_$i${path.extension(_quadImages[i]!.path)}';
          final String newPath = path.join(trekImagesDir, fileName);
          await _quadImages[i]!.copy(newPath);
          copiedImagePaths.add(newPath);
        }
      }

      // Create trek data
      Map<String, dynamic> newTrek = {
        'name': _mountainNameController.text,
        'description': _descriptionController.text,
        'cost': _costController.text,
        'trekDate': _trekDateController.text,
        'trekTiming': _trekTimingController.text,
        'location': _locationController.text,
        'essentials': _essentialsController.text,
        'duration': _durationController.text,
        'difficulty': _difficultyController.text,
        'companyName': _companyNameController.text,
        'contactNumber': _contactNumberController.text,
        'images': copiedImagePaths,
        'price': _costController.text.isNotEmpty
            ? '₹${_costController.text}'
            : '₹2000',
        'rating': 4.9,
        'participants': 0,
        'status': 'Upcoming',
        'revenue': '₹0',
      };

      // Add to static list
      TrekData.addedTreks.add(newTrek);

      // Save to persistent storage
      await LocalStorage.saveTreks(TrekData.addedTreks);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Trek added successfully!')));
        _resetForm();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryColor.withValues(alpha: 0.1), Colors.white],
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Icon(Icons.terrain, size: 60, color: primaryColor),
                    SizedBox(height: 10),
                    Text(
                      'Add New Trek',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Create an exciting trek experience for adventurers',
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              // Trek Images Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.photo_library, color: primaryColor),
                        SizedBox(width: 8),
                        Text(
                          'Trek Images',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
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
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _pickImage(index),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            height: 120,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.3),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[100],
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: _quadImages[index] != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      _quadImages[index]!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo,
                                        size: 30,
                                        color: primaryColor.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Image ${index + 1}',
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
              SizedBox(height: 24),

              // Basic Information Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: primaryColor),
                        SizedBox(width: 8),
                        Text(
                          'Basic Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      controller: _mountainNameController,
                      labelText: 'Mountain Name',
                      hintText: 'e.g., Everest Base Camp',
                      prefixIcon: Icons.terrain,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter mountain name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      controller: _descriptionController,
                      labelText: 'Description',
                      hintText: 'Describe the trek',
                      maxLines: 3,
                      prefixIcon: Icons.description,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Trek Details Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.details, color: primaryColor),
                        SizedBox(width: 8),
                        Text(
                          'Trek Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _costController,
                            labelText: 'Cost (₹)',
                            hintText: 'e.g., 2000',
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.attach_money,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter cost';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            controller: _durationController,
                            labelText: 'Duration',
                            hintText: 'e.g., 5 days',
                            prefixIcon: Icons.schedule,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter duration';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _trekDateController,
                            labelText: 'Trek Date',
                            hintText: 'e.g., 2023-12-25',
                            prefixIcon: Icons.calendar_today,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter trek date';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            controller: _difficultyController,
                            labelText: 'Difficulty',
                            hintText: 'e.g., Moderate',
                            prefixIcon: Icons.warning,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter difficulty';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      controller: _trekTimingController,
                      labelText: 'Trek Timing',
                      hintText: 'e.g., 8:00 AM - 6:00 PM',
                      prefixIcon: Icons.access_time,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter trek timing';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      controller: _locationController,
                      labelText: 'Location of the Trek',
                      hintText: 'e.g., Himalayas, Nepal',
                      prefixIcon: Icons.location_on,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter location';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      controller: _essentialsController,
                      labelText: 'Essentials to Carry',
                      hintText: 'e.g., Water bottle, snacks, warm clothes',
                      maxLines: 2,
                      prefixIcon: Icons.backpack,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter essentials';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Company Information Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.business_center, color: primaryColor),
                        SizedBox(width: 8),
                        Text(
                          'Company Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _companyNameController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Company Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.business, color: primaryColor),
                        filled: true,
                        fillColor: backgroundColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _contactNumberController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Contact Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.phone, color: primaryColor),
                        filled: true,
                        fillColor: backgroundColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),

              // Submit Button
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Add Trek',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
