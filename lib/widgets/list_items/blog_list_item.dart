import 'package:flutter/material.dart';
import 'package:lines_top_mobile/providers/user_data_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/bottom_navigation_provider.dart';
import '../../screens/details_screens/blog_post_details_screen.dart';

import '../../models/blog_post.dart';
import '../../screens/navigation_bar_screens/profile_screen.dart';

// ignore: must_be_immutable
class BlogListItem extends StatefulWidget {
  final BlogPost post;
  late Duration waitTimer;
  BlogListItem(this.post, {Duration? waitTimer}) {
    this.waitTimer = waitTimer ?? const Duration(milliseconds: 500);
  }

  @override
  State<BlogListItem> createState() => _BlogListItemState();
}

class _BlogListItemState extends State<BlogListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late bool _disposed;

  void _toggleSaved(IconData iconData, UserDataProvider authData) async {
    if (!authData.isAuth) {
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
    if (iconData == Icons.bookmark) {
      await authData.removeSavedId(widget.post.id);
      iconData = Icons.bookmark_outline;
    } else {
      await authData.addSavedId(widget.post.id);
      iconData = Icons.bookmark;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _disposed = false;
    _slideAnimation =
        Tween(begin: const Offset(-1.0, 0.0), end: const Offset(0.0, 0.0))
            .animate(CurvedAnimation(
                parent: _controller, curve: Curves.fastLinearToSlowEaseIn));
    Future.delayed(widget.waitTimer).whenComplete(() {
      try {
        if (!_disposed) _controller.forward();
        // ignore: empty_catches
      } catch (e) {}
    });
  }

  @override
  void dispose() {
    if (_controller.isAnimating) _controller.stop();
    _controller.dispose();
    _disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var authData = Provider.of<UserDataProvider>(context, listen: false);
    IconData iconData;
    if (!authData.isAuth) {
      iconData = Icons.bookmark_outline;
    } else {
      iconData = authData.savedBlogPostIds!.contains(widget.post.id)
          ? Icons.bookmark
          : Icons.bookmark_outline;
    }
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .pushNamed(BlogPostDetailsScreen.routeName, arguments: [widget.post]),
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: FileImage(widget.post.images.first),
                  fit: BoxFit.cover,
                  opacity: 0.2)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: IconButton(
                  icon: Icon(iconData),
                  onPressed: () => _toggleSaved(iconData, authData),
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    widget.post.title,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Color.fromARGB(120, 0, 0, 0),
                ),
              ),
                
              
            ],
          ),
        ),
      ),
    );
  }
}
