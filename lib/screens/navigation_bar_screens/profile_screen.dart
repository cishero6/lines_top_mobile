import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lines_top_mobile/helpers/db_helper.dart';
import 'package:lines_top_mobile/screens/profile_screens/change_data_screen.dart';
import 'package:lines_top_mobile/screens/profile_screens/control_screen.dart';
import 'package:lines_top_mobile/screens/profile_screens/parameters_screen.dart';
import 'package:lines_top_mobile/screens/profile_screens/programs_progress_screen.dart';
import 'package:lines_top_mobile/widgets/list_items/profile_item.dart';
import 'package:provider/provider.dart';

import '../../providers/user_data_provider.dart';
import '../../widgets/phone_auth_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const routeName = '/profile';
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserDataProvider authData;

  @override
  void initState() {
    authData = Provider.of<UserDataProvider>(context,listen: false);
    super.initState();
  }

  Widget _buildConfirmDialog(BuildContext ctx){
    return AlertDialog(
      backgroundColor: Colors.white70,
      surfaceTintColor: Colors.transparent,
      content: Padding(
        padding: const EdgeInsets.only(top:12.0),
        child: Text('Вы уверены?',style: Theme.of(context).textTheme.headlineSmall,),
      ),
      actions: [TextButton(onPressed: ()=> authData.logoutUser().then((result) {
ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(result,style: Theme.of(context).textTheme.titleMedium,),
              backgroundColor: Colors.white70,
            ));
            Navigator.of(ctx).pop();
      } )  , child: Text('Да', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: CupertinoColors.systemRed),),),TextButton(onPressed: ()=>Navigator.of(ctx).pop(), child: Text('Отмена', style: Theme.of(context).textTheme.bodyMedium,),)],
    );
  }

  Widget _buildProfileView(BuildContext ctx) {
    //print(authData);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
              backgroundColor: Colors.transparent,
              expandedHeight: 150,
              flexibleSpace: FlexibleSpaceBar(
                expandedTitleScale: 1.2,
                centerTitle: false,
                title: Text(
                'Профиль',
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge!
                    .copyWith(fontWeight: FontWeight.bold,color: Colors.white),
              ),
              ),
            ),
          SliverGrid.extent(maxCrossAxisExtent: 300,childAspectRatio: 4/3,children: [
            ProfileItem(
              title: authData.username ?? 'Ошибка',
              subtext: 'Твоё имя',
              onTap: () {
                Navigator.of(context).pushNamed(ChangeDataScreen.routeName);
              },
              isGrid: true,
            ),
            ProfileItem(
              title: authData.phoneNumber ?? 'Ошибка',
              subtext: 'Твой номер',
              onTap: () {
                Navigator.of(context).pushNamed(ChangeDataScreen.routeName);
              },
              isGrid: true,
            ),
          ],),
          SliverToBoxAdapter(child: 
            ProfileItem(
              title: 'Мои параметры',
              subtext: '',
              onTap: () {
                  Navigator.of(context).pushNamed(ParametersScreen.routeName,arguments: [false]);
                },
              isGrid: false,
            ),
          ),
          SliverGrid.extent(maxCrossAxisExtent: 300,childAspectRatio: 4/3,children: [
            ProfileItem(
              title: 'Прогресс программ',
              subtext: '',
              onTap: () {
                Navigator.of(context).pushNamed(ProgramsProgressScreen.routeName);
              },
              isGrid: true,
            ),
            ProfileItem(
              title: 'Выйти',
              subtext: '',
              onTap: ()=>showDialog(context: context, builder: _buildConfirmDialog),
              isGrid: true,
            ),
            ProfileItem(
              title: 'Сменить все версии',
              subtext: '',
              onTap: authData.changeAllVersions,
              isGrid: true,
            ),
            const ProfileItem(
              title: 'Удалить таблицы',
              subtext: '',
              onTap: DBHelper.deleteTables,
              isGrid: true,
            ),
            ProfileItem(
              title: 'Удалить статы',
              subtext: '',
              onTap: authData.deleteStats,
              isGrid: true,
            ),
            ProfileItem(
              title: 'Панель',
              subtext: '',
              onTap: ()=>Navigator.of(ctx).pushNamed(ControlScreen.routeName),
              isGrid: true,
            ),

          ],),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    authData = Provider.of<UserDataProvider>(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: const AssetImage('assets/images/backgrounds/bg_9.jpg'),opacity: authData.isAuth ? 0.5 : 1,fit: BoxFit.cover),
        ),
        child: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(),builder: (_,snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const CustomScrollView(slivers: [SliverToBoxAdapter(child: Center(child: Text('Загрузка'),),)],);
          }
          if(snapshot.data == null){
            return const PhoneAuthView();
          }
          return _buildProfileView(context);
        }),
      ),
    );
  }
}