import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_model.dart';
import '../models/admin/menu_item_model.dart';

class CartController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'carts';

  // Lấy giỏ hàng của người dùng
  Stream<CartModel?> getCart(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return CartModel.fromMap(snapshot.docs.first.data());
    });
  }

  // Thêm món ăn vào giỏ hàng
  Future<void> addToCart(String userId, MenuItemModel menuItem, {int quantity = 1}) async {
    final cartDoc = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .get();

    if (cartDoc.docs.isEmpty) {
      // Tạo giỏ hàng mới
      final cart = CartModel(
        userId: userId,
        items: [
          CartItem(
            menuItemId: menuItem.menuItemId,
            name: menuItem.name,
            price: menuItem.price,
            quantity: quantity,
            imageUrl: menuItem.imageUrl,
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _firestore.collection(_collection).add(cart.toMap());
    } else {
      // Cập nhật giỏ hàng hiện có
      final cart = CartModel.fromMap(cartDoc.docs.first.data());
      final existingItemIndex = cart.items.indexWhere(
        (item) => item.menuItemId == menuItem.menuItemId,
      );

      List<CartItem> updatedItems = List.from(cart.items);
      if (existingItemIndex != -1) {
        // Tăng số lượng nếu món ăn đã có trong giỏ
        final existingItem = updatedItems[existingItemIndex];
        updatedItems[existingItemIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + quantity,
        );
      } else {
        // Thêm món ăn mới vào giỏ
        updatedItems.add(
          CartItem(
            menuItemId: menuItem.menuItemId,
            name: menuItem.name,
            price: menuItem.price,
            quantity: quantity,
            imageUrl: menuItem.imageUrl,
          ),
        );
      }

      final updatedCart = cart.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(cartDoc.docs.first.id)
          .update(updatedCart.toMap());
    }
  }

  // Cập nhật số lượng món ăn trong giỏ hàng
  Future<void> updateCartItemQuantity(
    String userId,
    String menuItemId,
    int quantity,
  ) async {
    final cartDoc = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .get();

    if (cartDoc.docs.isNotEmpty) {
      final cart = CartModel.fromMap(cartDoc.docs.first.data());
      final itemIndex = cart.items.indexWhere(
        (item) => item.menuItemId == menuItemId,
      );

      if (itemIndex != -1) {
        List<CartItem> updatedItems = List.from(cart.items);
        if (quantity <= 0) {
          updatedItems.removeAt(itemIndex);
        } else {
          updatedItems[itemIndex] = updatedItems[itemIndex].copyWith(
            quantity: quantity,
          );
        }

        final updatedCart = cart.copyWith(
          items: updatedItems,
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection(_collection)
            .doc(cartDoc.docs.first.id)
            .update(updatedCart.toMap());
      }
    }
  }

  // Xóa món ăn khỏi giỏ hàng
  Future<void> removeFromCart(String userId, String menuItemId) async {
    final cartDoc = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .get();

    if (cartDoc.docs.isNotEmpty) {
      final cart = CartModel.fromMap(cartDoc.docs.first.data());
      final updatedItems = cart.items
          .where((item) => item.menuItemId != menuItemId)
          .toList();

      final updatedCart = cart.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(cartDoc.docs.first.id)
          .update(updatedCart.toMap());
    }
  }

  // Xóa toàn bộ giỏ hàng
  Future<void> clearCart(String userId) async {
    final cartDoc = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .get();

    if (cartDoc.docs.isNotEmpty) {
      await _firestore
          .collection(_collection)
          .doc(cartDoc.docs.first.id)
          .delete();
    }
  }
} 