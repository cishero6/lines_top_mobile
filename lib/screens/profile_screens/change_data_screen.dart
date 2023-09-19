// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lines_top_mobile/screens/more_screens.dart/delete_account_verification_screen.dart';
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
  final TextEditingController _phoneController = TextEditingController();


  final FocusNode _nameChangeFocusNode = FocusNode();





  Widget _buildConfirmDialog(BuildContext ctx,Future<String> Function() action){
    return AlertDialog(
      backgroundColor: Colors.white70,
      surfaceTintColor: Colors.transparent,
      content: Padding(
        padding: const EdgeInsets.only(top:12.0),
        child: Text('Вы уверены?',style: Theme.of(context).textTheme.headlineSmall,),
      ),
      actions: [TextButton(onPressed: ()=> action().then((result) {
        if(result == 'Успешно!'){
          Navigator.of(context).pop();
        }
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(result,style: Theme.of(context).textTheme.titleMedium,),
              backgroundColor: Colors.white70,
            ));
            Navigator.of(ctx).pop();
      } )  , child: Text('Да', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: CupertinoColors.systemRed),),),TextButton(onPressed: ()=>Navigator.of(ctx).pop(), child: Text('Отмена', style: Theme.of(context).textTheme.bodyMedium,),)],
    );
  }


  @override
  Widget build(BuildContext context) {
        authData = Provider.of<UserDataProvider>(context);
    _nameController.text = authData.username ?? 'Ошибка';
    _phoneController.text = authData.phoneNumber ?? 'Ошибка';
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Colors.black,image: DecorationImage(image: AssetImage('assets/images/backgrounds/bg_1.jpg'),fit: BoxFit.cover,opacity: 0.7)),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              backgroundColor: Colors.transparent,
              title: Text('Изменить данные',style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white,fontWeight: FontWeight.bold),),
            ),
            SliverList.list(children: [
              ChangeDataListItem(leadingText: 'Номер', textEditingController: _phoneController,readOnly: true,),
              const SizedBox(height: 30,),
              ChangeDataListItem(leadingText: 'Имя', textEditingController: _nameController,focusNode: _nameChangeFocusNode,),
              const SizedBox(height: 10,),
              UnconstrainedBox(child: ElevatedButton(onPressed: (){if(!_nameChangeFocusNode.hasFocus){_nameChangeFocusNode.requestFocus(); return;} _nameChangeFocusNode.unfocus();authData.changeUsername(_nameController.text).then((result) {ScaffoldMessenger.of(context).clearSnackBars();ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result,style: Theme.of(context).textTheme.titleMedium,),backgroundColor: Colors.white70,));});}, child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Изменить' ,style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),),
              ))),
              const SizedBox(height: 30,),
              UnconstrainedBox(child: ElevatedButton(onPressed: ()=>showDialog(context: context, builder:(ctx)=> _buildConfirmDialog(ctx,authData.logoutUser)), child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Выйти',style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),),
              ))),
              const SizedBox(height: 30,),
              UnconstrainedBox(child: TextButton(onPressed: ()=>Navigator.of(context).pushNamed(DeleteAccountVerificationScreen.routeName), child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Удалить аккаунт',style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white),),
              ))),

            ]),
          ],
        ),
      ),
    );
  }
}