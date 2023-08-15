import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lines_top_mobile/helpers/db_helper.dart';
import 'package:lines_top_mobile/screens/profile_screens/control_screen.dart';
import 'package:lines_top_mobile/widgets/auth_view.dart';
import 'package:lines_top_mobile/widgets/list_items/profile_item.dart';
import 'package:provider/provider.dart';

import '../../providers/user_data_provider.dart';

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

  Widget _buildProfileView(BuildContext ctx) {
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
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              ),
            ),
          SliverGrid.extent(maxCrossAxisExtent: 300,childAspectRatio: 4/3,children: [
            ProfileItem(
              title: authData.userName!,
              subtext: 'Изменить',
              onTap: () {},
              isGrid: true,
            ),
            ProfileItem(
              title: authData.email!,
              subtext: 'Изменить',
              onTap: () {},
              isGrid: true,
            ),
          ],),
          SliverToBoxAdapter(child: 
                      ProfileItem(
              title: 'Мои параметры',
              subtext: '',
              onTap: () {},
              isGrid: false,
            ),
          ),
          SliverGrid.extent(maxCrossAxisExtent: 300,childAspectRatio: 4/3,children: [
            ProfileItem(
              title: 'Прогресс программ',
              subtext: '',
              onTap: () {},
              isGrid: true,
            ),
            ProfileItem(
              title: 'Выйти',
              subtext: '',
              onTap: authData.logoutUser,
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
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/images/backgrounds/bg_9.jpg'),opacity: 0.5,fit: BoxFit.cover),
      ),
      child: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(),builder: (_,snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return const SizedBox();
        }
        if(!snapshot.hasData){
          return const AuthView();
        }
        return _buildProfileView(context);
      }),
    );
  }
}