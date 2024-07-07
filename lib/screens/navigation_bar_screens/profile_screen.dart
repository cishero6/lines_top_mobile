// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lines_top_mobile/helpers/db_helper.dart';
import 'package:lines_top_mobile/helpers/phone_auth_status.dart';
import 'package:lines_top_mobile/providers/blog_provider.dart';
import 'package:lines_top_mobile/providers/exercises_provider.dart';
import 'package:lines_top_mobile/providers/programs_provider.dart';
import 'package:lines_top_mobile/providers/trainings_provider.dart';
import 'package:lines_top_mobile/screens/profile_screens/control_screen.dart';
import 'package:lines_top_mobile/screens/profile_screens/parameters_screen.dart';
import 'package:lines_top_mobile/screens/profile_screens/programs_progress_screen.dart';
import 'package:lines_top_mobile/widgets/list_items/profile_item.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const routeName = '/profile';
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late UserProvider authData;
  late bool _isAdmin = false;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  TextEditingController _nameTextEditingController = TextEditingController();

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _opacityAnimation =
        Tween(begin: 0.0, end: 1.0).animate(_animationController);
    _slideAnimation =
        Tween(begin: const Offset(0, 1), end: const Offset(0.0, 0.0)).animate(
            CurvedAnimation(
                parent: _animationController,
                curve: Curves.fastLinearToSlowEaseIn));
    authData = Provider.of<UserProvider>(context, listen: false);
    if (authData.username == 'zoPUTyCKyxbMEAIECGzB') {
      _isAdmin = true;
    }
    _animationController.forward();
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
                  .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
        SliverGrid.extent(
          maxCrossAxisExtent: maxExtent * 2,
          childAspectRatio: 5 / 3,
          children: [
            ProfileItem(
              title: 'Мои параметры',
              subtext: '',
              onTap: () {
                Navigator.of(context)
                    .pushNamed(ParametersScreen.routeName, arguments: [false]);
              },
              isGrid: false,
            ),
          ],
        ),
        SliverGrid.extent(
          maxCrossAxisExtent: maxExtent,
          childAspectRatio: 4 / 3,
          children: [
            // ProfileItem(
            //   title: authData.username ?? 'Ошибка',
            //   subtext: 'Твоё имя',
            //   onTap: () {
            //     Navigator.of(context).pushNamed(ChangeDataScreen.routeName);
            //   },
            //   width: size.width / (size.width / maxExtent).ceil(),
            //   maxLines: 1,
            //   isGrid: true,
            // ),
            ProfileItem(
              title: 'Прогресс программ',
              subtext: '',
              onTap: () {
                Navigator.of(context)
                    .pushNamed(ProgramsProgressScreen.routeName);
              },
              width: size.width / (size.width / maxExtent).ceil(),
              isGrid: true,
            ),
            ProfileItem(
              title: 'Настройки',
              subtext: '',
              onTap: () {
                //Navigator.of(context).pushNamed(ChangeDataScreen.routeName);
              },
              width: size.width / (size.width / maxExtent).ceil(),
              isGrid: true,
            ),
            if (_isAdmin)
              ProfileItem(
                title: 'Удалить таблицы',
                subtext: '',
                onTap: DBHelper.deleteTables,
                width: size.width / (size.width / maxExtent).ceil(),
                isGrid: true,
              ),
            if (_isAdmin)
              ProfileItem(
                title: 'Удалить статы',
                subtext: '',
                onTap: () {},
                width: size.width / (size.width / maxExtent).ceil(),
                isGrid: true,
              ),
            if (_isAdmin)
              ProfileItem(
                title: 'Панель',
                subtext: '',
                onTap: () =>
                    Navigator.of(ctx).pushNamed(ControlScreen.routeName),
                width: size.width / (size.width / maxExtent).ceil(),
                isGrid: true,
              ),
            if (_isAdmin)
              ProfileItem(
                title: 'pre_compile',
                subtext: '',
                onTap: () async {
                  await Provider.of<BlogProvider>(context, listen: false)
                      .compileDatabaseIntoPreload();
                  await Provider.of<ExercisesProvider>(context, listen: false)
                      .compileDatabaseIntoPreload();
                  await Provider.of<TrainingsProvider>(context, listen: false)
                      .compileDatabaseIntoPreload();
                  await Provider.of<ProgramsProvider>(context, listen: false)
                      .compileDatabaseIntoPreload();
                },
                width: size.width / (size.width / maxExtent).ceil(),
                isGrid: true,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAskName() {
    return SizedBox(
      width: double.infinity,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              Text(
                'Введите ваше имя\n',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              UnconstrainedBox(
                  child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: CupertinoTextField(
                  controller: _nameTextEditingController,
                  prefix: Text(
                    ' ',
                    style: Theme.of(context).textTheme.bodyLarge!,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              )),
              UnconstrainedBox(
                child: Padding(
                  padding: const EdgeInsets.all(22.0),
                  child: ElevatedButton(
                      onPressed: () {
                          authData.setName(_nameTextEditingController.text);
                          isReg = false;
                          Navigator.of(context).pushReplacementNamed(ParametersScreen.routeName);
                      },
                      child: Text(
                        'Готово',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    authData = Provider.of<UserProvider>(context);
    if (authData.username == null) {
      return Scaffold(
        body: Container(
          //alignment: Alignment.center,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/backgrounds/bg_9.jpg'),
                fit: BoxFit.cover),
          ),
          child: _buildAskName(),
        ),
      );
    }
    return Scaffold();
  }

//  @override
//   Widget build(BuildContext context) {
//     authData = Provider.of<UserProvider>(context,listen: true);
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(image: const AssetImage('assets/images/backgrounds/bg_9.jpg'),opacity: authData.username !=null ? 0.5 : 1,fit: BoxFit.cover),
//         ),
//         child: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(),builder: (_,snapshot) {
//           if(snapshot.connectionState == ConnectionState.waiting){
//             return CustomScrollView(slivers: [SliverToBoxAdapter(child: Center(child: Text('Загрузка',style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),),),)],);
//           }
//           if(snapshot.data == null){
//             return const PhoneAuthView();
//           }
//           if(authData.phoneNumber == null){
//             return const CustomScrollView(slivers: [SliverToBoxAdapter(child: Center(child: Text(''),),)],);
//           }
//           return _buildProfileView(context);
//         }),
//       ),
//     );
//   }
}
