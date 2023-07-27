import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/exceptions/auth_exception.dart';

import '../models/auth.dart';

enum AuthMode { Signup, Login }

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

/* Mixin Singletickerprovider é responsável por fornecer um provider
para um ticker responsável por apenas uma animação
*/
class _AuthFormState extends State<AuthForm>
    with SingleTickerProviderStateMixin {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  /* Adicionando animação */
  AnimationController? _controller;
  /*  Classe que recebe um tipo generio e esse tipo genérico é o
  tipo de valor que eu quero animar */
  Animation<double>? _opacityAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    /* Controller da animação, cara que vai ligar com a função chamada pelo ticker
     dentro o intervalo de tempo definido*/
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ),
    );

    /* Atribuindo a animação de altura uma classe que herda animação
    animação tween trabalha entre dois intervalos (inicio e fim) 
    
    e chamamos a funçao animate e passar para ele como paramêtro o que 
    vai ser uma animation de um valor do tipo double. 
    */
    _opacityAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.linear,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1.5),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.linear,
      ),
    );

    /*
    será utilizado outra estrategia
    _heightAnimation?.addListener(() => setState(() {}));
    */
  }

  /* Dispose é responsável por liberar uma funcinalidade*/
  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  bool _islogin() => _authMode == AuthMode.Login;
  bool _isSignup() => _authMode == AuthMode.Signup;

  void _switchAuthMode() {
    setState(() {
      if (_islogin()) {
        _authMode = AuthMode.Signup;
        /* chama o controller para ele iniciar a animação */
        _controller?.forward();
      } else {
        _authMode = AuthMode.Login;
        /* chama a animação fazendo o reverse, do final para o início */
        _controller?.reverse();
      }
    });
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ocorreu um erro'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    setState(() => _isLoading = true);

    _formKey.currentState?.save();
    Auth auth = Provider.of(context, listen: false);

    try {
      if (_islogin()) {
        await auth.login(
          _authData['email']!,
          _authData['password']!,
        );
      } else {
        await auth.signup(
          _authData['email']!,
          _authData['password']!,
        );
      }
    } on AuthException catch (error) {
      _showErrorDialog(error.toString());
    } catch (error) {
      _showErrorDialog('Ocorreu um erro inesperado!');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 6,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        /* relacionado ao animatedBuilder
        Pega  o valor da altura da nossa classe de animação, e caso não esteja disponível 
        chamará a lógica antiga
        height: _heightAnimation?.value.height ?? (_islogin() ? 310 : 400),*/
        height: _islogin() ? 310 : 400,
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (email) => _authData['email'] = email ?? '',
                  validator: (_email) {
                    final email = _email ?? '';
                    if (email.trim().isEmpty || !email.contains('@')) {
                      return 'Informe um email válido';
                    }
                    return null;
                  }),
              TextFormField(
                  decoration: const InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                  controller: _passwordController,
                  onSaved: (password) => _authData['password'] = password ?? '',
                  validator: _islogin()
                      ? null
                      : (_password) {
                          final password = _password ?? '';
                          if (password.isEmpty || password.length < 5) {
                            return 'Informe uma senha válida';
                          }
                          return null;
                        }),
              /*Animação do campo confirmar senha
              Tenho que mostrar ao container qual os parâmetros dentro do componente
              que eu quero fazer a animação */
              AnimatedContainer(
                /* define o que será animado no container que é o campo de confirmar senha

                  uma vez que quando estiver em login a altura dele será 0, e em registrar 
                  será 60
                */
                constraints: BoxConstraints(
                  minHeight: _islogin() ? 0 : 60,
                  maxHeight: _islogin() ? 0 : 120,
                ),
                duration: Duration(milliseconds: 300),
                curve: Curves.linear,
                child: FadeTransition(
                  opacity: _opacityAnimation!,
                  child: SlideTransition(
                    position: _slideAnimation!,
                    child: TextFormField(
                      //ss
                      decoration:
                          const InputDecoration(labelText: 'Confirmar Senha'),
                      obscureText: true,
                      validator: _islogin()
                          ? null
                          : (_password) {
                              final password = _password ?? '';
                              if (password != _passwordController.text) {
                                return 'Senhas informadas não conferem.';
                              }
                              return null;
                            },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
                  ),
                  child: Text(
                      _authMode == AuthMode.Login ? 'Entrar' : 'Registrar'),
                ),
              const Spacer(),
              TextButton(
                onPressed: _switchAuthMode,
                child:
                    Text(_islogin() ? 'Deseja Registrar?' : 'Já possui conta?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
