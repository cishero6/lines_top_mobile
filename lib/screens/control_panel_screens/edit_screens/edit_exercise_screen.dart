import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lines_top_mobile/models/exercise.dart';
import 'package:provider/provider.dart';

import '../../../providers/exercises_provider.dart';

class EditExerciseScreen extends StatefulWidget {
  final Exercise exercise;
  const EditExerciseScreen(this.exercise, {super.key});

  static const routeName = '/control_panel/edit_exercise';

  @override
  State<EditExerciseScreen> createState() => _EditExerciseScreenState();
}

class _EditExerciseScreenState extends State<EditExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  late XFile? _pickedVideo = null;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  Color videoTextColor = Colors.black;
  bool _anythingChanged = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Загрузка'),
              actions: [
                Text(Provider.of<ExercisesProvider>(context).loadingText)
              ],
              content:
                  const UnconstrainedBox(child: CircularProgressIndicator()),
            ));
    Map<String, dynamic> newData = {};
    if (_titleController.text != widget.exercise.title) {
      newData.addAll({'title': _titleController.text});
    }
    if (_descriptionController.text != widget.exercise.description) {
      newData.addAll({'description': _titleController.text});
    }
    if (_pickedVideo != null) {
      newData.addAll({'video': File(_pickedVideo!.path)});
    }
    try {
      await Provider.of<ExercisesProvider>(context, listen: false)
          .editItem(widget.exercise, newData);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Успешно!')));
    } catch (e) {
      print(e);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Что-то пошло не так!')));
    }
  }

  @override
  void initState() {
    _titleController.text = widget.exercise.title;
    _descriptionController.text = widget.exercise.description;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(
              'Изменить упражнение',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Form(
            key: _formKey,
            child: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: TextFormField(
                      onChanged: (value) => setState(() =>
                          _anythingChanged = !(value == widget.exercise.title)),
                      validator: (value) {
                        if (value == null || value == '') return 'Введите текст!';
                        return null;
                      },
                      decoration:
                          const InputDecoration(hintText: 'Название упражнения'),
                      controller: _titleController,
                      maxLength: 20,
                    ),
                  ),
                  const Divider(
                    thickness: 6,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: TextFormField(
                      onChanged: (value) => setState(() => _anythingChanged =
                          !(value == widget.exercise.description)),
                      validator: (value) {
                        if (value == null || value == '') return 'Введите текст!';
                        return null;
                      },
                      maxLines: null,
                      decoration:
                          const InputDecoration(hintText: 'Описание упражнения'),
                      controller: _descriptionController,
                      maxLength: 200,
                    ),
                  ),
                  UnconstrainedBox(
                    child: ElevatedButton(
                      onPressed: () => FocusScope.of(context).unfocus(),
                      child: const Text('Готово'),
                    ),
                  ),
                  const Divider(
                    thickness: 6,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                          onPressed: () async {
                            _pickedVideo = await _picker.pickVideo(
                                source: ImageSource.gallery);
                            _anythingChanged = true;
                            setState(() {
                              videoTextColor = Colors.black;
                            });
                          },
                          icon: Icon(Icons.image),
                          label: Text(
                            'Изменить видео',
                            style: Theme.of(context).textTheme.bodySmall,
                          )),
                      IconButton(
                          onPressed: _pickedVideo == null
                              ? null
                              : () => setState(() => _pickedVideo = null),
                          icon: Icon(
                            Icons.delete,
                            color: _pickedVideo == null
                                ? Colors.grey
                                : Theme.of(context).colorScheme.error,
                          )),
                    ],
                  ),
                  Center(
                    child: Text(
                      _pickedVideo == null ? 'Текущее видео' : _pickedVideo!.name,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: videoTextColor),
                    ),
                  ),
                  const Divider(
                    thickness: 6,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  UnconstrainedBox(
                      child: ElevatedButton(
                          onPressed: _anythingChanged ? () => _submit() : null,
                          child: Text(
                            'Подтвердить',
                            style: Theme.of(context).textTheme.bodyMedium,
                          )))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
