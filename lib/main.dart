import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/auth.dart';
import 'package:shop/models/cart.dart';
import 'package:shop/pages/auth_page.dart';
import 'package:shop/pages/cart_page.dart';
import 'package:shop/pages/orders_page.dart';
import 'package:shop/pages/product_detail_page.dart';
import 'package:shop/pages/products_page.dart';
import 'package:shop/pages/products_overview_pages.dart';
import 'package:shop/utils/app_routes.dart';

import 'models/oder_list.dart';
import 'models/product_list.dart';
import 'pages/product_form_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ThemeData myTheme = ThemeData();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Auth(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductList(),
        ),
        ChangeNotifierProvider(
          create: (_) => Cart(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderList(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
            colorScheme: myTheme.colorScheme.copyWith(
              primary: Colors.purple,
              secondary: Colors.deepOrange,
            ),
            appBarTheme: (AppBarTheme(
              centerTitle: false,
            )),
            textTheme: TextTheme(titleLarge: TextStyle(color: Colors.white)),
            fontFamily: 'Lato'),
        routes: {
          AppRoutes.AUTH: (ctx) => AuthPage(),
          AppRoutes.HOME: (ctx) => ProductsOverviewPage(),
          AppRoutes.PRODUCT_DETAIL: (ctx) => ProductDetailPage(),
          AppRoutes.CART: (ctx) => CartPage(),
          AppRoutes.ORDERS: (ctx) => OrdersPage(),
          AppRoutes.PRODUCTS: (ctx) => ProductsPage(),
          AppRoutes.PRODUCT_FORM: (ctx) => ProductFormPage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
