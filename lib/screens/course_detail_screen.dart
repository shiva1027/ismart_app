import 'package:flutter/material.dart';
import '../models/course_model.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key});

  @override
  _CourseDetailScreenState createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool _isEnrolled = false;

  @override
  Widget build(BuildContext context) {
    // Receive the course model from route arguments
    final CourseModel course =
        ModalRoute.of(context)!.settings.arguments as CourseModel;

    return Scaffold(
      appBar: AppBar(title: Text('Course Details'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Course image
            Container(
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(course.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Course details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          course.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          SizedBox(width: 4),
                          Text(
                            course.rating.toStringAsFixed(1),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  // Instructor
                  Row(
                    children: [
                      Icon(Icons.person, size: 20, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('Instructor: ${course.instructor}'),
                    ],
                  ),

                  SizedBox(height: 4),

                  // Duration
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 20, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('${course.durationInWeeks} weeks'),
                    ],
                  ),

                  SizedBox(height: 4),

                  // Enrolled students
                  Row(
                    children: [
                      Icon(Icons.people, size: 20, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('${course.enrolledCount} students enrolled'),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(course.description),

                  SizedBox(height: 24),

                  // Topics
                  Text(
                    'Topics Covered',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  ...course.topics.map(
                    (topic) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green,
                          ),
                          SizedBox(width: 8),
                          Expanded(child: Text(topic)),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 32),

                  // Enroll button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isEnrolled = !_isEnrolled;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _isEnrolled
                                  ? 'Successfully enrolled in ${course.title}'
                                  : 'Unenrolled from ${course.title}',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: _isEnrolled ? Colors.grey : null,
                      ),
                      child: Text(
                        _isEnrolled ? 'Unenroll' : 'Enroll Now',
                        style: TextStyle(fontSize: 16),
                      ),
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
