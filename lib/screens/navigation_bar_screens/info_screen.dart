// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});
  static const routeName = '/info';
  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> with TickerProviderStateMixin{
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _postitionAnimation;



  @override
  void initState() {
    _animationController = AnimationController(duration: const Duration(milliseconds: 300),vsync: this);
    _opacityAnimation = Tween(begin: 0.0,end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.linear));
    _postitionAnimation = Tween(begin: const Offset(0.0,0.5),end: const Offset(0.0, 0.0)).animate(CurvedAnimation(parent: _animationController, curve: Curves.fastLinearToSlowEaseIn));
    _animationController.forward();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Colors.black,image: DecorationImage(image: AssetImage('assets/images/backgrounds/bg_10.jpg'),fit: BoxFit.cover,opacity: 0.5,)),
        child: CustomScrollView(
          
          slivers: [
            SliverAppBar.large(surfaceTintColor: Colors.black,backgroundColor: Colors.transparent,title: Text('О нас',style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white,fontWeight: FontWeight.bold),),),
            SliverToBoxAdapter(child: SlideTransition(
              position: _postitionAnimation,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Text('Автор проекта',style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),textAlign: TextAlign.center,),
                  ),
                  const Divider(thickness: 4,color: Colors.black12,),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 15,top:10),
                      child: Text(
                        'Анастасия',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),
                      ),
                    ),
                    const Image(
                      image: AssetImage('assets/images/backgrounds/bg_12.jpg'),
                      fit: BoxFit.contain,
                      width: 200,
                      //height: 400,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 40),
                      child: Text(
                        '     Меня зовут Анастасия, по первому образованию я инженер путей сообщения.\n\n     После окончания университета, я пошла работать в офис инженером в области Автоматики и телемеханики.\n     Я участвовала в проектировании Крымского моста и многих других объектов железнодорожной инфраструктуры России, это было круто\n     Спортом я начала заниматься с 18 лет, сперва это было просто увлечение и хорошая привычка (танцы, волейбол).\n\n     Спустя пару лет офисной работы за компьютером, я поняла, что чтобы сохранить фигуру, красоту и здоровье необходимо более осознанно подойти к вопросу спорта, питания и ухода за собой. \n     Здесь и началось мое погружение в сферу фитнеса и здоровья.\n     За последние 4 года я изучала все составляющие женского благополучия:\n   o красота, \n   o здоровье, \n   o фитнес,\n   o диетология,\n   o а также гармония в себе и вокруг себя. \n\n     Параллельно с этим у меня получилось на какое-то время попробовать себя в качестве профессионального игрока в пляжный волейбол, а это, кстати, также дало мне много дополнительных знаний о работе нашего организма под воздействием высоких нагрузок, о грамотном восстановлении и о сбалансированном питании в эти периоды.\n     Теперь, когда я нашла формулу красоты женского тела и гармонии, я хочу поделиться с вами ❤️',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white),
                        maxLines: 100,
                      ),
                    ),
                  const Divider(thickness: 4,color: Colors.black12,),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Text('Контакты',style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),textAlign: TextAlign.center,),
                  ),

                  const Divider(thickness: 4,color: Colors.black12,),

                  ]),
              ),
            ),
            ),

        ],),
      ),
    );
  }
}