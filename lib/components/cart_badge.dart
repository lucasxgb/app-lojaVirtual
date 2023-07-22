import 'package:flutter/material.dart';

class CartBadge extends StatelessWidget {
  final Widget child;
  final String value;
  final Color? color;
  const CartBadge(
      {super.key, required this.child, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
            right: 8,
            top: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(2),
                constraints: BoxConstraints(minHeight: 16, maxWidth: 16),
                color: color ?? Theme.of(context).colorScheme.secondary,
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                  ),
                ),
              ),
            ))
      ],
    );
  }
}
