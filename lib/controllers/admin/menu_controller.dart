import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/admin/menu_item_model.dart';

class MenuItemController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'menu_items';

  // Lấy danh sách món ăn
  Stream<List<MenuItemModel>> getMenuItems() {
    return _firestore
        .collection(_collection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MenuItemModel.fromMap({...doc.data(), 'menuItemId': doc.id}))
          .toList();
    });
  }

  // Lấy chi tiết món ăn
  Future<MenuItemModel?> getMenuItemDetails(String menuItemId) async {
    final doc = await _firestore.collection(_collection).doc(menuItemId).get();
    if (doc.exists) {
      return MenuItemModel.fromMap({...doc.data()!, 'menuItemId': doc.id});
    }
    return null;
  }

  // Thêm món ăn mới
  Future<String> addMenuItem(MenuItemModel menuItem) async {
    final docRef = await _firestore.collection(_collection).add(menuItem.toMap());
    return docRef.id;
  }

  // Cập nhật món ăn
  Future<void> updateMenuItem(MenuItemModel menuItem) async {
    await _firestore
        .collection(_collection)
        .doc(menuItem.menuItemId)
        .update(menuItem.toMap());
  }

  // Xóa món ăn
  Future<void> deleteMenuItem(String menuItemId) async {
    await _firestore.collection(_collection).doc(menuItemId).delete();
  }

  // Lấy số lượng món ăn
  Stream<int> getMenuItemCount() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Lấy món ăn theo danh mục
  Stream<List<MenuItemModel>> getMenuItemsByCategory(MenuCategory category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category.toString())
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MenuItemModel.fromMap({...doc.data(), 'menuItemId': doc.id}))
          .toList();
    });
  }

  // Lấy món ăn còn bán
  Stream<List<MenuItemModel>> getAvailableMenuItems() {
    return _firestore
        .collection(_collection)
        .where('isAvailable', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MenuItemModel.fromMap({...doc.data(), 'menuItemId': doc.id}))
          .toList();
    });
  }

  // Tìm kiếm món ăn
  Stream<List<MenuItemModel>> searchMenuItems(String query) {
    return _firestore
        .collection(_collection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MenuItemModel.fromMap({...doc.data(), 'menuItemId': doc.id}))
          .where((item) =>
              item.name.toLowerCase().contains(query.toLowerCase()) ||
              item.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
} 