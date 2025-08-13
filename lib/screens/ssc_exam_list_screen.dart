import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SscExamListScreen extends StatelessWidget {
  const SscExamListScreen({super.key});

  final List<Map<String, String>> exams = const [
    {'title': 'SSC CGL', 'desc': 'Graduate level exam for Group B & C posts'},
    {'title': 'SSC CHSL', 'desc': '12th pass exam for LDC, DEO, PA/SA'},
    {'title': 'SSC MTS', 'desc': 'Non-technical staff recruitment'},
    {'title': 'SSC CPO', 'desc': 'Sub-Inspector in Delhi Police & CAPFs'},
    {'title': 'SSC GD Constable', 'desc': 'Constables in paramilitary forces'},
    {'title': 'SSC JE', 'desc': 'Junior Engineer (Civil, Mech, Electrical)'},
    {'title': 'SSC Stenographer', 'desc': 'Grade C & D stenographer posts'},
    {'title': 'SSC JHT', 'desc': 'Junior Hindi Translator recruitment'},
    {'title': 'SSC Selection Posts', 'desc': 'Direct recruitment in ministries'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SSC Exams'),
        centerTitle: true,
      ),
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
              title: Text(
                exam['title']!,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                exam['desc']!,
                style: TextStyle(fontSize: 11.sp),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Navigate to syllabus or AI doubt screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${exam['title']} tapped')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
