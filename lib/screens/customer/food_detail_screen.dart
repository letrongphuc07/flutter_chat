import 'package:flutter/material.dart';
import '../../models/admin/menu_item_model.dart';

class FoodDetailScreen extends StatelessWidget {
  final MenuItemModel menuItem;
  const FoodDetailScreen({Key? key, required this.menuItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(menuItem.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  menuItem.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(Icons.restaurant, size: 64),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                menuItem.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                menuItem.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                '${menuItem.price.toStringAsFixed(0)} VNĐ',
                style: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Thêm vào giỏ hàng'),
                  onPressed: () {
                    Navigator.pop(context, true); // Trả về true để biết đã thêm
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 