import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants.dart';

class CompanyDetailsScreen extends StatefulWidget {
  const CompanyDetailsScreen({super.key});

  @override
  State<CompanyDetailsScreen> createState() => _CompanyDetailsScreenState();
}

class _CompanyDetailsScreenState extends State<CompanyDetailsScreen> {
  String? companyName;
  String? contactEmail;
  String? businessPhone;
  String? businessAddress;
  String? businessRegistrationNumber;
  String? aboutCompany;
  List<String>? businessDocuments;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompanyDetails();
  }

  Future<void> _loadCompanyDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      companyName = prefs.getString('company_name');
      contactEmail = prefs.getString('contact_email');
      businessPhone = prefs.getString('business_phone');
      businessAddress = prefs.getString('business_address');
      businessRegistrationNumber = prefs.getString(
        'business_registration_number',
      );
      aboutCompany = prefs.getString('about_company');
      businessDocuments = prefs.getStringList('business_documents');
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Company Details'),
        backgroundColor: primaryColor,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : companyName == null
          ? Center(
              child: Text(
                'No company has registered yet',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor,
                          primaryColor.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.business_center,
                          color: Colors.white,
                          size: 40,
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            companyName ?? 'Company Name',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Company Information',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildDetailCard(
                    'Company Name',
                    companyName ?? 'Not set',
                    Icons.business,
                  ),
                  _buildDetailCard(
                    'Contact Email',
                    contactEmail ?? 'Not set',
                    Icons.email,
                  ),
                  _buildDetailCard(
                    'Business Phone',
                    businessPhone ?? 'Not set',
                    Icons.phone,
                  ),
                  _buildDetailCard(
                    'Business Address',
                    businessAddress ?? 'Not set',
                    Icons.location_on,
                  ),
                  _buildDetailCard(
                    'Registration Number',
                    businessRegistrationNumber ?? 'Not set',
                    Icons.confirmation_number,
                  ),
                  _buildDetailCard(
                    'About Company',
                    aboutCompany ?? 'Not set',
                    Icons.info,
                  ),
                  if (businessDocuments != null &&
                      businessDocuments!.isNotEmpty) ...[
                    SizedBox(height: 20),
                    Text(
                      'Business Documents',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    ...businessDocuments!.map(
                      (doc) => ListTile(
                        leading: Icon(Icons.file_present, color: primaryColor),
                        title: Text('Document: ${doc.split('/').last}'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon) {
    return Card(
      elevation: 6,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      shadowColor: primaryColor.withValues(alpha: 0.2),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: primaryColor, size: 28),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
