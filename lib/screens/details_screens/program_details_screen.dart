import 'package:flutter/material.dart';
import '../../models/program.dart';
import '../program_process_screens/trainings_list_screen.dart';

class ProgramDetailsScreen extends StatefulWidget {
  static const routeName = '/programs/details';
  final Program program;
  const ProgramDetailsScreen(this.program, {super.key});

  @override
  State<ProgramDetailsScreen> createState() => _ProgramDetailsScreenState();
}

class _ProgramDetailsScreenState extends State<ProgramDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _firstController;
  late AnimationController _secondController;
  late AnimationController _thirdController;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _subtextSlideAnimation;
  late Animation<double> _subtextFadeAnimation;
  late Animation<Offset> _bodySlideAnimation;
  late Animation<double> _bodyFadeAnimation;
  late Animation<double> _buttonScaleAnimation;

  bool _disposed = false;

  void _animate() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!_disposed) {_firstController.forward();}
    await Future.delayed(const Duration(milliseconds: 400));
    if (!_disposed) {_secondController.forward();}
    await Future.delayed(const Duration(milliseconds: 400));
    if (!_disposed) {_thirdController.forward();}
  }

  void _tryStart() {
    // if (!Provider.of<UserDataProvider>(context,listen: false).isAuth) {
    //   ScaffoldMessenger.of(context).clearSnackBars();
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       backgroundColor: Colors.white70,
    //       content: Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceAround,
    //         children: [
    //           Text(
    //             'Вы не вошли в аккаунт!',
    //             style: Theme.of(context).textTheme.bodyMedium,
    //           ),
    //           TextButton(
    //               onPressed: () {
    //                 Navigator.of(context)
    //                     .pushReplacementNamed(ProfileScreen.routeName);
    //                 ScaffoldMessenger.of(context).clearSnackBars();
    //                 Provider.of<BottomNavigationProvider>(context,
    //                         listen: false)
    //                     .setIndex(2);
    //               },
    //               child: Text(
    //                 'Войти',
    //                 style: Theme.of(context).textTheme.bodyMedium,
    //               ),),
    //         ],
    //       ),
    //     ),
    //   );
    //   return;
    // }
    Navigator.of(context).pushNamed(TrainingsListScreen.routeName,arguments: [widget.program]);
  }

  @override
  void initState() {
    _firstController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _secondController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _thirdController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _titleFadeAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _firstController, curve: Curves.fastLinearToSlowEaseIn));
    _titleSlideAnimation =
        Tween(begin: const Offset(1.0, 0.0), end: const Offset(0.0, 0.0))
            .animate(CurvedAnimation(
                parent: _firstController,
                curve: Curves.fastLinearToSlowEaseIn));
    _subtextFadeAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _secondController, curve: Curves.fastLinearToSlowEaseIn));
    _subtextSlideAnimation =
        Tween(begin: const Offset(0.0, 1.0), end: const Offset(0.0, 0.0))
            .animate(CurvedAnimation(
                parent: _secondController,
                curve: Curves.fastLinearToSlowEaseIn));
    _bodyFadeAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _thirdController, curve: Curves.fastLinearToSlowEaseIn));
    _bodySlideAnimation =
        Tween(begin: const Offset(0.0, 1.0), end: const Offset(0.0, 0.0))
            .animate(CurvedAnimation(
                parent: _thirdController,
                curve: Curves.fastLinearToSlowEaseIn));
    _buttonScaleAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _thirdController, curve: Curves.fastLinearToSlowEaseIn));
    super.initState();
  }

  @override
  void dispose() {
    _disposed = true;
    if (_firstController.isAnimating) {
      _firstController.stop();
    }
    _firstController.dispose();
    if (_secondController.isAnimating) {
      _secondController.stop();
    }
    _secondController.dispose();
    if (_thirdController.isAnimating) {
      _thirdController.stop();
    }
    _thirdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _animate();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Colors.black,image: DecorationImage(image: AssetImage('assets/images/backgrounds/bg_30.jpg'),fit: BoxFit.cover,opacity: 0.7)),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              pinned: false,
              backgroundColor: Colors.transparent,
              title: SlideTransition(
                position: _titleSlideAnimation,
                child: FadeTransition(
                  opacity: _titleFadeAnimation,
                  child: Text(
                    widget.program.title,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold,color: Colors.white),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SlideTransition(
                position: _subtextSlideAnimation,
                child: FadeTransition(
                  opacity: _subtextFadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 40),
                    child: Text(
                      widget.program.subtext,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SlideTransition(
                position: _bodySlideAnimation,
                child: FadeTransition(
                  opacity: _bodyFadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                    ),
                    child: Text(
                      widget.program.bodyText,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: UnconstrainedBox(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ScaleTransition(
                      scale: _buttonScaleAnimation,
                      child: ElevatedButton(
                          onPressed:_tryStart,
                          child: Text(
                            'Начать',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),
                          ))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
