import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SkillDetailsPage extends StatefulWidget {
  final String skillData;
  final int? employeeSkillTestId;
  const SkillDetailsPage({Key? key, required this.skillData, this.employeeSkillTestId}) : super(key: key);


  @override
  State<SkillDetailsPage> createState() => _SkillDetailsPageState();
}

class _SkillDetailsPageState extends State<SkillDetailsPage> {
  Map<String, dynamic>? _skillDetails;
  Map<int, TextEditingController> _gradeControllers = {}; // Store grade controllers for each skill

  @override
  void initState() {
    super.initState();
    _parseSkillData();
  }

  void _parseSkillData() {
    try {
      final decodedData = utf8.decode(widget.skillData.codeUnits); // Decode as UTF-8
      _skillDetails = jsonDecode(decodedData);

      // Initialize grade controllers for each skill
      if (_skillDetails != null && _skillDetails!['skills'] != null) {
        for (var skill in _skillDetails!['skills'] as List<dynamic>) {
          _gradeControllers[skill['id']] = TextEditingController();
        }
      }
    } catch (error) {
      print('Error parsing skill data: $error');
      // Handle error, e.g., show an error message to the user
    }
  }

  @override
  void dispose() {
    // Dispose grade controllers to prevent memory leaks
    for (var controller in _gradeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Center(child: Text(' المهارات',style: TextStyle(color: Colors.white),)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _skillDetails == null
                ? const Center(child: CircularProgressIndicator())
                : Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: (_skillDetails?['skills'] as List<dynamic>)
                      ?.map((skill) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 2, // Allocate more space to the text
                                child: Text(
                                  skill['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5), // Add space between text and input
                              Expanded(
                                flex: 1, // Allocate less space to the input field
                                child: TextField(
                                  controller: _gradeControllers[skill['id']],
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.blue.shade50,
                                    hintText: '---',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 8,
                                    ),
                                  ),
                                ),

                              ),

                            ],

                          ),
                        ),
                        const Divider(), // Add a divider line below each skill item
                      ],
                    );
                  }).toList() ??
                      [],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
                minimumSize: const Size(double.infinity, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                // Validate input fields
                final emptySkillIds = <dynamic>[];
                _gradeControllers.forEach((skillId, controller) {
                  if (controller.text.isEmpty) {
                    emptySkillIds.add(skillId);
                  }
                });

                if (emptySkillIds.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                          'الرجاء إدخال درجة المهارات التالية:'),
                    ),
                  );
                  return;
                }

                try {
                  final skillGrades = _gradeControllers.entries.map((entry) {
                    return {
                      'skill': entry.key,
                      'grade': int.parse(entry.value.text),
                    };
                  }).toList();

                  final requestData = {
                    'skill_grade': skillGrades,
                    'employee_skill_test': widget.employeeSkillTestId,
                  };

                  final response = await http.post(
                    Uri.parse(
                        'https://employee-skill.onrender.com/employee/skill/submit/test/'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode(requestData),
                  );

                  if (response.statusCode == 201) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('تم إرسال البيانات بنجاح'),
                      ),
                    );
                    Navigator.pop(context);
                  } else {
                    print('Error sending data: ${response.statusCode}');
                  }
                } catch (error) {
                  print('Error sending data: $error');
                }
              },
              child: const Text(
                'ارسال النتائج',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}