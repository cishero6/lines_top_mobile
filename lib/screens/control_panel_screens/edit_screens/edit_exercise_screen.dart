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
   final TextEditingController _exListController1 = TextEditingController();
  final TextEditingController _repsListController1 = TextEditingController();
  final TextEditingController _exListController2 = TextEditingController();
  final TextEditingController _repsListController2 = TextEditingController();
  final TextEditingController _exListController3 = TextEditingController();
  final TextEditingController _repsListController3 = TextEditingController();
  final TextEditingController _exListController4 = TextEditingController();
  final TextEditingController _repsListController4 = TextEditingController();
  final TextEditingController _exListController5 = TextEditingController();
  final TextEditingController _repsListController5 = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  Color videoTextColor = Colors.black;
  bool _anythingChanged = false;
  late BuildContext _dialogContext;

  bool _listChanged = false;
  final List<String> _exListTexts = ['','','','',''];
  final List<String> _repsListTexts = ['','','','',''];
  


  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _exListTexts.clear();
    _exListTexts.addAll([_exListController1.text,_exListController2.text,_exListController3.text,_exListController4.text,_exListController5.text]);
    _repsListTexts.clear();
    _repsListTexts.addAll([_repsListController1.text,_repsListController2.text,_repsListController3.text,_repsListController4.text,_repsListController5.text]);
    for (int i = 0; i < 5; i++) {
      if (_exListTexts[i].split('\n').length !=
          _repsListTexts[i].split('\n').length) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Количество строк в списке упражнений и повторениях должны совпадать!')));
        return;
      }
    }
    showDialog(
      barrierDismissible: false,
        context: context,
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
    Map<String, dynamic> newData = {};
    if (_titleController.text != widget.exercise.title) {
      newData.addAll({'title': _titleController.text});
    }
    if (_descriptionController.text != widget.exercise.description) {
      newData.addAll({'description': _descriptionController.text});
    }
    if (_listChanged) {
      newData.addAll({'exercise_list_texts': _exListTexts});
      newData.addAll({'repetition_list_texts': _repsListTexts});
    }
    if (_pickedVideo != null) {
      newData.addAll({'video': File(_pickedVideo!.path)});
    }
    try {
      await Provider.of<ExercisesProvider>(context, listen: false)
          .editItem(widget.exercise, newData);
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
  void initState() {
    _titleController.text = widget.exercise.title;
    _descriptionController.text = widget.exercise.description;
    _repsListController1.text = widget.exercise.repetitionListTexts[0];
    _exListController1.text = widget.exercise.exerciseListTexts[0];
    _repsListController2.text = widget.exercise.repetitionListTexts[1];
    _exListController2.text = widget.exercise.exerciseListTexts[1];
    _repsListController3.text = widget.exercise.repetitionListTexts[2];
    _exListController3.text = widget.exercise.exerciseListTexts[2];
    _repsListController4.text = widget.exercise.repetitionListTexts[3];
    _exListController4.text = widget.exercise.exerciseListTexts[3];
    _repsListController5.text = widget.exercise.repetitionListTexts[4];
    _exListController5.text = widget.exercise.exerciseListTexts[4];
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
                      maxLength: 80,
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
                      maxLength: 400,
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
                  const Center(child: Text('СЛОТ 1')),
                  Row(
                    children: [
                      Flexible(
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null)
                                    return 'Введите текст!';
                                  return null;
                                },
                                onChanged: (value) {
                                  _listChanged = true;
                                  setState(()=>_anythingChanged=true);
                                },
                                maxLines: null,
                                decoration: const InputDecoration(
                                    hintText: 'Список упражнений'),
                                controller: _exListController1,
                                maxLength: 400,
                              ),
                            ),
                            UnconstrainedBox(
                              child: ElevatedButton(
                                onPressed: () =>
                                    FocusScope.of(context).unfocus(),
                                child: const Text('Готово'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null )
                                    return 'Введите текст!';
                                  return null;
                                },
                                onChanged: (value) {
                                  _listChanged = true;
                                  setState(()=>_anythingChanged=true);
                                },
                                maxLines: null,
                                decoration: const InputDecoration(
                                    hintText: 'Повторения'),
                                controller: _repsListController1,
                                maxLength: 400,
                              ),
                            ),
                            UnconstrainedBox(
                              child: ElevatedButton(
                                onPressed: () =>
                                    FocusScope.of(context).unfocus(),
                                child: const Text('Готово'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    thickness: 6,
                  ),
                  const Center(child: Text('СЛОТ 2')),
                  Row(
                    children: [
                      Flexible(
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null)
                                    return 'Введите текст!';
                                  return null;
                                },
                                onChanged: (value) {
                                  _listChanged = true;
                                  setState(()=>_anythingChanged=true);
                                },
                                maxLines: null,
                                decoration: const InputDecoration(
                                    hintText: 'Список упражнений'),
                                controller: _exListController2,
                                maxLength: 400,
                              ),
                            ),
                            UnconstrainedBox(
                              child: ElevatedButton(
                                onPressed: () =>
                                    FocusScope.of(context).unfocus(),
                                child: const Text('Готово'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null)
                                    return 'Введите текст!';
                                  return null;
                                },
                                onChanged: (value) {
                                  _listChanged = true;
                                  setState(()=>_anythingChanged=true);
                                },                                maxLines: null,
                                decoration: const InputDecoration(
                                    hintText: 'Повторения'),
                                controller: _repsListController2,
                                maxLength: 400,
                              ),
                            ),
                            UnconstrainedBox(
                              child: ElevatedButton(
                                onPressed: () =>
                                    FocusScope.of(context).unfocus(),
                                child: const Text('Готово'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    thickness: 6,
                  ),
                  const Center(child: Text('СЛОТ 3')),
                  Row(
                    children: [
                      Flexible(
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null)
                                    return 'Введите текст!';
                                  return null;
                                },
                                onChanged: (value) {
                                  _listChanged = true;
                                  setState(()=>_anythingChanged=true);
                                },
                                maxLines: null,
                                decoration: const InputDecoration(
                                    hintText: 'Список упражнений'),
                                controller: _exListController3,
                                maxLength: 400,
                              ),
                            ),
                            UnconstrainedBox(
                              child: ElevatedButton(
                                onPressed: () =>
                                    FocusScope.of(context).unfocus(),
                                child: const Text('Готово'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null)
                                    return 'Введите текст!';
                                  return null;
                                },
                                onChanged: (value) {
                                  _listChanged = true;
                                  setState(()=>_anythingChanged=true);
                                },
                              maxLines: null,
                                decoration: const InputDecoration(
                                    hintText: 'Повторения'),
                                controller: _repsListController3,
                                maxLength: 400,
                              ),
                            ),
                            UnconstrainedBox(
                              child: ElevatedButton(
                                onPressed: () =>
                                    FocusScope.of(context).unfocus(),
                                child: const Text('Готово'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    thickness: 6,
                  ),
                  const Center(child: Text('СЛОТ 4')),
                  Row(
                    children: [
                      Flexible(
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null)
                                    return 'Введите текст!';
                                  return null;
                                },
                                onChanged: (value) {
                                  _listChanged = true;
                                  setState(()=>_anythingChanged=true);
                                },                                
                                maxLines: null,
                                decoration: const InputDecoration(
                                    hintText: 'Список упражнений'),
                                controller: _exListController4,
                                maxLength: 400,
                              ),
                            ),
                            UnconstrainedBox(
                              child: ElevatedButton(
                                onPressed: () =>
                                    FocusScope.of(context).unfocus(),
                                child: const Text('Готово'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null)
                                    return 'Введите текст!';
                                  return null;
                                },
                                onChanged: (value) {
                                  _listChanged = true;
                                  setState(()=>_anythingChanged=true);
                                },
                                maxLines: null,
                                decoration: const InputDecoration(
                                    hintText: 'Повторения'),
                                controller: _repsListController4,
                                maxLength: 400,
                              ),
                            ),
                            UnconstrainedBox(
                              child: ElevatedButton(
                                onPressed: () =>
                                    FocusScope.of(context).unfocus(),
                                child: const Text('Готово'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    thickness: 6,
                  ),
                  const Center(child: Text('СЛОТ 5')),
                  Row(
                    children: [
                      Flexible(
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null)
                                    return 'Введите текст!';
                                  return null;
                                },
                                onChanged: (value) {
                                  _listChanged = true;
                                  setState(()=>_anythingChanged=true);
                                },                                
                                maxLines: null,
                                decoration: const InputDecoration(
                                    hintText: 'Список упражнений'),
                                controller: _exListController5,
                                maxLength: 400,
                              ),
                            ),
                            UnconstrainedBox(
                              child: ElevatedButton(
                                onPressed: () =>
                                    FocusScope.of(context).unfocus(),
                                child: const Text('Готово'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null)
                                    return 'Введите текст!';
                                  return null;
                                },
                                onChanged: (value) {
                                  _listChanged = true;
                                  setState(()=>_anythingChanged=true);
                                },                                
                                maxLines: null,
                                decoration: const InputDecoration(
                                    hintText: 'Повторения'),
                                controller: _repsListController5,
                                maxLength: 400,
                              ),
                            ),
                            UnconstrainedBox(
                              child: ElevatedButton(
                                onPressed: () =>
                                    FocusScope.of(context).unfocus(),
                                child: const Text('Готово'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                          ))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
