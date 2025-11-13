import 'package:flutter/material.dart';

class FilterOption extends StatelessWidget {
  final String title;

  const FilterOption({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF6A1B9A).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Color(0xFF6A1B9A),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6A1B9A),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF6A1B9A).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Color(0xFF6A1B9A),
          ),
        ),
      ),
    );
  }
}
