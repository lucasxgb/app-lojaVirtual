import 'package:flutter/material.dart';
/* Classe que vai auxiliar a ter uma transição   personalizada para 
uma rota especifica */

class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(builder: builder, settings: settings);

/* Método que será implementado a transição */
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

/* Classe que vai auxiliar a ter uma transição   personalizada de forma global
para toda a aplicação */
class CustomPageTransitionsBuilder extends PageTransitionsBuilder {
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    /* animação personalizada para determinada rota 
    if (route.settings.name == '/') {
      return child;
    }*/
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
