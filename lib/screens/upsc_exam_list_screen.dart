import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class UpscExamListScreen extends StatelessWidget {
  const UpscExamListScreen({super.key});

  final List<Map<String, String>> exams = const [
    {'title': 'UPSC CSE', 'desc': 'Civil Services Exam (IAS, IPS, IFS)'},
    {'title': 'UPSC CDS', 'desc': 'Combined Defence Services'},
    {'title': 'UPSC NDA', 'desc': 'National Defence Academy'},
    {'title': 'UPSC CAPF', 'desc': 'Central Armed Police Forces'},
    {'title': 'UPSC IES', 'desc': 'Indian Engineering Services'},
    {'title': 'UPSC IFoS', 'desc': 'Indian Forest Service'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UPSC Exams'), centerTitle: true),
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
