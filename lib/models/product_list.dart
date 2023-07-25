import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/models/product.dart';

import '../utils/constants.dart';

/* Sempre que houver uma mudança no changeNotifier é importante avisar
aos interessados (obsevers) */
class ProductList with ChangeNotifier {
  List<Product> _items = [];
  final String _token;
  final String _userId;

  ProductList([this._token = '', this._userId = '', this._items = const []]);

  int get itemsCount {
    return _items.length;
  }

  //retornando um clone da minha lista principal
  List<Product> get items {
    return [..._items];
  }

  Future<void> loadProducts() async {
    _items.clear();
    /* Fazendo a requisição dizendo para o firebase que estou logado, pois passamos o token */
    final response = await http.get(
      Uri.parse('${Constants.PRODUCT_BASE_URL}.json?auth=$_token'),
    );
    if (response.body == 'null') return;

    final favResponse = await http.get(
      Uri.parse('${Constants.USER_FAVORITES_URL}/$_userId.json?auth=$_token'),
    );

    Map<String, dynamic> favData =
        favResponse.body == 'null' ? {} : jsonDecode(favResponse.body);

    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach((productId, productData) {
      final isFavorite = favData[productId] ?? false;
      _items.add(Product(
        id: productId,
        name: productData['name'].toString(),
        description: productData['description'].toString(),
        price: double.parse(productData['price'].toString()),
        imageUrl: productData['imageUrl'].toString(),
        isFavorite: isFavorite,
      ));
    });
    notifyListeners();
  }

  List<Product> get favoriteItems =>
      _items.where((product) => product.isFavorite).toList();

  Future<void> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse('${Constants.PRODUCT_BASE_URL}.json?auth=$_token'),
      body: jsonEncode(
        {
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
        },
      ),
    );

    final id = jsonDecode(response.body)['name'];
    _items.add(
      Product(
        id: id,
        name: product.name,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      ),
    );
    notifyListeners();
  }

  Future<void> saveProduct(Map<String, Object> data) {
    bool hasId = data['id'] != null;

    final product = Product(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      name: data['name'].toString(),
      description: data['description'].toString(),
      price: double.parse(data['price'].toString()),
      imageUrl: data['imageUrl'].toString(),
    );

    if (hasId) {
      return updateProduct(product);
    } else {
      return addProduct(product);
    }
  }

  Future<void> updateProduct(Product product) async {
    /* Pesquisano pelo index, se o indíce é valido e o produto
    está dentro da nossa lista */
    int index = _items.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      final response = await http.patch(
        Uri.parse(
            '${Constants.PRODUCT_BASE_URL}/${product.id}.json?auth=$_token'),
        body: jsonEncode(
          {
            'name': product.name,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
          },
        ),
      );
      _items[index] = product;
      notifyListeners();
    }
    return Future.value();
  }

  Future<void> removeProduct(Product product) async {
    int index = _items.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      final product = _items[index];
      _items.remove(product);
      notifyListeners();

      final response = await http.delete(
        Uri.parse(
            '${Constants.PRODUCT_BASE_URL}/${product.id}.json?auth=$_token'),
      );

      if (response.statusCode >= 400) {
        /* insere os itens exatamente no mesmo ponto */
        _items.insert(index, product);
        notifyListeners();
        throw HttpException(
          msg: 'Não foi possível excluir o produto',
          statusCode: response.statusCode,
        );
      }
    }
  }
}
