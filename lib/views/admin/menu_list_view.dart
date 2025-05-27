import 'package:flutter/material.dart';
import '../../controllers/admin/menu_controller.dart';
import '../../models/admin/menu_item_model.dart';

class MenuListView extends StatelessWidget {
  static final MenuItemController _menuController = MenuItemController();

  const MenuListView({super.key});

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
                    'Quản lý thực đơn',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222B45),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm món ăn...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onChanged: (value) {
                            // TODO: Implement search functionality
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => _showAddMenuItemDialog(context),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Thêm', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<MenuItemModel>>(
                stream: _menuController.getMenuItems(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Có lỗi xảy ra'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Không có món ăn nào'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final menuItem = snapshot.data![index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              menuItem.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.restaurant, size: 32),
                                );
                              },
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                menuItem.name,
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
                                  color: _getCategoryColor(menuItem.category).shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getCategoryText(menuItem.category),
                                  style: TextStyle(
                                    color: _getCategoryColor(menuItem.category).shade700,
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
                                menuItem.description,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF8F9BB3),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    _formatCurrency(menuItem.price),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: menuItem.isAvailable ? Colors.green[100] : Colors.red[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      menuItem.isAvailable ? 'Còn bán' : 'Hết món',
                                      style: TextStyle(
                                        color: menuItem.isAvailable ? Colors.green[700] : Colors.red[700],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                tooltip: 'Sửa',
                                onPressed: () => _showEditMenuItemDialog(context, menuItem),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                tooltip: 'Xóa',
                                onPressed: () => _showDeleteConfirmation(context, menuItem.menuItemId),
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

  void _showAddMenuItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final imageUrlController = TextEditingController();
    MenuCategory category = MenuCategory.mainCourse;
    bool isAvailable = true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm món ăn mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên món ăn',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Giá bán',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL ảnh',
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<MenuCategory>(
                value: category,
                decoration: const InputDecoration(
                  labelText: 'Danh mục',
                ),
                items: [
                  DropdownMenuItem(
                    value: MenuCategory.mainCourse,
                    child: Text('Món chính'),
                  ),
                  DropdownMenuItem(
                    value: MenuCategory.appetizer,
                    child: Text('Khai vị'),
                  ),
                  DropdownMenuItem(
                    value: MenuCategory.dessert,
                    child: Text('Tráng miệng'),
                  ),
                  DropdownMenuItem(
                    value: MenuCategory.beverage,
                    child: Text('Nước uống'),
                  ),
                  DropdownMenuItem(
                    value: MenuCategory.other,
                    child: Text('Khác'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    category = value;
                  }
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Còn bán'),
                value: isAvailable,
                onChanged: (value) {
                  isAvailable = value;
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
                final menuItem = MenuItemModel(
                  menuItemId: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  description: descriptionController.text,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  category: category,
                  isAvailable: isAvailable,
                  imageUrl: imageUrlController.text,
                );
                await _menuController.addMenuItem(menuItem);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã thêm món ăn thành công')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi khi thêm món ăn: $e')),
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

  void _showEditMenuItemDialog(BuildContext context, MenuItemModel menuItem) {
    final nameController = TextEditingController(text: menuItem.name);
    final descriptionController = TextEditingController(text: menuItem.description);
    final priceController = TextEditingController(text: menuItem.price.toString());
    final imageUrlController = TextEditingController(text: menuItem.imageUrl);
    MenuCategory category = menuItem.category;
    bool isAvailable = menuItem.isAvailable;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa món ăn'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên món ăn',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Giá bán',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL ảnh',
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<MenuCategory>(
                value: category,
                decoration: const InputDecoration(
                  labelText: 'Danh mục',
                ),
                items: [
                  DropdownMenuItem(
                    value: MenuCategory.mainCourse,
                    child: Text('Món chính'),
                  ),
                  DropdownMenuItem(
                    value: MenuCategory.appetizer,
                    child: Text('Khai vị'),
                  ),
                  DropdownMenuItem(
                    value: MenuCategory.dessert,
                    child: Text('Tráng miệng'),
                  ),
                  DropdownMenuItem(
                    value: MenuCategory.beverage,
                    child: Text('Nước uống'),
                  ),
                  DropdownMenuItem(
                    value: MenuCategory.other,
                    child: Text('Khác'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    category = value;
                  }
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Còn bán'),
                value: isAvailable,
                onChanged: (value) {
                  isAvailable = value;
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
              final updatedMenuItem = menuItem.copyWith(
                name: nameController.text,
                description: descriptionController.text,
                price: double.tryParse(priceController.text) ?? menuItem.price,
                category: category,
                isAvailable: isAvailable,
                imageUrl: imageUrlController.text,
              );
              try {
                await _menuController.updateMenuItem(updatedMenuItem);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã cập nhật món ăn thành công')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi khi cập nhật món ăn: $e')),
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

  void _showDeleteConfirmation(BuildContext context, String menuItemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa món ăn này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _menuController.deleteMenuItem(menuItemId);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xóa món ăn thành công')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi khi xóa món ăn: $e')),
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

  MaterialColor _getCategoryColor(MenuCategory category) {
    switch (category) {
      case MenuCategory.mainCourse:
        return Colors.blue;
      case MenuCategory.appetizer:
        return Colors.orange;
      case MenuCategory.dessert:
        return Colors.pink;
      case MenuCategory.beverage:
        return Colors.green;
      case MenuCategory.other:
        return Colors.grey;
    }
  }

  String _getCategoryText(MenuCategory category) {
    switch (category) {
      case MenuCategory.mainCourse:
        return 'Món chính';
      case MenuCategory.appetizer:
        return 'Khai vị';
      case MenuCategory.dessert:
        return 'Tráng miệng';
      case MenuCategory.beverage:
        return 'Nước uống';
      case MenuCategory.other:
        return 'Khác';
    }
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0)} VNĐ';
  }
} 