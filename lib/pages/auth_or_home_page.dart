import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/pages/auth_page.dart';
import 'package:shop/pages/products_overview_pages.dart';

import '../models/auth.dart';

class AuthOrHomePage extends StatelessWidget {
  const AuthOrHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Auth auth = Provider.of(context);
    //return auth.isAuth ? ProductsOverviewPage() : AuthPage();
    return FutureBuilder(
        future: auth.tryAutoLogin(),
        /* Controlo do que está acontecendo com a future*/
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.error != null) {
            return const Center(
              child: Text('Ocorreu um erro!'),
            );
          } else {
            return auth.isAuth ? ProductsOverviewPage() : AuthPage();
          }
        });
  }
}
