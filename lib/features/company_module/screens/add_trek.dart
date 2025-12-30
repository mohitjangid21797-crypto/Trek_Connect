import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants.dart';
import '../../../core/local_storage.dart';
import '../../../shared_widgets/custom_button.dart';
import '../../../shared_widgets/custom_text_field.dart';
import '../trek_data.dart';
import 'trek_history.dart';

class AddTrek extends StatefulWidget {
  const AddTrek({super.key});

  @override
  State<AddTrek> createState() => _AddTrekState();
}

class _AddTrekState extends State<AddTrek> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mountainNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _essentialsController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _companyNumberController =
      TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  String? _selectedDifficulty;
  File? _coverImage;
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final List<String> _difficulties = ['Easy', 'Moderate', 'Hard', 'Extreme'];

  @override
  void initState() {
    super.initState();
    _loadTreks();
  }

  Future<void> _loadTreks() async {
    if (TrekData.addedTreks.isEmpty) {
      TrekData.addedTreks.addAll(await LocalStorage.getTreks());
    }
    await _loadCompanyData();
  }

  Future<void> _loadCompanyData() async {
    final prefs = await SharedPreferences.getInstance();
    final companyName = prefs.getString('company_name') ?? '';
    final companyNumber = prefs.getString('business_phone') ?? '';
    setState(() {
      _companyNameController.text = companyName;
      _companyNumberController.text = companyNumber;
    });
  }

  @override
  void dispose() {
    _mountainNameController.dispose();
    _locationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _descriptionController.dispose();
    _essentialsController.dispose();
    _costController.dispose();
    _companyNameController.dispose();
    _companyNumberController.dispose();
    super.dispose();
  }

  String _formatTime12Hour(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _coverImage = File(image.path);
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

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          _startDateController.text = "${picked.toLocal()}".split(' ')[0];
        } else {
          _endDate = picked;
          _endDateController.text = "${picked.toLocal()}".split(' ')[0];
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
          _startTimeController.text = _formatTime12Hour(picked);
        } else {
          _endTime = picked;
          _endTimeController.text = _formatTime12Hour(picked);
        }
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_coverImage == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please select a cover image')));
        return;
      }

      // Create trek data
      Map<String, dynamic> newTrek = {
        'name': _mountainNameController.text,
        'location': _locationController.text,
        'difficulty': _selectedDifficulty,
        'startDate': _startDate?.toIso8601String(),
        'endDate': _endDate?.toIso8601String(),
        'startTime': _startTime?.format(context),
        'endTime': _endTime?.format(context),
        'image': _coverImage!.path, // Store path for now
        'company': _companyNameController.text,
        'companyNumber': _companyNumberController.text,
        'description': _descriptionController.text,
        'Essential to carry': _essentialsController.text,
        'cost': _costController.text,
        'duration': _calculateDuration(),
        'price': _costController.text.isNotEmpty
            ? '₹${_costController.text}'
            : '₹2000', // Use cost field
        'rating': 4.9,
        'date': _startDate != null
            ? "${_startDate!.toLocal()}".split(' ')[0]
            : 'N/A',
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

        // Navigate to Trek History
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: Text('Trek History'),
                backgroundColor: primaryColor,
              ),
              body: TrekHistory(),
            ),
          ),
        );
      }
    }
  }

  String _calculateDuration() {
    if (_startDate != null && _endDate != null) {
      int days = _endDate!.difference(_startDate!).inDays + 1;
      return '$days days';
    }
    return 'N/A';
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
              AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 500),
                child: Text(
                  'Cover Image',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              SizedBox(height: 8),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: GestureDetector(
                  key: ValueKey(_coverImage?.path ?? 'no-image'),
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
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
                    child: _coverImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _coverImage!,
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
                                size: 50,
                                color: primaryColor.withValues(alpha: 0.7),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap to select cover image',
                                style: TextStyle(color: primaryColor),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Mountain Name
              AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 600),
                child: CustomTextField(
                  controller: _mountainNameController,
                  labelText: 'Mountain Name',
                  hintText: 'e.g., Everest Base Camp',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter mountain name';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),

              // Location
              AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 700),
                child: CustomTextField(
                  controller: _locationController,
                  labelText: 'Location',
                  hintText: 'e.g., Nepal',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter location';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),

              // Difficulty
              AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 800),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedDifficulty,
                  decoration: InputDecoration(
                    labelText: 'Difficulty',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.terrain, color: primaryColor),
                  ),
                  items: _difficulties.map((String difficulty) {
                    return DropdownMenuItem<String>(
                      value: difficulty,
                      child: Text(difficulty),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedDifficulty = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select difficulty';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),

              // Start Date
              AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 900),
                child: TextFormField(
                  controller: _startDateController,
                  decoration: InputDecoration(
                    labelText: 'Start Date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context, true),
                    ),
                    prefixIcon: Icon(Icons.date_range, color: primaryColor),
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select start date';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),

              // End Date
              AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 1000),
                child: TextFormField(
                  controller: _endDateController,
                  decoration: InputDecoration(
                    labelText: 'End Date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context, false),
                    ),
                    prefixIcon: Icon(Icons.date_range, color: primaryColor),
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select end date';
                    }
                    if (_startDate != null &&
                        _endDate != null &&
                        _endDate!.isBefore(_startDate!)) {
                      return 'End date must be after start date';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),

              // Start Time
              AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 1100),
                child: TextFormField(
                  controller: _startTimeController,
                  decoration: InputDecoration(
                    labelText: 'Start Time',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.access_time),
                      onPressed: () => _selectTime(context, true),
                    ),
                    prefixIcon: Icon(Icons.schedule, color: primaryColor),
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select start time';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),

              // End Time
              AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 1200),
                child: TextFormField(
                  controller: _endTimeController,
                  decoration: InputDecoration(
                    labelText: 'End Time',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.access_time),
                      onPressed: () => _selectTime(context, false),
                    ),
                    prefixIcon: Icon(Icons.schedule, color: primaryColor),
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select end time';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),

              // Description
              AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 1300),
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe the trek',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.description, color: primaryColor),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),

              // Essentials
              AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 1200),
                child: TextFormField(
                  controller: _essentialsController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Essentials to Carry',
                    hintText: 'e.g., Water bottle, snacks, etc.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.backpack, color: primaryColor),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter essentials';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),

              // Cost
              AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 1300),
                child: CustomTextField(
                  controller: _costController,
                  labelText: 'Cost (₹)',
                  hintText: 'e.g., 2000',
                  keyboardType: TextInputType.number,
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
              SizedBox(height: 16),

              // Company Name
              AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 1400),
                child: CustomTextField(
                  controller: _companyNameController,
                  labelText: 'Company Name',
                  hintText: 'e.g., Adventure Co.',
                  enabled: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter company name';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),

              // Company Number
              AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 1500),
                child: CustomTextField(
                  controller: _companyNumberController,
                  labelText: 'Company Contact Number',
                  hintText: 'e.g., +91 9876543210',
                  keyboardType: TextInputType.phone,
                  enabled: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter company number';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 32),

              // Submit Button
              AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 1100),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  child: CustomButton(text: 'Add Trek', onPressed: _submitForm),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
