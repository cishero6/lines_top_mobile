import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lines_top_mobile/providers/blog_provider.dart';
import '../../models/lines_top_model.dart';
import '../../providers/trainings_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/exercises_provider.dart';
import '../../providers/programs_provider.dart';

class ControlPanelScreen extends StatefulWidget {
  final String addRouteName;

  const ControlPanelScreen(this.addRouteName, {super.key});
  static const routeName = '/control_panel';
  @override
  State<ControlPanelScreen> createState() => _ControlPanelScreenState();
}

class _ControlPanelScreenState extends State<ControlPanelScreen> {
  List<LinesTopModel> _items = [];
  late var _provider;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.addRouteName) {
      case '/control_panel/add_training':
        _items = Provider.of<TrainingsProvider>(context).items;
        _provider = Provider.of<TrainingsProvider>(context);
        break;
      case '/control_panel/add_exercise':
        _items = Provider.of<ExercisesProvider>(context).items;
        _provider = Provider.of<ExercisesProvider>(context);
        break;
      case '/control_panel/add_blog_post':
        _items = Provider.of<BlogProvider>(context).items;
        _provider = Provider.of<BlogProvider>(context);
        break;
      case '/control_panel/add_program':
        _items = Provider.of<ProgramsProvider>(context).items;
        _provider = Provider.of<ProgramsProvider>(context);
        break;
      default:
    }
    return Scaffold(
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(
              '${widget.addRouteName.substring(19)}s',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            actions: [
              IconButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(widget.addRouteName),
                  icon: const Icon(
                    Icons.add,
                    size: 32,
                  ))
            ],
          ),
          CupertinoSliverRefreshControl(
            onRefresh: () async => await _provider.fetchAndSetItems(context),
            refreshTriggerPullDistance: 31,
            refreshIndicatorExtent: 30,
          ),
          SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, index) => Column(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pushNamed(
                                widget.addRouteName.replaceFirst('add', 'edit'),
                                arguments: [_items[index]]),
                            child: ListTile(
                              leading: CircleAvatar(child: Text('${index + 1}')),
                              title: Text(
                                _items[index].title,
                              ),
                              trailing: IconButton(
                                  onPressed: () => showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Удалить предмет'),
                                          content: Text(
                                              'Вы уверены, что хотите удалить ${_items[index].title}?'),
                                          actions: [
                                            IconButton(
                                              onPressed: () async {
                                                String? result =
                                                    await _provider.deleteItem(
                                                        _items[index], context);
                                                // ignore: use_build_context_synchronously
                                                Navigator.of(context).pop();
                                                // ignore: use_build_context_synchronously
                                                ScaffoldMessenger.of(context)
                                                    .clearSnackBars();
                                                // ignore: use_build_context_synchronously
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(result ??
                                                            'Успешно!')));
                                              },
                                              icon: Text(
                                                'Да',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(color: Colors.red),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              icon: Text('Нет',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium),
                                            ),
                                          ],
                                        ),
                                      ),
                                  icon: const Icon(Icons.delete)),
                            ),
                          ),
                          const Divider(),
                        ],
                      ),
                  childCount: _items.length)),
        ],
      ),
    );
  }
}
