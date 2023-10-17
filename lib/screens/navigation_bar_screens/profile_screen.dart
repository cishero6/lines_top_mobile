// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lines_top_mobile/helpers/db_helper.dart';
import 'package:lines_top_mobile/providers/blog_provider.dart';
import 'package:lines_top_mobile/providers/exercises_provider.dart';
import 'package:lines_top_mobile/providers/programs_provider.dart';
import 'package:lines_top_mobile/providers/trainings_provider.dart';
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
  late bool _isAdmin = false;

  @override
  void initState() {
    authData = Provider.of<UserDataProvider>(context,listen: false);
    if(authData.phoneNumber == '+79313733536'){
      _isAdmin = true;
    }
    super.initState();
  }



  Widget _buildProfileView(BuildContext ctx) {
    //print(authData);
    var size = MediaQuery.of(context).size;
    double maxExtent = 300;
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
          SliverGrid.extent(maxCrossAxisExtent: maxExtent,childAspectRatio: 4/3,children: [
            ProfileItem(
              title: authData.username ?? 'Ошибка',
              subtext: 'Твоё имя',
              onTap: () {
                Navigator.of(context).pushNamed(ChangeDataScreen.routeName);
              },
              width: size.width/(size.width/maxExtent).ceil(),
              maxLines: 1,
              isGrid: true,
            ),
            ProfileItem(
              title: authData.phoneNumber ?? 'Ошибка',
              subtext: 'Твой номер',
              onTap: () {
                Navigator.of(context).pushNamed(ChangeDataScreen.routeName);
              },
              width: size.width/(size.width/maxExtent).ceil(),
              maxLines: 1,
              isGrid: true,
            ),
          ],),
          SliverGrid.extent(maxCrossAxisExtent: maxExtent*2,childAspectRatio: 5/3,children: [ 
            ProfileItem(
              title: 'Мои параметры',
              subtext: '',
              onTap: () {
                  Navigator.of(context).pushNamed(ParametersScreen.routeName,arguments: [false]);
                },
              isGrid: false,
            ),],
          ),
          SliverGrid.extent(maxCrossAxisExtent: maxExtent,childAspectRatio: 4/3,children: [
            ProfileItem(
              title: 'Прогресс программ',
              subtext: '',
              onTap: () {
                Navigator.of(context).pushNamed(ProgramsProgressScreen.routeName);
              },
              width: size.width/(size.width/maxExtent).ceil(),
              isGrid: true,
            ),
            ProfileItem(
              title: 'Настройки',
              subtext: '',
              onTap: (){Navigator.of(context).pushNamed(ChangeDataScreen.routeName);},
              width: size.width/(size.width/maxExtent).ceil(),
              isGrid: true,
            ),
            if(_isAdmin) ProfileItem(
              title: 'Сменить все версии',
              subtext: '',
              onTap: authData.changeAllVersions,
              width: size.width/(size.width/maxExtent).ceil(),
              isGrid: true,
            ),
            if(_isAdmin) ProfileItem(
              title: 'Удалить таблицы',
              subtext: '',
              onTap: DBHelper.deleteTables,
              width: size.width/(size.width/maxExtent).ceil(),
              isGrid: true,
            ),
            if(_isAdmin) ProfileItem(
              title: 'Удалить статы',
              subtext: '',
              onTap: authData.deleteStats,
              width: size.width/(size.width/maxExtent).ceil(),
              isGrid: true,
            ),
            if(_isAdmin) ProfileItem(
              title: 'Панель',
              subtext: '',
              onTap: ()=>Navigator.of(ctx).pushNamed(ControlScreen.routeName),
              width: size.width/(size.width/maxExtent).ceil(),
              isGrid: true,
            ),
            if(_isAdmin) ProfileItem(
              title: 'pre_compile',
              subtext: '',
              onTap: ()async{
                await Provider.of<BlogProvider>(context,listen: false).compileDatabaseIntoPreload();
                await Provider.of<ExercisesProvider>(context,listen: false).compileDatabaseIntoPreload();
                await Provider.of<TrainingsProvider>(context,listen: false).compileDatabaseIntoPreload();
                await Provider.of<ProgramsProvider>(context,listen: false).compileDatabaseIntoPreload();
              },
              width: size.width/(size.width/maxExtent).ceil(),
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
          if(authData.phoneNumber == null){
            return const CustomScrollView(slivers: [SliverToBoxAdapter(child: Center(child: Text(''),),)],);
          }
          return _buildProfileView(context);
        }),
      ),
    );
  }
}