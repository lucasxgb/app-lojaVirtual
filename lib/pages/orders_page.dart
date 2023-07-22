import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/app_drawer.dart';
import 'package:shop/components/order.dart';

import '../models/oder_list.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  Future<void> _refreshOrders(BuildContext context) {
    return Provider.of<OrderList>(context, listen: false).loadOrders();
  }

  // bool _isLoading = true;
  @override
  Widget build(BuildContext context) {
    // final OrderList orders = Provider.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: Text('Meus pedidos'),
      ),
      body: FutureBuilder(
          future: Provider.of<OrderList>(context, listen: false).loadOrders(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Consumer<OrderList>(
                builder: (ctx, orders, child) => RefreshIndicator(
                  onRefresh: () => _refreshOrders(context),
                  child: ListView.builder(
                    itemCount: orders.itemsCount,
                    itemBuilder: (ctx, index) =>
                        OrderWidget(order: orders.items[index]),
                  ),
                ),
              );
            }
          }),
      drawer: const AppDrawer(),
    );
  }
}
