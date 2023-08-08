import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lines_top_mobile/models/exercise.dart';
import 'package:provider/provider.dart';

import '../../../providers/exercises_provider.dart';

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});
  static const routeName = '/control_panel/add_exercise';
  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  late XFile? _pickedVideo = null;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  Color videoTextColor = Colors.black;
  late BuildContext _dialogContext;


  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_pickedVideo == null) {
      setState(() {
        videoTextColor = Colors.red;
      });
      return;
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          _dialogContext = ctx;
          return AlertDialog(
              title: const Text('Загрузка'),
              actions: [
                Text(Provider.of<ExercisesProvider>(context).loadingText)
              ],
              content:
                  const UnconstrainedBox(child: CircularProgressIndicator()),
            );
        });
    Exercise newExercise = Exercise(
        title: _titleController.text,
        description: _descriptionController.text,
        video: File(_pickedVideo!.path));
    try {
      await Provider.of<ExercisesProvider>(context, listen: false)
          .addExercise(newExercise);
      // ignore: use_build_context_synchronously
      Navigator.of(_dialogContext).pop();
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(
              'Добавить упражнение',
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
                            setState(() {
                              videoTextColor = Colors.black;
                            });
                          },
                          icon: Icon(Icons.image),
                          label: Text(
                            'Выбрать видео',
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
                      _pickedVideo == null ? 'Не выбрано' : _pickedVideo!.name,
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
                          onPressed: () => _submit(),
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
