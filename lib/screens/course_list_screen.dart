import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  _CourseListScreenState createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Courses'), elevation: 0),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search courses...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = "";
                            });
                          },
                        )
                        : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // 课程列表
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('courses').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No courses available'));
                }

                // 将数据转换为课程列表
                final courses =
                    snapshot.data!.docs.map((doc) {
                      return CourseModel.fromMap(
                        doc.id,
                        doc.data() as Map<String, dynamic>,
                      );
                    }).toList();

                // 根据搜索条件过滤课程
                final filteredCourses =
                    _searchQuery.isEmpty
                        ? courses
                        : courses
                            .where(
                              (course) =>
                                  course.title.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  ) ||
                                  course.instructor.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  ),
                            )
                            .toList();

                if (filteredCourses.isEmpty) {
                  return const Center(
                    child: Text('No courses match your search'),
                  );
                }

                // 显示课程列表
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredCourses.length,
                  itemBuilder: (context, index) {
                    final course = filteredCourses[index];
                    return CourseCard(course: course);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final CourseModel course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/course_detail', arguments: course);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 课程封面图片
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Image.network(
                course.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.error)),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 课程标题
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // 课程讲师
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        course.instructor,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // 课程时长
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${course.durationInWeeks} weeks',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 底部信息：评分和学生数量
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 评分
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            course.rating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      // 已注册学生数量
                      Text(
                        '${course.enrolledCount} students',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
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
