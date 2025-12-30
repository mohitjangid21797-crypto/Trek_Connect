import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants.dart';
import '../../../shared_widgets/custom_text_field.dart';
import '../../../shared_widgets/custom_button.dart';
import '../../dashboard/screens/combine_dashboard.dart';

class RegisterCompany extends StatefulWidget {
  const RegisterCompany({super.key});

  @override
  State<RegisterCompany> createState() => _RegisterCompanyState();
}

class _RegisterCompanyState extends State<RegisterCompany>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _buttonAnimationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, -1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();

    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
  }

  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _businessRegistrationNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _aboutCompanyController = TextEditingController();
  final List<File> _businessDocuments = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickDocument() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _businessDocuments.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _registerCompany() async {
    if (_formKey.currentState!.validate() && _businessDocuments.isNotEmpty) {
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('company_name', _companyNameController.text);
      await prefs.setString('contact_email', _contactEmailController.text);
      await prefs.setString('business_phone', _businessPhoneController.text);
      await prefs.setString(
        'business_address',
        _businessAddressController.text,
      );
      await prefs.setString(
        'business_registration_number',
        _businessRegistrationNumberController.text,
      );
      await prefs.setString('password', _passwordController.text);
      await prefs.setString('about_company', _aboutCompanyController.text);
      await prefs.setStringList(
        'business_documents',
        _businessDocuments.map((file) => file.path).toList(),
      );

      // Navigate to dashboard
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Company registered successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CombinedDashboard()),
        );
      }
    } else if (_businessDocuments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please upload at least one business document.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Company'),
        backgroundColor: primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/valley_flowers.jpg'),
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(defaultPadding),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(defaultBorderRadius),
            ),
            child: Padding(
              padding: EdgeInsets.all(defaultPadding),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SlideTransition(
                        position: _slideAnimation,
                        child: Text(
                          'Company Registration',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      CustomTextField(
                        controller: _companyNameController,
                        labelText: 'Company Name',
                        prefixIcon: Icons.business,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter company name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        controller: _contactEmailController,
                        labelText: 'Contact Email',
                        prefixIcon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter contact email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        controller: _businessPhoneController,
                        labelText: 'Business Phone',
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter business phone';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        controller: _businessAddressController,
                        labelText: 'Business Address',
                        prefixIcon: Icons.location_on,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter business address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        controller: _businessRegistrationNumberController,
                        labelText: 'Business Registration Number',
                        prefixIcon: Icons.numbers,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter business registration number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        controller: _aboutCompanyController,
                        labelText: 'About your Company',
                        prefixIcon: Icons.info,
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter about your company';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Business Documents',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: _pickDocument,
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(
                              defaultBorderRadius,
                            ),
                            color: Colors.grey[200],
                          ),
                          child: _businessDocuments.isNotEmpty
                              ? Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: _businessDocuments.map((file) {
                                      return Stack(
                                        children: [
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundImage: FileImage(file),
                                          ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _businessDocuments.remove(
                                                    file,
                                                  );
                                                });
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.close,
                                                  size: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                )
                              : Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.upload_file,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Tap to upload documents',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 30),
                      CustomButton(
                        text: 'Register',
                        onPressed: _registerCompany,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _buttonAnimationController.dispose();
    _companyNameController.dispose();
    _contactEmailController.dispose();
    _businessPhoneController.dispose();
    _businessAddressController.dispose();
    _businessRegistrationNumberController.dispose();
    _passwordController.dispose();
    _aboutCompanyController.dispose();
    super.dispose();
  }
}
