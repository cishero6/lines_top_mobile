// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_data_provider.dart';
import '../../widgets/list_items/change_data_list_item.dart';

class ChangeDataScreen extends StatefulWidget {
  const ChangeDataScreen({super.key});
  static const routeName = 'profile/change_data';
  @override
  State<ChangeDataScreen> createState() => _ChangeDataScreenState();
}

class _ChangeDataScreenState extends State<ChangeDataScreen> {
  late UserDataProvider authData;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();


  void _tryChangeEmail()async{
    if(_emailController.text.isEmpty){
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Введите новую почту',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        backgroundColor: Colors.white,
      ));
      return;
    }
    if(!_emailController.text.contains('.')){
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Неверный формат новой почты',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        backgroundColor: Colors.white,
      ));
      return;
    }
    if(!_emailController.text.contains('@')){
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Неверный формат новой почты',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        backgroundColor: Colors.white,
      ));
      return;
    }
    String result = await authData.changeEmail(newEmail: _emailController.text.trim(),password: '123321');
    ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          result,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        backgroundColor: Colors.white,
      ));
  }


  Future<String> _tryChangePassword()async{
   if (_oldPasswordController.text == '') {
      return Future.value('Введите старый пароль');
    }
    if (_oldPasswordController.text.length < 6) return Future.value('Пароль слишком короткий');
    if (_passwordController.text == '') {
      return Future.value('Введите новый пароль');
    }
    if (_passwordController.text.length < 6) return Future.value('Пароль слишком короткий');
    if (_passwordController.text != _repeatPasswordController.text) {
      return Future.value('Пароли не совпадают');
    }
    String result = await authData.changePassword(_oldPasswordController.text, _passwordController.text);
    _passwordController.clear();
    _repeatPasswordController.clear();
    _oldPasswordController.clear();
    return result;
  }

  void _startChangePassword(){
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              gradient: const LinearGradient(
                colors: [
                Color.fromARGB(255, 255, 255, 255),
                Color.fromARGB(255, 90, 90, 90)
              ], begin: Alignment.bottomLeft, end: Alignment.topRight),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Введите старый пароль',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: CupertinoTextField(
                      obscureText: true,
                      controller: _oldPasswordController,
                      placeholder: 'Старый пароль',
                      cursorColor: Colors.black54,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Введите новый пароль',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: CupertinoTextField(
                      obscureText: true,
                      controller: _passwordController,
                       placeholder: 'Новый пароль',
                      cursorColor: Colors.black54,

                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Повторите новый пароль',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: CupertinoTextField(
                      obscureText: true,
                      controller: _repeatPasswordController,
                      placeholder: 'Повтор',
                      cursorColor: Colors.black54,

                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: ElevatedButton(onPressed: ()async{
                      FocusManager.instance.primaryFocus!.unfocus();
                      String result = await _tryChangePassword();
                      ScaffoldMessenger.of(ctx).clearSnackBars();
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(result,style: Theme.of(context).textTheme.titleMedium,),backgroundColor: Colors.white,));
                      if(result == 'Успешно!') Navigator.of(ctx).pop();
                    }, child: Text('Подтвердить',style: Theme.of(context).textTheme.titleMedium,)),
                  ),
                ],
              ),
            )),
      ),
);
  }

  @override
  Widget build(BuildContext context) {
    authData = Provider.of<UserDataProvider>(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/backgrounds/bg_1.jpg'),fit: BoxFit.cover,opacity: 0.5)),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              backgroundColor: Colors.transparent,
              title: Text('Изменить данные',style: Theme.of(context).textTheme.headlineMedium,),
            ),
            SliverList.list(children: [
              ChangeDataListItem(leadingText: 'Имя', textEditingController: _nameController, initialValue: authData.username!),
              UnconstrainedBox(child: ElevatedButton(onPressed: (){authData.changeUsername(_nameController.text).then((result) {ScaffoldMessenger.of(context).clearSnackBars();ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result,style: Theme.of(context).textTheme.titleMedium,),backgroundColor: Colors.white70,));});}, child: Text('Подтвердить',style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),))),
              ChangeDataListItem(leadingText: 'E-Mail', textEditingController: _emailController, initialValue: authData.email!),
              UnconstrainedBox(child: ElevatedButton(onPressed: _tryChangeEmail, child: Text('Подтвердить',style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),))),
              UnconstrainedBox(child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(onPressed: _startChangePassword, child: Text('Изменить пароль',style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),)),
              )),

            ]),
          ],
        ),
      ),
    );
  }
}