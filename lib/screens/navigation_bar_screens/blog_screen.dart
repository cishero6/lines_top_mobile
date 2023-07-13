import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lines_top_mobile/models/blog_post.dart';
import 'package:lines_top_mobile/providers/blog_provider.dart';
import 'package:lines_top_mobile/providers/user_data_provider.dart';
import 'package:lines_top_mobile/screens/navigation_bar_screens/profile_screens/auth_screen.dart';
import 'package:lines_top_mobile/widgets/flexible_space.dart';
import 'package:provider/provider.dart';
import '../../widgets/list_items/blog_list_item.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});
  static const routeName = '/blog';
  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> with TickerProviderStateMixin {
  List<BlogPost> _items = [];
  List<BlogPost> _candidatesItems = [];
  List<BlogPost> _shownItems = [];
  bool _showSaved = false;
  bool _searchActivated = false;
  final FocusNode _focusNode = FocusNode();
  bool _isBelow = false;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _slideAnimation =
        Tween(begin: const Offset(0.34, 1.2), end: const Offset(0.0, 0.0))
            .animate(CurvedAnimation(
                parent: _animationController,
                curve: Curves.fastEaseInToSlowEaseOut));
    _items = Provider.of<BlogProvider>(context, listen: false).items;
    _candidatesItems = [..._items];
    _shownItems = [..._candidatesItems];
    super.initState();
  }

  void _tryToggleSaved() {
    if (!_showSaved &&
        !Provider.of<UserDataProvider>(context, listen: false).isAuth) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Theme.of(context).cardColor,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Вы не вошли в аккаунт!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed(AuthScreen.routeName),
                  child: Text(
                    'Войти',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ))
            ],
          )));
      return;
    }
    if (!_showSaved) {
      var savedIds = Provider.of<UserDataProvider>(context, listen: false)
          .savedBlogPostIds;
      _candidatesItems = [
        ..._items.where((element) => savedIds!.contains(element.id)).toList()
      ];
      _showSaved = true;
      if (!_searchActivated) {
        _shownItems = [..._candidatesItems];
      } else {
        _trySearch(_textController.text);
      }
      setState(() {});
    } else {
      _candidatesItems = [..._items];
      _showSaved = false;
      if (!_searchActivated) {
        _shownItems = [..._candidatesItems];
      } else {
        _trySearch(_textController.text);
      }
      setState(() {});
    }
    return;
  }

  void _pressSearch() {
    setState(() {
      _searchActivated = true;
    });
    _focusNode.requestFocus();
  }

  void _submitSearch() {
    if (_textController.text.isEmpty) {
      _searchActivated = false;
      setState(() {});
    }
    _focusNode.unfocus();
    return;
  }

  void _trySearch(String value) {
    if (value.length <= 2) {
      _shownItems = [..._candidatesItems];
      setState(() {});
      return;
    }
    _shownItems = [
      ..._candidatesItems
          .where((element) => element.title.contains(value))
          .toList()
    ];
    setState(() {});
    return;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int waitTimer = -200;

    return Scaffold(
      body: NotificationListener(
        onNotification: (t) {
          if (t is ScrollUpdateNotification) {
            double value = 5;
            if (_scrollController.position.pixels > value && !_isBelow) {
              _animationController.forward();
              setState(() => _isBelow = true);
            }
            if (_scrollController.position.pixels < value && _isBelow) {
              _animationController.reverse();
              setState(() => _isBelow = false);
            }
          }
          return true;
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              key: ValueKey('blog'),
              automaticallyImplyLeading: false,
              scrolledUnderElevation: 0,
              flexibleSpace: FlexibleSpace(key: const ValueKey('blog'),title: 'Блог', children: [
                SlideTransition(
                  transformHitTests: true,
                  position: _slideAnimation,
                  child: GestureDetector(
                    onTap: _tryToggleSaved,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.fastEaseInToSlowEaseOut,
                      width: _isBelow ? 42 : 150,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: const Color.fromARGB(120, 0, 0, 0),
                          )),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              !_showSaved
                                  ? Icons.bookmark_outline
                                  : Icons.bookmark,
                              size: 24,
                              color: const Color.fromARGB(120, 0, 0, 0),
                            ),
                            Flexible(
                              fit: FlexFit.tight,
                              child: Text(
                                _isBelow ? '' : 'Сохраненные',
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color:
                                            const Color.fromARGB(120, 0, 0, 0)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: _searchActivated ? Colors.white : Colors.white70,
                      borderRadius: BorderRadius.circular(30)),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _pressSearch,
                        splashRadius: 0.1,
                        icon: const Icon(Icons.search_outlined),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.fastEaseInToSlowEaseOut,
                        width: _searchActivated ? 70 : 0,
                        child: CupertinoTextField.borderless(
                          focusNode: _focusNode,
                          controller: _textController,
                          placeholder: 'Поиск',
                          onEditingComplete: _submitSearch,
                          onChanged: _trySearch,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
              expandedHeight: 150,
              elevation: 0,
              pinned: true,
              backgroundColor: const Color.fromARGB(255, 230, 230, 230),
            ),
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 6,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0),
              delegate: SliverChildListDelegate(
                [
                  ..._shownItems.map(
                    (post) {
                      waitTimer += 200;

                      return BlogListItem(
                        post,
                        waitTimer: Duration(milliseconds: waitTimer),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
