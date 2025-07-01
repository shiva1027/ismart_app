import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';
import '../models/course_model.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final _searchController = TextEditingController();
  final String _searchQuery = '';
  final List<String> _categories = ['全部', '编程', '设计', '商业', '语言', '科学'];
  String _selectedCategory = '全部';

  @override
  void initState() {
    super.initState();
    // 加载课程数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourseProvider>(context, listen: false).loadCourses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('课程列表'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CourseSearchDelegate(
                  Provider.of<CourseProvider>(context, listen: false),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 分类选项卡
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // 课程列表
          Expanded(
            child: Consumer<CourseProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '加载课程失败: ${provider.error}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.loadCourses(),
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  );
                }

                // 过滤课程
                List<CourseModel> filteredCourses = provider.courses;
                if (_selectedCategory != '全部') {
                  filteredCourses = provider.filterCoursesByCategory(
                    _selectedCategory,
                  );
                }

                if (_searchQuery.isNotEmpty) {
                  filteredCourses = provider.searchCourses(_searchQuery);
                }

                if (filteredCourses.isEmpty) {
                  return const Center(child: Text('没有找到符合条件的课程'));
                }

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/course_detail', arguments: course);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 课程封面图
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(course.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 课程标题和评分
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          course.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 讲师信息
                  Text(
                    '讲师: ${course.instructor}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  // 课程时长和学生数量
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${course.durationInWeeks} 周',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${course.enrolledCount} 学生已注册',
                        style: TextStyle(color: Colors.grey[600]),
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

// 课程搜索代理
class CourseSearchDelegate extends SearchDelegate<String> {
  final CourseProvider courseProvider;

  CourseSearchDelegate(this.courseProvider);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(child: Text('请输入搜索关键词'));
    }

    final results = courseProvider.searchCourses(query);

    if (results.isEmpty) {
      return const Center(child: Text('没有找到相关课程'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final course = results[index];
        return ListTile(
          title: Text(course.title),
          subtitle: Text(course.instructor),
          leading: CircleAvatar(backgroundImage: NetworkImage(course.imageUrl)),
          onTap: () {
            Navigator.pushNamed(context, '/course_detail', arguments: course);
            close(context, course.id);
          },
        );
      },
    );
  }
}
