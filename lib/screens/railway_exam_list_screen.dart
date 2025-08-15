import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'exam_options_screen.dart'; // ✅ Import the options screen

class RailwayExamListScreen extends StatelessWidget {
  const RailwayExamListScreen({super.key});

  final List<Map<String, String>> exams = const [
    {'title': 'RRB NTPC', 'desc': 'Non-Technical Popular Categories'},
    {'title': 'RRB Group D', 'desc': 'Level 1 posts in Indian Railways'},
    {'title': 'RRB ALP', 'desc': 'Assistant Loco Pilot'},
    {'title': 'RRB JE', 'desc': 'Junior Engineer (Civil, Mech, Electrical)'},
    {'title': 'RRB Technician', 'desc': 'Technical posts in Railways'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Railway Exams'), centerTitle: true),
      body: ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: exams.length,
        itemBuilder: (context, index) {
          final exam = exams[index];
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 2.w),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: Text(exam['title']!, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
              subtitle: Text(exam['desc']!, style: TextStyle(fontSize: 11.sp)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExamOptionsScreen(examTitle: exam['title']!),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
