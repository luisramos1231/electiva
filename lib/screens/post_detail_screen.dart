import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../models/comment.dart';
import '../services/api_service.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final ApiService _api = ApiService();
  late Future<Map<String, dynamic>> _data;

  final List<Color> _palette = const [
    Color(0xFFFF6B6B),
    Color(0xFFFFBE0B),
    Color(0xFF06D6A0),
    Color(0xFF118AB2),
    Color(0xFFFF9F1C),
  ];

  @override
  void initState() {
    super.initState();
    _data = _loadData();
  }

  Future<Map<String, dynamic>> _loadData() async {
    final results = await Future.wait([
      _api.getUser(widget.post.userId),
      _api.getComments(widget.post.id),
    ]);
    return {
      'user': results[0] as User,
      'comments': results[1] as List<Comment>,
    };
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _palette[widget.post.userId % _palette.length];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: accentColor,
        title: const Text('Detalle', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: accentColor));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}'));
          }

          final user = snapshot.data!['user'] as User;
          final comments = snapshot.data!['comments'] as List<Comment>;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border(top: BorderSide(color: accentColor, width: 4)),
                  boxShadow: [
                    BoxShadow(color: accentColor.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.post.body,
                      style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.7),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text('Autor', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: accentColor, letterSpacing: 0.5)),
              ),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: accentColor.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: accentColor,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text(user.email, style: TextStyle(fontSize: 12, color: accentColor)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 12, color: Colors.black38),
                            const SizedBox(width: 2),
                            Text(user.city, style: const TextStyle(fontSize: 12, color: Colors.black38)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text('Comentarios (${comments.length})', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: accentColor, letterSpacing: 0.5)),
              ),
              ...comments.asMap().entries.map((entry) {
                final i = entry.key;
                final c = entry.value;
                final cColor = _palette[i % _palette.length];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: cColor.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: cColor.withOpacity(0.15),
                            child: Text(
                              c.name.isNotEmpty ? c.name[0].toUpperCase() : 'C',
                              style: TextStyle(color: cColor, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(c.email, style: TextStyle(fontSize: 11, color: cColor)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(c.body, style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.5)),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
