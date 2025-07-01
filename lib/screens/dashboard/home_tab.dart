
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_snackbar.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('iSMART学生助手'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: 导航到通知页面
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            onPressed: () {
              // TODO: 导航到聊天页面
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: 刷新数据
          await Future.delayed(const Duration(seconds: 1));
          if (context.mounted) {
            showCustomSnackBar(
              context: context, 
              message: '数据已更新',
              type: SnackBarType.success,
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 欢迎卡片
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                        child: Text(
                          user?.name.isNotEmpty == true 
                            ? user!.name.substring(0, 1).toUpperCase()
                            : 'S',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '你好，${user?.name ?? '同学'}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '今天是 ${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日 星期${_getWeekdayInChinese(DateTime.now().weekday)}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '努力学习，共创美好未来！',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 近期成绩
              _buildSectionTitle('近期成绩', '查看全部'),
              const SizedBox(height: 12),
              _buildRecentGradesCard(),
              const SizedBox(height: 24),

              // 课程推荐
              _buildSectionTitle('课程推荐', '更多推荐'),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return _buildCourseCard(index);
                  },
                ),
              ),
              const SizedBox(height: 24),

              // 最新资讯
              _buildSectionTitle('最新资讯', '查看更多'),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return _buildNewsItem(index);
                },
              ),
              const SizedBox(height: 24),

              // 学习工具
              _buildSectionTitle('学习工具', ''),
              const SizedBox(height: 12),
              _buildToolsGrid(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // 构建章节标题
  Widget _buildSectionTitle(String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (actionText.isNotEmpty)
          TextButton(
            onPressed: () {
              // TODO: 导航到对应页面
            },
            child: Text(actionText),
          ),
      ],
    );
  }

  // 近期成绩卡片
  Widget _buildRecentGradesCard() {
    // 模拟成绩数据
    final grades = [
      {'subject': '数学', 'score': 92, 'grade': 'A'},
      {'subject': '语文', 'score': 88, 'grade': 'B+'},
      {'subject': '英语', 'score': 95, 'grade': 'A+'},
      {'subject': '物理', 'score': 86, 'grade': 'B+'},
    ];

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(grades.length, (index) {
          final grade = grades[index];
          return ListTile(
            title: Text(grade['subject'] as String),
            subtitle: Text('得分: ${grade['score']}'),
            trailing: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _getGradeColor(grade['grade'] as String),
                shape: BoxShape.circle,
              ),
              child: Text(
                grade['grade'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              // TODO: 显示成绩详情
            },
          );
        }),
      ),
    );
  }

  // 课程卡片
  Widget _buildCourseCard(int index) {
    // 模拟课程数据
    final courses = [
      {'name': '高等数学提高班', 'teacher': '李教授', 'level': '高级', 'color': Colors.blue},
      {'name': '英语口语强化', 'teacher': '王教授', 'level': '中级', 'color': Colors.green},
      {'name': '物理实验专题', 'teacher': '张教授', 'level': '中级', 'color': Colors.orange},
      {'name': '编程入门与实践', 'teacher': '陈教授', 'level': '初级', 'color': Colors.purple},
      {'name': '创新思维训练', 'teacher': '赵教授', 'level': '高级', 'color': Colors.red},
    ];

    final course = index < courses.length ? courses[index] : courses[0];

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: course['color'] as Color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.school,
                color: Colors.white,
                size: 40,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['name'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '讲师: ${course['teacher']}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (course['color'] as Color).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      course['level'] as String,
                      style: TextStyle(
                        color: course['color'] as Color,
                        fontSize: 10,
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

  // 新闻项目
  Widget _buildNewsItem(int index) {
    // 模拟新闻数据
    final news = [
      {
        'title': '关于举办2024年春季校园招聘会的通知',
        'time': '2024-03-15',
        'type': '通知',
      },
      {
        'title': '学校图书馆新增电子资源使用指南',
        'time': '2024-03-10',
        'type': '公告',
      },
      {
        'title': '2024年暑期国际交流项目申请开始',
        'time': '2024-03-05',
        'type': '活动',
      },
    ];

    final item = index < news.length ? news[index] : news[0];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          item['title'] as String,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(item['time'] as String),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getNewsTypeColor(item['type'] as String).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Icon(
            _getNewsTypeIcon(item['type'] as String),
            color: _getNewsTypeColor(item['type'] as String),
            size: 20,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: 导航到新闻详情页面
        },
      ),
    );
  }

  // 工具网格
  Widget _buildToolsGrid() {
    final tools = [
      {'name': '课程表', 'icon': Icons.calendar_today, 'color': Colors.blue},
      {'name': '作业', 'icon': Icons.assignment, 'color': Colors.green},
      {'name': '图书馆', 'icon': Icons.menu_book, 'color': Colors.orange},
      {'name': '校历', 'icon': Icons.event, 'color': Colors.purple},
      {'name': '校园地图', 'icon': Icons.map, 'color': Colors.red},
      {'name': '服务中心', 'icon': Icons.help_center, 'color': Colors.teal},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];

        return InkWell(
          onTap: () {
            // TODO: 导航到相应工具页面
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: tool['color'] as Color? ?? Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  tool['icon'] as IconData,
                  color: tool['color'] as Color? ?? Colors.blue,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  tool['name'] as String,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 获取星期几（中文）
  String _getWeekdayInChinese(int weekday) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return weekdays[weekday - 1];
  }

  // 获取成绩颜色
  Color _getGradeColor(String grade) {
    if (grade.startsWith('A')) {
      return Colors.green;
    } else if (grade.startsWith('B')) {
      return Colors.blue;
    } else if (grade.startsWith('C')) {
      return Colors.orange;
    } else if (grade.startsWith('D')) {
      return Colors.deepOrange;
    } else {
      return Colors.red;
    }
  }

  // 获取新闻类型颜色
  Color _getNewsTypeColor(String type) {
    switch (type) {
      case '通知':
        return Colors.blue;
      case '公告':
        return Colors.orange;
      case '活动':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // 获取新闻类型图标
  IconData _getNewsTypeIcon(String type) {
    switch (type) {
      case '通知':
        return Icons.notification_important;
      case '公告':
        return Icons.campaign;
      case '活动':
        return Icons.event;
      default:
        return Icons.article;
    }
  }
}
