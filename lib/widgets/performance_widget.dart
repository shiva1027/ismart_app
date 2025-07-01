import 'package:flutter/material.dart';

class PerformanceWidget extends StatelessWidget {
  final String level;
  final List<String> suggestedCourses;

  const PerformanceWidget({
    required this.level,
    required this.suggestedCourses,
    super.key,
  });

  Color _getLevelColor() {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.blue;
      case 'advanced':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getLevelColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getLevelColor(),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Level: $level',
                    style: TextStyle(
                      color: _getLevelColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Performance Level'),
                        content: Text(
                          'Your current level is $level. Complete the suggested courses to advance to the next level.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Recommended Courses:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (suggestedCourses.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'No courses recommended at this time.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              )
            else
              ...suggestedCourses.map((course) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getLevelColor().withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.school,
                        color: _getLevelColor(),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      course,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Navigate to course details
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening course: $course'),
                          action: SnackBarAction(
                            label: 'Dismiss',
                            onPressed: () {},
                          ),
                        ),
                      );
                    },
                  )),
          ],
        ),
      ),
    );
  }
}
