import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/exceptions/auth_exception.dart';

import '../data/store.dart';

class Auth with ChangeNotifier {
  String? _token;
  String? _email;
  String? _userId;
  DateTime? _expiryDate;
  Timer? _logoutTimer;

  bool get isAuth {
    final isValid = _expiryDate?.isAfter(DateTime.now()) ?? false;
    return _token != null && isValid;
  }

  String? get token {
    return isAuth ? _token : null;
  }

  String? get email {
    return isAuth ? _email : null;
  }

  String? get userId {
    return isAuth ? _userId : null;
  }

  /* Método responsável por realizar a requisição de login para o servidor.
    Parâmetros:  String email, e String senha.

    Esse método envia as informações passadas pelo usuário para o servidor e 
    trata a resposta obtida, caso retorne um erro, chama uma função auxiliadora a
    autenticação. Caso esteja tudo correto, atribui os valores recebidos da requisi
    ção as variáveis associadas.


    Área de persistência
    */

  Future<void> _authenticate(
      String email, String password, String urlFragment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlFragment?key=AIzaSyC0hphuwtfTGtX3m6N96EPhY0S7j95ybwc';

    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );

    final body = jsonDecode(response.body);
    if (body['error'] != null) {
      throw AuthException(body['error']['message']);
    } else {
      _token = body['idToken'];
      _email = body['email'];
      _userId = body['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(body['expiresIn']),
        ),
      );

      Store.saveMap('userData', {
        'token': _token,
        'email': _email,
        'userId': _userId,
        'expiryDate': _expiryDate!.toIso8601String(),
      });

      _autoLogout();
      notifyListeners();
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  /* Método que redorta um future que tentará fazer o login automatico baseado na 
  persistência de dados.

  Aqui acontece uma série de validações, se estiver autenticado, se não tiver informações
  no map ou se a data expirou, so após isso tentará o login.

  */

  Future<void> tryAutoLogin() async {
    if (isAuth) return;

    final userData = await Store.getMap('userData');
    if (userData.isEmpty) return;

    /* Data de expiração do token */
    final expiryDate = DateTime.parse(userData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) return;

    /* Restaurando os dados do usuário */
    _token = userData['token'];
    _email = userData['email'];
    _userId = userData['userId'];
    _expiryDate = expiryDate;

    _autoLogout();
    notifyListeners();
  }

  /* Método de logout da aplicação.
  
    Quando chamado esse método 'limpa' os valores das variáveis, que em nossa aplicação
    só é nulo quando o usuário não está logado.  
   */

  void logout() {
    _token = null;
    _email = null;
    _userId = null;
    _expiryDate = null;
    _clearLogoutTimer();
    notifyListeners();
  }

  /* Adicionando logout automático */

  /* Método responsável por limpar o timer de logout */
  void _clearLogoutTimer() {
    _logoutTimer?.cancel();
    _logoutTimer = null;
  }

  /* Método responsável por passar um timer para o logout. 

    Timer esse que recebe como parâmetros uma duração e uma função
    a duração é o tempo que ele esperará até chamar a função passada como parâ-
    metro  
   */
  void _autoLogout() {
    _clearLogoutTimer();
    /* Se não estiver nullo faça a diferença do valor da variável com a data
    atual */
    final timeTologout = _expiryDate?.difference(DateTime.now()).inSeconds;
    _logoutTimer = Timer(Duration(seconds: timeTologout ?? 0), logout);
  }
}
