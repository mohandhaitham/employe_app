
import 'package:employe_app/skillpage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SkillPage extends StatefulWidget {
  @override
  _SkillPageState createState() => _SkillPageState();
}

class _SkillPageState extends State<SkillPage> {
  String? _selectedEmployee;
  List<Map<String, dynamic>> _employees = [];
  String? _selectedCategory;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int? _employeeDetailsId;
  int? employeeSkillTestId;

  // Future<void> _submitData() async {
  //   // Request 1: Employee and Skill Category
  //   final url1 = Uri.parse('https://employee-skill.onrender.com/employee/skill/generate/test/');
  //   final headers1 = {'Content-Type': 'application/json'};
  //   final body1 = jsonEncode({
  //     'id': 0, // You might need to change this based on your API requirements
  //     'employee': int.parse(_selectedEmployee!),
  //     'skill_category': int.parse(_selectedCategory!),
  //   });
  //
  //   // Request 2: Email and Phone Number
  //   final url2 = Uri.parse('https://employee-skill.onrender.com/employee/test/details/');
  //   final headers2 = {'Content-Type': 'application/json'};
  //   final body2 = jsonEncode({
  //     'id': 0, // Replace with the actual ID if needed
  //     'employee_details': int.parse(_selectedEmployee!), // Replace with the actual employee details ID if needed
  //     'email': _emailController.text,
  //     'phone_number': _phoneController.text,
  //   });
  //
  //   try {
  //     // Send Request 1
  //     final response1 = await http.post(url1, headers: headers1, body: body1);
  //     if (response1.statusCode == 201) {
  //       print('Request 1 submitted successfully');
  //     } else {
  //       print('Error submitting Request 1: ${response1.statusCode}');
  //     }
  //
  //     // Send Request 2
  //     final response2 = await http.post(url2, headers: headers2, body: body2);
  //     if (response2.statusCode == 201) {
  //       print('Request 2 submitted successfully');
  //     } else {
  //       print('Error submitting Request 2: ${response2.statusCode}');
  //     }
  //
  //     if (response1.statusCode == 201 && response2.statusCode == 201) {
  //       // Get the skill test ID (assuming it's returned in the response body)
  //       final skillTestId = response1.body; // or response1.headers['skill_test_id'] or similar
  //
  //       // Navigate to SkillDetailsPage
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => SkillDetailsPage(skillTestId: int.parse(skillTestId)),
  //         ),
  //       );
  //     }
  //     // You can show a success message to the user here if both requests are successful
  //   } catch (error) {
  //     print('Error submitting data: $error');
  //     // You can show an error message to the user here
  //   }
  //
  // }
  // Fetch employee data from the API
  Future<void> _fetchEmployees() async {
    try {
      final response = await http.get(
        Uri.parse('https://employee-skill.onrender.com/employee/list/'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _employees = data
              .map((e) => {
            "id": e["id"],
            "employee_name": e["employee_name"],
          })
              .toList();
          _isLoading = false;
          print('Data loaded successfully, _isLoading set to false'); // Added check
        });
      } else {
        throw Exception('Failed to load employees');
      }
    } catch (error) {
      print('Error fetching employees: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }
  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(

        Uri.parse('https://employee-skill.onrender.com/skill-category/'),

        headers: {'Accept-Charset': 'utf-8'}, // Add this line
    );
      if (response.statusCode == 200) {
        final decodedData = utf8.decode(response.bodyBytes);
        final jsonData = jsonDecode(decodedData); // Use the decoded data
        setState(() {
          _categories = jsonData.cast<Map<String, dynamic>>();
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (error) {
      print('Error fetching categories: $error');
    }
  }
  Future<void> _submitEmployeeDetails() async {
    final url = Uri.parse('https://employee-skill.onrender.com/employee/test/details/');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'employee_details': int.parse(_selectedEmployee!), // Use selected employee ID
      'email': _emailController.text,
      'phone_number': _phoneController.text,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        print('Employee details submitted successfully');
        final responseData = jsonDecode(response.body);
        final employeeDetailsId = responseData['id'];

        print('Employee details ID: $employeeDetailsId');
        setState(() {
          _employeeDetailsId = employeeDetailsId;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Employee details submitted successfully!')),
          );
        });

        // You can perform any actions after successful submission, like navigating to another screen
      } else {
        print('Error submitting employee details: ${response.statusCode}');
        // Handle error, e.g., show an error message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting employee details: ${response.statusCode}')),
        );
      }
    } catch (error) {
      print('Error submitting employee details: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting employee details: $error')),
      );
      // Handle error, e.g., show an error message to the user
    }
  }
  Future<void> _submitSkillData(int employeeDetailsId, int categoryId) async {
    final url = Uri.parse('https://employee-skill.onrender.com/employee/skill/generate/test/');
    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode({
      'id': 0,
      'employee': employeeDetailsId,
      'skill_category': categoryId,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print(response.body);
        print('Skill data submitted successfully');
        final responseData = jsonDecode(response.body);
        employeeSkillTestId = responseData['id'];
        // Navigate to SkillDetailsPage with FutureBuilder
        // In _submitSkillData function:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SkillDetailsPage(skillData: response.body, employeeSkillTestId: employeeSkillTestId),
          ),
        );
      } else {
        print('Error submitting skill data: ${response.statusCode}');
        // Handle error, e.g., show an error message to the user
      }
    } catch (error) {
      print('Error submitting skill data: $error');
      // Handle error, e.g., show an error message to the user
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchEmployees();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Center(child: Text('تطبيق المهارات',style: TextStyle(color: Colors.white),)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
        
            child: Form(
              key: _formKey,

              child: Column(
              
                children: [
              
              
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade600, Colors.blue.shade300],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      color: Colors.transparent, // Make the card's background transparent
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Dropdown
                              Text(
                                'اسم الموظف',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              SizedBox(height: 8),
                                _isLoading
                                  ? Center(child: CircularProgressIndicator())
                                  : DropdownButtonFormField<String>(
                                value: _selectedEmployee,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                  validator: (value) { // Add validator
                                    if (value == null || value.isEmpty) {
                                      return 'اختر اسم الموظف';
                                    }
                                    return null;
                                  },
                                items: _employees
                                    .map(
                                      (employee) => DropdownMenuItem<String>(
                                    value: employee['id'].toString(),
                                    child: Text(employee['employee_name']),
                                  ),
                                )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedEmployee = value;
                                  });
                                },
                              ),
                              SizedBox(height: 16),
                              // First Input
                              Text(
                                'البريد اللاكتروني',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController, // Add controller for email
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                validator: (value) { // Add email validator
                                  if (value == null || value.isEmpty) {
                                    return 'يرجا ادخال البريد الاكتروني';
                                  }
                                  if (!value.contains('@')) {
                                    return 'يرجا ادخال بريد الكتروني صالح';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              // Second Input
                              Text(
                                'رقم الهاتف',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _phoneController, // Add controller for phone number
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                validator: (value) { // Add phone number validator
                                  if (value == null || value.isEmpty) {
                                    return 'ادخل رقم هاتف';
                                  }
                                  if (!RegExp(r'^\+964[0-9]{10}$').hasMatch(value)) {
                                    return 'يرجا ادخال رقم هاتف صالح +964';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),

                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) { // Validate form
                                      _submitEmployeeDetails(); // Call the new function to submit data
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('تم تنفيذ الإجراء بنجاح!'),
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                    'ارسال المعلومات',
                                    style: TextStyle(fontSize: 16,),

                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    ),

                  ),
              
                  SizedBox(height: 20,),
                      //card 2
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade600, Colors.blue.shade300],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Card(
                      color: Colors.transparent, // Make the card's background transparent
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Dropdown
                              Center(
                                child: Text(
                                  'اختر المصفوفة',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white,),
                                ),
                              ),
                              SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedCategory,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.blue.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                validator: (value) { // Add validator
                                  if (value == null || value.isEmpty) {
                                    return 'اختر مصفوقة';
                                  }
                                  return null;
                                },
                                items: _categories.map((category) {
                                  return DropdownMenuItem<String>(
                                    value: category['id'].toString(), // Use 'id' as value
                                    child: Text(category['name']), // Use 'name' as displayed text
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                },
                              ),
                              SizedBox(height: 16),
                              // First Input
              
                              SizedBox(height: 16),
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                  ),
                                  onPressed: () {
                                    if (_employeeDetailsId != null && _selectedCategory != null) {
                                      _submitSkillData(_employeeDetailsId!, int.parse(_selectedCategory!));
                                    } else {
                                      // Handle case where employee details ID or category ID is not available
                                      // e.g., show an error message to the user
                                    }
                                  },
                                  child: Text(
                                    'ارسال المصفوفة', // Or any label you prefer
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        
        
        ),
      ),
    );
  }
}