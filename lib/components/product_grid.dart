import 'package:provider/provider.dart';
import 'package:shop/components/product_grid_item.dart';
import '../models/product.dart';
import '../models/product_list.dart';
import 'package:flutter/material.dart';

class ProductGrid extends StatelessWidget {
  final bool showFavoriteOnly;
  ProductGrid(this.showFavoriteOnly);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductList>(context);
    final List<Product> loadedProducts =
        showFavoriteOnly ? provider.favoriteItems : provider.items;

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: loadedProducts.length,
      /* Usa o .value pois esse changeNotifier já foi criado
      anteriormente */
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        value: loadedProducts[index],
        child: ProductGridItem(),
      ),
      /* Diz como vai construir cada elemento que vai ser exibido dentro da gridviel */
      /* área dentro de algo que é rolavel, com a quantidade de 
      elementos fixos no eixo cruzado */
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
    );
  }
}
