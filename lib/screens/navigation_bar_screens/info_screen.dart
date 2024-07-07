// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
            SliverAppBar.large(surfaceTintColor: Colors.black,backgroundColor: Colors.transparent,title: Text('Подробнее',style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white,fontWeight: FontWeight.bold),),),
            SliverToBoxAdapter(child: SlideTransition(
              position: _postitionAnimation,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Column(children: [
                  const Divider(thickness: 4,color: Colors.black12,),
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
                      image: AssetImage('assets/images/backgrounds/about_me.jpg'),
                      fit: BoxFit.contain,
                      width: 200,
                      //height: 400,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 40),
                      child: Text(
                        '\t\t\tМеня зовут Анастасия, и я профессиональная спортсменка и тренер по фитнесу. По первому образованию я инженер систем обеспечения движения поездов, а следующие дипломы - персональный тренер и преподаватель 🤓\n\t\t\tСразу после учебы, я пошла работать инженером в области Автоматики и телемеханики. Участвовала в проектировании Крымского моста и многих других объектов железнодорожной инфраструктуры России, это было круто 👍 \n\t\t\tНо после нескольких лет офисной работы, я поняла, что это не для меня, и я хочу иметь больше времени для себя и на себя 🧘‍♀️ Так начался мой новый путь, осознанное погружение в вопросы здоровья, красоты, питания и фитнеса 💓\n\n\t\t\tИ вот уже пятый год, я изучала и изучаю все составляющие женского благополучия:\n▫️красота, \n▫️здоровье,  \n▫️фитнес,\n▫️диетология,\n▫️а также гармония в себе и вокруг себя. \n\n\t\t\tСамыми простыми и действенными формулами красоты женского тела и гармонии, я хочу поделиться с тобой уже сейчас ❤️\n\n\t\t\tА также о моей удивительной спортивной «карьере»🏐: в параллель всему, что я уже описала: отличной учебе в техническом университете📕, далее работе в офисе👩‍💻, а потом смене профессии, - в 18 лет я начинаю заниматься спортом  с нуля. \n\t\t\tИ пару лет я самостоятельно, постоянно тренируюсь и учусь играть в волейбол. Как итог: тренер выбирает меня капитаном сборной университета (среди девушек, выпустившихся из спортшкол и играющих более 10 лет) 🏆\nЕще через несколько лет, я стала участницей этапов Чемпионата России по пляжному волейболу (уже среди профессональных спортсменов, посвятивших этому занятию всю свою жизнь)🇷🇺\nВ  этот период я получила колоссальный опыт в нюансах построения тренировочного процесса для проф. спортсменов (на увеличение силовых показателей, показателей выносливости, а также улучшение и поддержание технических навыков игры - и все это одновременно📈) и бесценные советы от звезд мирового пляжного волейбола о нюансах подготовки, игры, здоровья и психологии. \nПопробовала это все на себе! И даже заработала деньги на пляжном волейболе, о чем никогда не могла бы и подумать!\nЦели перед собой ставим только мы сами!',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white),
                        maxLines: 100,
                      ),
                    ),
                  const Divider(thickness: 4,color: Colors.black12,),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Text('Контакты',style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),textAlign: TextAlign.center,),
                  ),
                  Padding(padding: const EdgeInsets.all(10),child: Text('Почта - nusha485@mail.ru',style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),textAlign: TextAlign.center,),),
                  Padding(padding: const EdgeInsets.only(top:10,bottom: 60),child: GestureDetector(onTap: ()=>launchUrl(Uri.parse('http://t.me/stasy_ilc'),mode: LaunchMode.inAppBrowserView),child: Text('Telegram - @stasy_ilc',style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.lightBlue),textAlign: TextAlign.center,)),),
                  ]),
              ),
            ),
            ),

        ],),
      ),
    );
  }
}