/* Responsável por gerenciar todos os pedidos */

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/models/cart_item.dart';
import '../utils/constants.dart';
import 'cart.dart';
import 'order.dart';

class OrderList with ChangeNotifier {
  final String _token;
  List<Order> _items = [];

  OrderList(this._token, this._items);

  List<Order> get items {
    return [..._items];
  }

  int get itemsCount {
    return _items.length;
  }

  Future<void> addOrder(Cart cart) async {
    final date = DateTime.now();
    final response = await http.post(
      Uri.parse('${Constants.ORDERS_BASE_URL}.json?auth=$_token'),
      body: jsonEncode(
        {
          'total': cart.totalAmount,
          'date': date.toIso8601String(),
          'products': cart.items.values
              .map((cartItem) => {
                    'id': cartItem.id,
                    'productId': cartItem.productId,
                    'name': cartItem.name,
                    'quantity': cartItem.quantity,
                    'price': cartItem.price,
                  })
              .toList(),
        },
      ),
    );
    final id = jsonDecode(response.body)['name'];
    _items.insert(
        0,
        Order(
            id: id,
            total: cart.totalAmount,
            date: date,
            products: cart.items.values.toList()));
    notifyListeners();
  }

  Future<void> loadOrders() async {
    List<Order> items = [];
    final response = await http.get(
      Uri.parse('${Constants.ORDERS_BASE_URL}.json?auth=$_token'),
    );
    if (response.body == 'null') return;
    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach((orderId, orderData) {
      items.add(Order(
          id: orderId,
          date: DateTime.parse(orderData['date']),
          total: orderData['total'],
          products: (orderData['products'] as List<dynamic>).map((item) {
            return CartItem(
              id: item['id'],
              productId: item['productId'],
              name: item['name'],
              quantity: item['quantity'],
              price: item['price'],
            );
          }).toList()
          //       id: productId,
          //       name: productData['name'].toString(),
          //       description: productData['description'].toString(),
          //       price: double.parse(productData['price'].toString()),
          //       imageUrl: productData['imageUrl'].toString(),
          //       isFavorite: productData['isFavorite']));
          ));
    });
    _items = items.reversed.toList();
    notifyListeners();
  }
}
