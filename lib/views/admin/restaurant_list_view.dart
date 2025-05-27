import 'package:flutter/material.dart';
import '../../controllers/admin/restaurant_controller.dart';
import '../../models/admin/restaurant_model.dart';

class RestaurantListView extends StatelessWidget {
  static final RestaurantController _restaurantController = RestaurantController();

  const RestaurantListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Danh sách nhà hàng',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF222B45),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddRestaurantDialog(context),
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
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<RestaurantModel>>(
                stream: _restaurantController.getRestaurants(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Có lỗi xảy ra'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Chưa có nhà hàng nào'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final restaurant = snapshot.data![index];
                      return Opacity(
                        opacity: restaurant.isActive ? 1.0 : 0.5,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            leading: restaurant.imageUrl != null && restaurant.imageUrl!.isNotEmpty
                                ? CircleAvatar(
                                    radius: 28,
                                    backgroundImage: NetworkImage(restaurant.imageUrl!),
                                  )
                                : CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.green[100],
                                    child: Icon(Icons.restaurant, color: Colors.green[700], size: 32),
                                  ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    restaurant.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: Color(0xFF222B45),
                                    ),
                                  ),
                                ),
                                if (!restaurant.isActive)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Ngừng hoạt động',
                                      style: TextStyle(
                                        color: Colors.red,
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
                                Text(
                                  restaurant.address,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF8F9BB3),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'ID Chủ nhà hàng: ${restaurant.ownerId}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFB0B5C0),
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
                                  onPressed: () => _showEditRestaurantDialog(context, restaurant),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  tooltip: 'Xóa',
                                  onPressed: () => _showDeleteConfirmation(context, restaurant.id),
                                ),
                              ],
                            ),
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

  void _showAddRestaurantDialog(BuildContext context) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final imageUrlController = TextEditingController();
    final ownerIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm nhà hàng mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên nhà hàng',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL hình ảnh',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ownerIdController,
                decoration: const InputDecoration(
                  labelText: 'ID Chủ nhà hàng',
                ),
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
                final restaurant = RestaurantModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  address: addressController.text,
                  imageUrl: imageUrlController.text,
                  ownerId: ownerIdController.text,
                );
                await _restaurantController.addRestaurant(restaurant);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã thêm nhà hàng thành công')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi khi thêm nhà hàng: $e')),
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

  void _showEditRestaurantDialog(BuildContext context, RestaurantModel restaurant) {
    final nameController = TextEditingController(text: restaurant.name);
    final addressController = TextEditingController(text: restaurant.address);
    final imageUrlController = TextEditingController(text: restaurant.imageUrl);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa nhà hàng'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên nhà hàng',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL hình ảnh',
                ),
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
              final updatedRestaurant = restaurant.copyWith(
                name: nameController.text,
                address: addressController.text,
                imageUrl: imageUrlController.text,
              );
              try {
                await _restaurantController.updateRestaurant(updatedRestaurant);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã cập nhật nhà hàng thành công')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi khi cập nhật nhà hàng: $e')),
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

  void _showDeleteConfirmation(BuildContext context, String restaurantId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa nhà hàng này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _restaurantController.deleteRestaurant(restaurantId);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xóa nhà hàng thành công')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi khi xóa nhà hàng: $e')),
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