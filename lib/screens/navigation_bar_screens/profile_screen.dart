import 'package:flutter/material.dart';
import 'package:lines_top_mobile/providers/user_data_provider.dart';
import 'package:lines_top_mobile/screens/navigation_bar_screens/profile_screens/auth_screen.dart';
import 'package:lines_top_mobile/screens/navigation_bar_screens/profile_screens/control_screen.dart';
import 'package:provider/provider.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const routeName = '/profile';
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {





  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<UserDataProvider>(context);
    
    if (!authData.isAuth) {
      return const AuthScreen();
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            automaticallyImplyLeading: false,
            elevation: 10,
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Text(
              'Профиль',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const Divider(
                  thickness: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'ID пользователя',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.black54),
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: FittedBox(
                          child: Text(
                            authData.userId!,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(
                  thickness: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Имя пользователя',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.black54),
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            authData.userName!,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Изменить',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const Divider(
                  thickness: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Почта',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.black54),
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            authData.email!,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Изменить',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const Divider(
                  thickness: 4,
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pushNamed(ControlScreen.routeName),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Панель управления',style: Theme.of(context).textTheme.titleLarge,),
                        const Icon(Icons.arrow_forward_ios,color: Colors.black87,),
                    ],),
                  ),
                ),
                const Divider(
                  thickness: 4,
                ),
                UnconstrainedBox(
                  child: ElevatedButton.icon(
                      onPressed: () async {
                        await authData.changeAllVersions();
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Успешно',style: Theme.of(context).textTheme.bodyMedium,)));
                      },
                      icon: const Icon(Icons.logout,color: Colors.black87,),
                      label: Text('Поменять все версиий',style: Theme.of(context).textTheme.bodyMedium,)),
                ),
                const Divider(
                  thickness: 4,
                ),
                UnconstrainedBox(
                  child: ElevatedButton.icon(
                      onPressed: () async {
                        bool result = await authData.logoutUser();
                        if (!result) {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).clearSnackBars();
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Что-то пошло не так!',style: Theme.of(context).textTheme.bodyMedium,)));
                        }
                      },
                      icon: const Icon(Icons.logout,color: Colors.black87,),
                      label: Text('Выйти',style: Theme.of(context).textTheme.bodyMedium,)),
                ),
                const Divider(
                  thickness: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
