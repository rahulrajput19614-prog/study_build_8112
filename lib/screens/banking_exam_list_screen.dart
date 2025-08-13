import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class BankingExamListScreen extends StatelessWidget {
  const BankingExamListScreen({super.key});

  final List<Map<String, String>> exams = const [
    {'title': 'IBPS PO', 'desc': 'Probationary Officer in public sector banks'},
    {'title': 'IBPS Clerk', 'desc': 'Clerical posts in banks'},
    {'title': 'IBPS SO', 'desc': 'Specialist Officer (IT, HR, Law, etc.)'},
    {'title': 'SBI PO', 'desc': 'Probationary Officer in SBI'},
    {'title': 'SBI Clerk', 'desc': 'Junior Associate in SBI'},
    {'title': 'RBI Grade B', 'desc': 'Officer post in Reserve Bank of India'},
    {'title': 'RBI Assistant', 'desc': 'Assistant post in RBI'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Banking Exams'), centerTitle: true),
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
