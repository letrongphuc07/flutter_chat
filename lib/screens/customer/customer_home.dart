import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/floating_chat_button.dart';
import '../../controllers/admin/menu_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../models/admin/menu_item_model.dart';
import 'food_detail_screen.dart';
import 'dart:async';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  final AuthService _authService = AuthService();
  final MenuItemController _menuController = MenuItemController();
  final CartController _cartController = CartController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  MenuCategory? _selectedCategory;
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
      });
    });
  }

  Future<void> _addToCart(MenuItemModel menuItem) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _authService.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bạn cần đăng nhập để thêm vào giỏ hàng'),
            ),
          );
        }
        return;
      }

      await _cartController.addToCart(user.uid, menuItem);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm vào giỏ hàng'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi thêm vào giỏ hàng: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Column(
        children: [
          // PHẦN HEADER
          Container(
            height: 220,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/Logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading background image: $error');
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Trang chủ',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/customer/cart');
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.logout, color: Colors.white),
                                onPressed: () async {
                                  await _authService.signOut();
                                  if (mounted) {
                                    Navigator.pushReplacementNamed(context, '/login');
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm món ăn...',
                          hintStyle: const TextStyle(color: Colors.white),
                          prefixIcon: const Icon(Icons.search, color: Colors.white),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryChip(null, 'Tất cả'),
                          ...MenuCategory.values.map(
                            (category) => _buildCategoryChip(
                              category,
                              _getCategoryText(category),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // PHẦN DANH SÁCH MÓN ĂN
          Expanded(
            child: Stack(
              children: [
                StreamBuilder<List<MenuItemModel>>(
                  stream: _searchQuery.isNotEmpty
                      ? _menuController.searchMenuItems(_searchQuery)
                      : _selectedCategory != null
                          ? _menuController.getMenuItemsByCategory(_selectedCategory!)
                          : _menuController.getMenuItems(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print('Error loading menu items: ${snapshot.error}');
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              'Có lỗi xảy ra: ${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {}); // Refresh the page
                              },
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Không tìm thấy món ăn phù hợp'
                                  : 'Không có món ăn nào',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        setState(() {});
                      },
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final menuItem = snapshot.data![index];
                          return _buildMenuItemCard(menuItem);
                        },
                      ),
                    );
                  },
                ),
                const FloatingChatButton(),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(MenuCategory? category, String label) {
    final isSelected = category == _selectedCategory;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.blue[100],
        checkmarkColor: Colors.blue,
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  String _getAssetImageForMenu(String name) {
    switch (name.toLowerCase()) {
      case 'bánh quy':
        return 'assets/images/bánh quy.webp';
      case 'bún thịt nướng':
        return 'assets/images/bún thịt nướng.jpg';
      case 'cơm trộn':
        return 'assets/images/cơm trộn.jpg';
      case 'trà sữa trân châu':
        return 'assets/images/trà sữa trân châu đường đen.jpg';
      case 'bún bò huế':
        return 'assets/images/bún bò huế.jpg';
      case 'mỳ quảng':
        return 'assets/images/mỳ quảng.jpg';
      case 'mỳ trộn':
        return 'assets/images/mỳ trộn.jpg';
      case 'gà rán':
        return 'assets/images/gà rán.jpg';
      case 'bún đậu mắm tôm':
        return 'assets/images/bún đậu mắm tôm.webp';
      case 'bánh tráng trộn':
        return 'assets/images/banh trang tron.jpg';
      default:
        return 'assets/images/Logo.png';
    }
  }

  Widget _buildMenuItemCard(MenuItemModel menuItem) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoodDetailScreen(menuItem: menuItem),
            ),
          );
          if (result == true) {
            await _addToCart(menuItem);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                _getAssetImageForMenu(menuItem.name),
                height: 80,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading menu item image: $error');
                  return Container(
                    height: 80,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    menuItem.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${menuItem.price.toStringAsFixed(0)} VNĐ',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart),
                        onPressed: _isLoading ? null : () async {
                          await _addToCart(menuItem);
                        },
                        color: Colors.blue,
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
} 