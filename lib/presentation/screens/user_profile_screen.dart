import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../data/models/user.dart';

class UserProfileScreen extends StatefulWidget {
  final User currentUser;
  const UserProfileScreen({super.key, required this.currentUser});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 8),
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(widget.currentUser.avatarUrl),
        ),
        const SizedBox(height: 16),
        Text(
          'Tên người dùng',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        ListTile(
          leading: Icon(Icons.edit),
          title: Text('Chỉnh sửa thông tin'),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.color_lens),
          title: Text('Chủ đề giao diện'),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.logout),
          title: Text('Đăng xuất'),
          onTap: () {},
        ),
      ],
    );
  }
}
