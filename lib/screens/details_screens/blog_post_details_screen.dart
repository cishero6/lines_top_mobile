import 'package:flutter/material.dart';
import 'package:lines_top_mobile/models/blog_post.dart';
import 'package:lines_top_mobile/providers/user_data_provider.dart';
import 'package:provider/provider.dart';

import '../../providers/bottom_navigation_provider.dart';
import '../navigation_bar_screens/profile_screen.dart';

// ignore: must_be_immutable
class BlogPostDetailsScreen extends StatefulWidget {
  final BlogPost blogPost;
  static const routeName = '/blog_details';

  BlogPostDetailsScreen(this.blogPost, {super.key});

  @override
  State<BlogPostDetailsScreen> createState() => _BlogPostDetailsScreenState();
}

class _BlogPostDetailsScreenState extends State<BlogPostDetailsScreen> {
  List<String> _formattedText = [];

  late List<Widget> _widgets;

  @override
  void initState() {
    _widgets = [];
    super.initState();
  }

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

  void _constructWidgets(BuildContext ctx) {
    int index = 0;
    print(_formattedText);
    for (String element in _formattedText) {
      if (element.trim().startsWith('//')) {
        _widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Image.file(
              widget.blogPost.images[index],
              height: 300,
              fit: BoxFit.cover,
            ),
          ),
        );
        index++;
        if (index == widget.blogPost.images.length) index--;
      } else {
        _widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Text(
              element,
              style: Theme.of(ctx).textTheme.bodyLarge,
              textAlign: TextAlign.start,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool contains = Provider.of<UserDataProvider>(context, listen: false)
                .savedBlogPostIds ==
            null
        ? false
        : Provider.of<UserDataProvider>(context, listen: false)
            .savedBlogPostIds!
            .contains(widget.blogPost.id);
    _formattedText = widget.blogPost.bodyText.split('|');
    print(_formattedText);
    print('ddd');
    print(_widgets);
    _constructWidgets(context);
    print(_widgets);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            actions: [
              IconButton(
                  onPressed: () => _toggleSaved(contains),
                  icon: contains
                      ? const Icon(Icons.bookmark)
                      : const Icon(Icons.bookmark_outline))
            ],
            title: Text(
              'Пост',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            pinned: true,
            scrolledUnderElevation: 0,
          ),
          SliverToBoxAdapter(
            child: UnconstrainedBox(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                    maxHeight: 80, minHeight: 60, minWidth: 120),
                child: Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: Text(
                    widget.blogPost.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
            ),
          ),
          SliverList.list(children: _widgets),
        ],
      ),
    );
  }
}
