// import 'dart:io' show Platform;
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:lines_top_mobile/providers/user_data_provider.dart';
// import 'package:provider/provider.dart';

// class AuthView extends StatefulWidget {
//   const AuthView({super.key});

//   @override
//   State<AuthView> createState() => _AuthViewState();
// }

// class _AuthViewState extends State<AuthView> with TickerProviderStateMixin {
//   final Key emailKey = const ValueKey('email');
//   final Key usernameKey = const ValueKey('username');
//   final Key passwordKey = const ValueKey('password');
//   final Key passwordRepeatKey = const ValueKey('password2');
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _passwordRepeatController =
//       TextEditingController();

//   final GlobalKey<FormState> _formKey = GlobalKey();

//   bool _isReg = false;
//   bool _isLoading = false;

//   void _tryAuth() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }
//     FocusManager.instance.primaryFocus!.unfocus();
//     _isLoading = true;
//     setState(() {});
//     String result;
//     if (_isReg) {
//       result = await Provider.of<UserDataProvider>(context, listen: false)
//           .registerUser(_usernameController.text.trim(), _emailController.text,
//               _passwordController.text,
//               context: context);
//     } else {
//       result = await Provider.of<UserDataProvider>(context, listen: false)
//           .loginUser(_emailController.text, _passwordController.text,
//               context: context);
//     }
//     _isLoading = false;
//     if (result != 'Успешно!') {
//       ScaffoldMessenger.of(context).clearSnackBars();
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text(result, style: Theme.of(context).textTheme.titleMedium),
//         backgroundColor: Colors.white70,
//       ));
//     }
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomScrollView(
//       physics: const NeverScrollableScrollPhysics(),
//       slivers: [
//         SliverAppBar.large(
//           backgroundColor: Colors.transparent,
//           automaticallyImplyLeading: false,
//           pinned: true,
//           title: Text(
//             'Профиль',
//             style: Theme.of(context)
//                 .textTheme
//                 .headlineLarge!
//                 .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
//           ),
//         ),
//         SliverToBoxAdapter(
//           child: AnimatedContainer(
//             margin: const EdgeInsets.all(12),
//             alignment: Alignment.center,
//             duration: const Duration(milliseconds: 900),
//             child: Form(
//                 key: _formKey,
//                 child: Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Column(
//                     children: [
//                       Text(
//                         _isReg ? 'Регистрация' : 'Вход',
//                         style: Theme.of(context).textTheme.headlineMedium,
//                       ),
//                       if (_isReg)
//                         Platform.isIOS
//                             ? CupertinoTextFormFieldRow(
//                                 key: usernameKey,
//                                 cursorColor:
//                                     Theme.of(context).colorScheme.onSecondary,
//                                 prefix: Text(
//                                   'Имя пользователя',
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodySmall!
//                                       .copyWith(color: Colors.white),
//                                 ),
//                                 controller: _usernameController,
//                                 validator: (value) {
//                                   if (value == null) {
//                                     return 'Введите имя пользователя';
//                                   }
//                                   if (value.length < 4) {
//                                     return 'Имя пользователя слишком короткое';
//                                   }
//                                   return null;
//                                 },
//                               )
//                             : TextFormField(
//                                 key: usernameKey,
//                                 cursorColor:
//                                     Theme.of(context).colorScheme.onSecondary,
//                                 controller: _usernameController,
//                                 decoration: const InputDecoration(
//                                     hintText: 'Имя пользователя'),
//                                 validator: (value) {
//                                   if (value == null) {
//                                     return 'Введите имя пользователя';
//                                   }
//                                   if (value.length < 4) {
//                                     return 'Имя пользователя слишком короткое';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                       Platform.isIOS
//                           ? CupertinoTextFormFieldRow(
//                               key: emailKey,
//                               cursorColor:
//                                   Theme.of(context).colorScheme.onSecondary,
//                               prefix: Text(
//                                 'Электронная почта',
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .bodySmall!
//                                     .copyWith(color: Colors.white),
//                               ),
//                               controller: _emailController,
//                               validator: (value) {
//                                 if (value == null || value.isEmpty)
//                                   return 'Введите почту';
//                                 if (!value.contains('@'))
//                                   return 'Неверный формат';
//                                 if (!value.contains('.'))
//                                   return 'Неверный формат!';
//                                 return null;
//                               },
//                             )
//                           : TextFormField(
//                               key: emailKey,
//                               controller: _emailController,
//                               cursorColor:
//                                   Theme.of(context).colorScheme.onSecondary,
//                               decoration: const InputDecoration(
//                                   hintText: 'Электронная почта'),
//                               validator: (value) {
//                                 if (value == null || value.isEmpty)
//                                   return 'Введите почту';
//                                 if (!value.contains('@'))
//                                   return 'Неверный формат';
//                                 if (!value.contains('.'))
//                                   return 'Неверный формат!';
//                                 return null;
//                               },
//                             ),
//                       Platform.isIOS
//                           ? CupertinoTextFormFieldRow(
//                               key: passwordKey,
//                               cursorColor:
//                                   Theme.of(context).colorScheme.onSecondary,
//                               prefix: Text(
//                                 'Пароль',
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .bodySmall!
//                                     .copyWith(color: Colors.white),
//                               ),
//                               controller: _passwordController,
//                               obscureText: true,
//                               validator: (value) {
//                                 if (value == null || value == '') {
//                                   return 'Введите пароль';
//                                 }
//                                 if (value.length < 6)
//                                   return 'Пароль слишком короткий';
//                                 return null;
//                               },
//                             )
//                           : TextFormField(
//                               key: passwordKey,
//                               cursorColor:
//                                   Theme.of(context).colorScheme.onSecondary,
//                               controller: _passwordController,
//                               obscureText: true,
//                               decoration:
//                                   const InputDecoration(hintText: 'Пароль'),
//                               validator: (value) {
//                                 if (value == null || value == '') {
//                                   return 'Введите пароль';
//                                 }
//                                 if (value.length < 6)
//                                   return 'Пароль слишком короткий';
//                                 return null;
//                               },
//                             ),
//                       if (_isReg)
//                         Platform.isIOS
//                             ? CupertinoTextFormFieldRow(
//                                 key: passwordRepeatKey,
//                                 cursorColor:
//                                     Theme.of(context).colorScheme.onSecondary,
//                                 prefix: Text(
//                                   'Повтор пароля',
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodySmall!
//                                       .copyWith(color: Colors.white),
//                                 ),
//                                 controller: _passwordRepeatController,
//                                 obscureText: true,
//                                 validator: (value) {
//                                   if (value != _passwordController.text) {
//                                     return 'Пароли не совпадают!';
//                                   }
//                                   if (value == null || value == '') {
//                                     return 'Введите пароль';
//                                   }
//                                   return null;
//                                 },
//                               )
//                             : TextFormField(
//                                 key: passwordRepeatKey,
//                                 controller: _passwordRepeatController,
//                                 obscureText: true,
//                                 cursorColor:
//                                     Theme.of(context).colorScheme.onSecondary,
//                                 decoration: InputDecoration(
//                                     errorStyle:
//                                         Theme.of(context).textTheme.bodySmall,
//                                     hintText: 'Подтверждение пароля'),
//                                 validator: (value) {
//                                   if (value != _passwordController.text) {
//                                     return 'Пароли не совпадают!';
//                                   }
//                                   if (value == null || value == '') {
//                                     return 'Введите пароль';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                       Padding(
//                         padding: const EdgeInsets.all(20.0),
//                         child: TextButton(
//                             onPressed: () => setState(() => _isReg = !_isReg),
//                             child: Text(
//                               _isReg
//                                   ? 'У меня уже есть аккаунт'
//                                   : 'У меня нет аккаунта',
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .bodyMedium!
//                                   .copyWith(color: Colors.white),
//                             )),
//                       ),
//                       ElevatedButton(
//                         style: ButtonStyle(
//                             backgroundColor: MaterialStateProperty.all(
//                                 Theme.of(context).colorScheme.background)),
//                         onPressed: _tryAuth,
//                         child: Text(
//                           _isReg ? 'Зарегистрироваться' : 'Войти',
//                           style: Theme.of(context)
//                               .textTheme
//                               .bodyMedium!
//                               .copyWith(color: Colors.white),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )),
//           ),
//         ),
//         if (_isLoading)
//           const SliverToBoxAdapter(
//             child: UnconstrainedBox(
//                 child: Padding(
//               padding: EdgeInsets.only(top: 135.0),
//               child: CircularProgressIndicator(
//                 strokeWidth: 1,
//               ),
//             )),
//           ),
//       ],
//     );
//   }
// }
