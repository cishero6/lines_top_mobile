import 'package:flutter/material.dart';
import 'package:lines_top_mobile/models/blog_post.dart';

// ignore: must_be_immutable
class BlogPostDetailsScreen extends StatefulWidget {
  final BlogPost blogPost;
  static const routeName = '/blog_details';

  BlogPostDetailsScreen(this.blogPost, {super.key});

  @override
  State<BlogPostDetailsScreen> createState() => _BlogPostDetailsScreenState();
}

class _BlogPostDetailsScreenState extends State<BlogPostDetailsScreen>
    with TickerProviderStateMixin {
  List<String> _formattedText = [];

  final List<Widget> _widgets = [];

  late AnimationController _firstController;
  late AnimationController _secondController;
  late AnimationController _thirdController;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _subtextSlideAnimation;
  late Animation<double> _subtextFadeAnimation;
  //late Animation<double> _buttonScaleAnimation;
  final List<Map<String, Animation>> _widgetsAnimations = [];

  

  bool _disposed = false;
  bool _isBuilt = false;
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
    //_buttonScaleAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
     //   parent: _thirdController, curve: Curves.fastLinearToSlowEaseIn));
    super.initState();
  }


/*
  void _toggleSaved(bool contains) async {
    if (!Provider.of<UserDataProvider>(context, listen: false).isAuth) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).cardColor,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Вы не вошли в аккаунт!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed(ProfileScreen.routeName);
                    ScaffoldMessenger.of(context).clearSnackBars();
                    Provider.of<BottomNavigationProvider>(context,
                            listen: false)
                        .setIndex(1);
                  },
                  child: Text(
                    'Войти',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ))
            ],
          ),
        ),
      );
      return;
    }
    if (!contains) {
      await Provider.of<UserDataProvider>(context, listen: false)
          .addSavedId(widget.blogPost.id);
      setState(() {});
    } else {
      await Provider.of<UserDataProvider>(context, listen: false)
          .removeSavedId(widget.blogPost.id);
      setState(() {});
    }
  }
  */

  void _constructWidgets(BuildContext ctx) {
    int index = 1;
    AnimationController tempController;
    Animation<double> tempFade;
    Animation<Offset> tempSlide;
    for (String element in _formattedText) {
      tempController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1000),
      );
      tempFade = Tween(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
                parent: tempController, curve: Curves.fastLinearToSlowEaseIn),
          );
      tempSlide =Tween(begin: const Offset(0.0, 1.0), end: const Offset(0.0, 0.0))
                  .animate(
            CurvedAnimation(
                parent: tempController, curve: Curves.fastLinearToSlowEaseIn),
          );
      _widgetsAnimations.add(
        {
          'controller': tempController,
          'fade': tempFade,
          'slide': tempSlide,
        },
      );

      if (element.trim().startsWith('//')) {
        _widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: SlideTransition(
              position: _widgetsAnimations.last['slide'] as Animation<Offset>,
              child: FadeTransition(
                opacity: _widgetsAnimations.last['fade'] as Animation<double>,
                child: Image.file(
                  widget.blogPost.images[index],
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
        index++;
        if (index == widget.blogPost.images.length) index--;
      } else {
        _widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: SlideTransition(
              position: _widgetsAnimations.last['slide'] as Animation<Offset>,
              child: FadeTransition(
                opacity: _widgetsAnimations.last['fade'] as Animation<double>,
                child: Text(
                  element,
                  style: Theme.of(ctx).textTheme.bodyLarge!.copyWith(color: Colors.white,fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize!+1),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
          ),
        );
      }
    }
  }

  void _animate()async{
    await Future.delayed(const Duration(milliseconds: 100));
    if (!_disposed) {_firstController.forward();}
    await Future.delayed(const Duration(milliseconds: 400));
    if (!_disposed) {_secondController.forward();}
    await Future.delayed(const Duration(milliseconds: 200));
    for(var map in _widgetsAnimations){
      await Future.delayed(const Duration(milliseconds: 200));
      if (!_disposed) (map['controller'] as AnimationController).forward();
    }
    if (!_disposed) {_thirdController.forward();}
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
    for(var map in _widgetsAnimations){
      if ((map['controller'] as AnimationController).isAnimating) {
        (map['controller'] as AnimationController).stop();
      }
      (map['controller'] as AnimationController).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /*
    bool contains = Provider.of<UserDataProvider>(context, listen: false)
                .savedBlogPostIds ==
            null
        ? false
        : Provider.of<UserDataProvider>(context, listen: false)
            .savedBlogPostIds!
            .contains(widget.blogPost.id);

    */
    _formattedText = widget.blogPost.bodyText.split('|');
    if(!_isBuilt){
    _constructWidgets(context);
    _animate();
    }

    _isBuilt= true;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Colors.black,image: DecorationImage(image: widget.blogPost.images.isEmpty?AssetImage('assets/content/blog_posts/${widget.blogPost.id}_0'): FileImage(widget.blogPost.images.first) as ImageProvider,fit: BoxFit.cover,opacity: 0.6)),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              pinned:false,
              centerTitle: true,
              backgroundColor: Colors.transparent,
              title: SlideTransition(
                position: _titleSlideAnimation,
                child: FadeTransition(
                  opacity: _titleFadeAnimation,
                  child: Text(
                    widget.blogPost.title,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold,color:Colors.white),
                  ),
                ),
              ),
              scrolledUnderElevation: 0,
            ),
            SliverToBoxAdapter(
              child: UnconstrainedBox(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: 200, minHeight: 60, minWidth: 120,maxWidth: MediaQuery.of(context).size.width*0.9),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30,bottom:13,left:13.0,right: 13),
                    child: SlideTransition(
                      position: _subtextSlideAnimation,
                      child: FadeTransition(
                        opacity: _subtextFadeAnimation,
                        child: Text(
                          widget.blogPost.shortDesc,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverList.list(children: _widgets),
            /*
             SliverToBoxAdapter(
               child: UnconstrainedBox(
                 child: ScaleTransition(
                  scale: _buttonScaleAnimation,
                   child: ElevatedButton.icon(
                          label: Text(contains ? 'Сохранено' : 'Сохранить',style: Theme.of(context).textTheme.bodyMedium,),
                          onPressed: () => _toggleSaved(contains),
                          
                          icon: contains
                              ? const Icon(Icons.bookmark,color: Colors.black54,)
                              : const Icon(Icons.bookmark_outline,color: Colors.black54),
                              ),
                 ),
               ),
             ),
             */
             const SliverToBoxAdapter(child: SizedBox(height: 50),),
          ],
        ),
      ),
    );
  }
}
