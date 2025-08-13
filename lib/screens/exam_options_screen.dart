import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ExamOptionsScreen extends StatelessWidget {
  final String examTitle;
  const ExamOptionsScreen({super.key, required this.examTitle});

  @override
  Widget build(BuildContext context) {
    final options = [
      {'title': 'Mock Test', 'icon': Icons.assignment},
      {'title': 'PYQ Test', 'icon': Icons.history_edu},
      {'title': 'PYQ Revision', 'icon': Icons.refresh},
    ];

    return Scaffold(
      appBar: AppBar(title: Text(examTitle), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: ListView.builder(
          itemCount: options.length,
          itemBuilder: (context, index) {
            final item = options[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 2.w),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(item['icon'] as IconData, size: 24.sp),
                title: Text(item['title']!, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item['title']} for $examTitle')),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
