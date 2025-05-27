import 'package:flutter/material.dart';
import '../../controllers/admin/user_controller.dart';
import '../../models/admin/user_model.dart';

class UserListView extends StatelessWidget {
  final UserController _userController = UserController();

  UserListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Danh sách người dùng',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222B45),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddUserDialog(context),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Thêm', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<UserModel>>(
                stream: _userController.getUsers(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Có lỗi xảy ra'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Không có người dùng nào'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final user = snapshot.data![index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.green[100],
                            child: Icon(Icons.person, color: Colors.green[700], size: 32),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: Color(0xFF222B45),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: user.role == UserRole.admin ? Colors.blue[100] : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  user.role == UserRole.admin ? 'Quản trị viên' : 'Người dùng',
                                  style: TextStyle(
                                    color: user.role == UserRole.admin ? Colors.blue : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF8F9BB3),
                                ),
                              ),
                              if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
                                Text(
                                  user.phoneNumber!,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF8F9BB3),
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                tooltip: 'Sửa',
                                onPressed: () => _showEditUserDialog(context, user),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                tooltip: 'Xóa',
                                onPressed: () => _showDeleteConfirmation(context, user.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneNumberController = TextEditingController();
    UserRole role = UserRole.customer;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm người dùng mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên người dùng',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<UserRole>(
                value: role,
                decoration: const InputDecoration(
                  labelText: 'Vai trò',
                ),
                items: [
                  DropdownMenuItem(
                    value: UserRole.admin,
                    child: Text('Quản trị viên'),
                  ),
                  DropdownMenuItem(
                    value: UserRole.customer,
                    child: Text('Người dùng'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    role = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final user = UserModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  email: emailController.text,
                  phoneNumber: phoneNumberController.text,
                  role: role,
                );
                await _userController.addUser(user);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã thêm người dùng thành công')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi khi thêm người dùng: $e')),
                  );
                }
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, UserModel user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    UserRole role = user.role;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa người dùng'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên người dùng',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                enabled: false, // Email không thể thay đổi
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<UserRole>(
                value: role,
                decoration: const InputDecoration(
                  labelText: 'Vai trò',
                ),
                items: [
                  DropdownMenuItem(
                    value: UserRole.admin,
                    child: Text('Quản trị viên'),
                  ),
                  DropdownMenuItem(
                    value: UserRole.customer,
                    child: Text('Người dùng'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    role = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              final updatedUser = user.copyWith(
                name: nameController.text,
                role: role,
              );
              try {
                await _userController.updateUser(updatedUser);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã cập nhật người dùng thành công')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi khi cập nhật người dùng: $e')),
                  );
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa người dùng này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _userController.deleteUser(userId);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xóa người dùng thành công')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi khi xóa người dùng: $e')),
                  );
                }
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
} 