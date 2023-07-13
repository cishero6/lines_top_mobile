import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lines_top_mobile/providers/user_data_provider.dart';
import 'package:provider/provider.dart';


class AuthScreen extends StatefulWidget {
  static const routeName = '/profile/auth';

  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin{
  final Key emailKey = const ValueKey('email');
  final Key usernameKey = const ValueKey('username');
  final Key passwordKey = const ValueKey('password');
  final Key passwordRepeatKey = const ValueKey('password2');
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordRepeatController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey();

  bool _isReg = false;
  bool _isLoading = false;

  void _tryAuth() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _isLoading = true;
    setState(() {});
    if (_isReg) {
      await Provider.of<UserDataProvider>(context, listen: false).registerUser(
          _usernameController.text,
          _emailController.text,
          _passwordController.text,
          context: context);
    } else {
      await Provider.of<UserDataProvider>(context, listen: false).loginUser(
          _emailController.text, _passwordController.text,
          context: context);
    }
    _isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            title: Text(
              'Профиль',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          SliverToBoxAdapter(
      child: AnimatedContainer(
        margin: const EdgeInsets.all(12),
        alignment: Alignment.center,
        duration: const Duration(milliseconds: 900),
        child: Card(
          child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      _isReg ? 'Регистрация' : 'Вход',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (_isReg)
                      Platform.isIOS
                          ? CupertinoTextFormFieldRow(
                            key: usernameKey,
                              prefix: Text('Имя пользователя',style: Theme.of(context).textTheme.bodySmall,),
                              controller: _usernameController,
                              validator: (value) {
                                if (value == null) {
                                  return 'Введите имя пользователя';
                                }
                                if (value.length < 4) {
                                  return 'Имя пользователя слишком короткое';
                                }
                                return null;
                              },
                            )
                          : TextFormField(
                            key: usernameKey,
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                  hintText: 'Имя пользователя'),
                              validator: (value) {
                                if (value == null) {
                                  return 'Введите имя пользователя';
                                }
                                if (value.length < 4) {
                                  return 'Имя пользователя слишком короткое';
                                }
                                return null;
                              },
                            ),
                    Platform.isIOS ? CupertinoTextFormFieldRow(
                      key: emailKey,
                      prefix: Text('Электронная почта',style: Theme.of(context).textTheme.bodySmall,),
                      controller: _emailController,
                      validator: (value) {
                        if (value == null) return 'Введите почту';
                        if (!value.contains('@')) return 'Неверный формат';
                        if (!value.contains('.')) return 'Неверный формат!';
                        return null;
                      },
                    ) : TextFormField(
                      key: emailKey,
                      controller: _emailController,
                      decoration:
                          const InputDecoration(hintText: 'Электронная почта'),
                      validator: (value) {
                        if (value == null) return 'Введите почту';
                        if (!value.contains('@')) return 'Неверный формат';
                        if (!value.contains('.')) return 'Неверный формат!';
                        return null;
                      },
                    ),
                    Platform.isIOS ? CupertinoTextFormFieldRow(
                      key: passwordKey,
                      prefix: Text('Пароль',style: Theme.of(context).textTheme.bodySmall,),
                      controller: _passwordController,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value == '') {
                          return 'Введите пароль';
                        }
                        if (value.length < 6) return 'Пароль слишком короткий';
                        return null;
                      },
                    ) : TextFormField(
                      key: passwordKey,
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: 'Пароль'),
                      validator: (value) {
                        if (value == null || value == '') {
                          return 'Введите пароль';
                        }
                        if (value.length < 6) return 'Пароль слишком короткий';
                        return null;
                      },
                    ),
                    if (_isReg)
                      Platform.isIOS ? CupertinoTextFormFieldRow(
                        key: passwordRepeatKey,
                        prefix: Text('Повтор пароля',style: Theme.of(context).textTheme.bodySmall,),
                        controller: _passwordRepeatController,
                        obscureText: true,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Пароли не совпадают!';
                          }
                          if (value == null || value == '') {
                            return 'Введите пароль';
                          }
                          return null;
                        },
                      ) : TextFormField(
                        key: passwordRepeatKey,
                        controller: _passwordRepeatController,
                        obscureText: true,
                        decoration: const InputDecoration(
                            hintText: 'Подтверждение пароля'),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Пароли не совпадают!';
                          }
                          if (value == null || value == '') {
                            return 'Введите пароль';
                          }
                          return null;
                        },
                      ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextButton(
                          onPressed: () => setState(() => _isReg = !_isReg),
                          child: Text(_isReg
                              ? 'У меня уже есть аккаунт'
                              : 'У меня нет аккаунта')),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).primaryColorLight)),
                      onPressed: _tryAuth,
                      child: Text(
                        _isReg ? 'Зарегистрироваться' : 'Войти',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ),
    ),
     if (_isLoading)  const SliverToBoxAdapter(child: UnconstrainedBox(child: Padding(
       padding: EdgeInsets.only(top: 135.0),
       child: CircularProgressIndicator(strokeWidth: 1,),
     )),),
        ],
      ),
    );
  }
}