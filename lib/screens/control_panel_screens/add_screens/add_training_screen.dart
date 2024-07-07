import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lines_top_mobile/models/exercise.dart';
import 'package:lines_top_mobile/models/training.dart';
import 'package:lines_top_mobile/providers/trainings_provider.dart';
import 'package:provider/provider.dart';

import '../../../providers/exercises_provider.dart';

class AddTrainingScreen extends StatefulWidget {
  const AddTrainingScreen({super.key});
  static const routeName = '/control_panel/add_training';
  @override
  State<AddTrainingScreen> createState() => _AddTrainingScreenState();
}

class _AddTrainingScreenState extends State<AddTrainingScreen> {
  late List<Training> _trainings;
  late List<Exercise> _exercises = [];
  String _selectedSection = '_notSelected';
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late bool _isSet = false;
  final ImagePicker _picker = ImagePicker();
  late XFile? _pickedPhoto = null;

  Map<String, List<int>> _repsIds = {
    'Разминка': [],
    'Основная часть': [],
    'Заминка': [],
  };

  Map<String, List<Exercise>> _sections = {
    'Разминка': [],
    'Основная часть': [],
    'Заминка': [],
  };
  Color _containerColor = Colors.white70;
  final ScrollController _scrollController = ScrollController();
  List<String> _sectionKeys = ['Разминка', 'Основная часть', 'Заминка'];
  late BuildContext _dialogContext;

  void _submit() async {
    if (_isSet && _pickedPhoto == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Добавьте фото!')));
      return;
    }
    if (_isSet && _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Добавьте описание сету!')));
      return;
    }
    if (_sections.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Добавьте секции!')));
      return;
    }
    for (List<Exercise> section in _sections.values) {
      if (section.isEmpty) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Надо заполнить пустые секции!')));
        return;
      }
    }
    if (_titleEditingController.text == '') {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Введите название тренировки!')));
      return;
    }
    for (Training training in _trainings) {
      if (_titleEditingController.text == training.title) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Тренировка с таким названием уже есть! Введите другое название')));
        return;
      }
    }
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) {
          _dialogContext = ctx;
          return const AlertDialog(
            title: Text('Загружаем тренировку'),
            content: UnconstrainedBox(child: CircularProgressIndicator()),
          );
        });
    try {
      Training newTraining = Training(
        title: _titleEditingController.text,
        sections: _sections,
        exRepetitionsIds: _repsIds,
        isSet: _isSet,
      );
      if (_isSet) {
        newTraining.description = _descriptionController.text;
        newTraining.image = File(_pickedPhoto!.path);
      }
      await Provider.of<TrainingsProvider>(context, listen: false)
          .addTraining(newTraining, _sectionKeys);
      Navigator.of(_dialogContext).pop();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Успешно!')));
    } catch (e) {
      print(e);
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Что-то пошло не так...')));
    }
  }

  @override
  void initState() {
     _trainings = Provider.of<TrainingsProvider>(context, listen: false).items;
    _exercises = Provider.of<ExercisesProvider>(context, listen: false).items;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
   print(_repsIds);
   print(_sections);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(
              'Добавить тренировку',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: _titleEditingController,
                decoration:
                    const InputDecoration(labelText: 'Название тренировки'),
                maxLength: 20,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(width: 0.5, color: Colors.black),
                      bottom: BorderSide(width: 0.5, color: Colors.black))),
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    flex: 3,
                    fit: FlexFit.tight,
                    child: Column(
                      children: [
                        Text(
                          'Упражнения',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        Expanded(
                          child: Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: Column(
                                children: _exercises
                                    .map((ex) => Draggable<Exercise>(
                                        data: ex,
                                        childWhenDragging: Container(
                                          height: 50,
                                          color: Colors.grey,
                                        ),
                                        feedback: Container(
                                            padding: const EdgeInsets.all(8),
                                            height: 50,
                                            decoration: BoxDecoration(
                                                border: Border.all(width: 0.5),
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              ex.title,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            )),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(width: 0.5)),
                                          padding: const EdgeInsets.all(8),
                                          height: 50,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            ex.title,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        )))
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 200,
                    margin: const EdgeInsets.all(5),
                    color: Colors.black,
                  ),
                  Flexible(
                    flex: 3,
                    fit: FlexFit.tight,
                    child: Column(
                      children: [
                        Text(
                          _selectedSection,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: DragTarget(
                              onWillAccept: (data) =>
                                  _selectedSection != '_notSelected',
                              onLeave: (details) => setState(() {
                                _containerColor = Colors.white70;
                              }),
                              onMove: (details) => setState(() {
                                _containerColor = Colors.black12;
                              }),
                              onAccept: (Exercise data) {
                                int repId = 0;
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Выберите слот повторений'),
                                    actions: [0,1,2,3,4].map((i) => ElevatedButton(onPressed: (){Navigator.of(ctx).pop();repId = i;_repsIds[_selectedSection]!.add(repId);}, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [Text(data.exerciseListTexts[i]),Flexible(child: Text(data.repetitionListTexts[i],)),],))).toList(),
                                  ),
                                );
                                _sections[_selectedSection]!.add(data);
                                _containerColor = Colors.white70;
                                setState(() {});
                              },
                              builder: (_, __, ___) => _selectedSection ==
                                      '_notSelected'
                                  ? const Text('Не выбрано')
                                  : _sections[_selectedSection]!.isEmpty
                                      ? Container(
                                          decoration: BoxDecoration(
                                              color: _containerColor,
                                              border: Border.all(width: 0.5)),
                                          alignment: Alignment.center,
                                          height: 170,
                                          width: 170,
                                          child: Text(
                                            'Перетяни сюда',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                        )
                                      : Column(
                                          children: _sections[_selectedSection]!
                                              .map(
                                                (ex) => Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          width: 0.5)),
                                                  height: 50,
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          ex.title,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium,
                                                        ),
                                                      ),
                                                      IconButton(
                                                        splashRadius: 1,
                                                        onPressed: () {
                                                          int index = _sections[
                                                                  _selectedSection]!
                                                              .lastIndexOf(ex);
                                                          _sections[
                                                                  _selectedSection]!
                                                              .removeAt(index);
                                                          _repsIds[
                                                                  _selectedSection]!
                                                              .removeAt(index);
                                                          setState(() {});
                                                        },
                                                        icon: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 10),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Colors.black, width: 0.5))),
              height: 200,
              child: Row(children: [
                Flexible(
                    child: Column(
                  children: [
                    Text(
                      'Секции',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Expanded(
                        child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ..._sections.keys.map((e) => GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedSection = e),
                                child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: _selectedSection == e
                                            ? Colors.grey
                                            : Colors.white,
                                        border: Border.all(width: 0.5)),
                                    height: 50,
                                    width: double.infinity,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                e,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                              onPressed: () => setState(() {
                                                    _sectionKeys.remove(
                                                        _selectedSection);
                                                    _sections.remove(
                                                        _selectedSection);
                                                    _repsIds.remove(
                                                        _selectedSection);
                                                    _selectedSection =
                                                        '_notSelected';
                                                  }),
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ))
                                        ])),
                              )),
                          Container(
                              padding: const EdgeInsets.all(8),
                              decoration:
                                  BoxDecoration(border: Border.all(width: 0.5)),
                              height: 50,
                              width: double.infinity,
                              child: TextButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Добавить секцию'),
                                        content: TextField(
                                          controller: _textEditingController,
                                          decoration: const InputDecoration(
                                              labelText: 'Введите название'),
                                        ),
                                        actions: [
                                          IconButton(
                                              onPressed: () {
                                                if (_textEditingController
                                                        .text.isNotEmpty &&
                                                    !_sections.keys.contains(
                                                        _textEditingController
                                                            .text)) {
                                                  _sections.addAll({
                                                    _textEditingController.text:
                                                        []
                                                  });
                                                  _repsIds.addAll({
                                                    _textEditingController.text:
                                                        []
                                                  });
                                                  _sectionKeys.add(
                                                      _textEditingController
                                                          .text);
                                                  _selectedSection =
                                                      _textEditingController
                                                          .text;
                                                  Navigator.of(context).pop();
                                                  setState(() {});
                                                } else {
                                                  Navigator.of(context).pop();
                                                  ScaffoldMessenger.of(context)
                                                      .clearSnackBars();
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(const SnackBar(
                                                          content: Text(
                                                              'Такая секция уже есть!')));
                                                }
                                              },
                                              icon: const Icon(Icons.done)),
                                          IconButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              icon: const Icon(Icons.cancel)),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.black,
                                  ),
                                  label: Text(
                                    'Добавить секцию',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ))),
                        ],
                      ),
                    )),
                  ],
                )),
                Flexible(
                  child: Container(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: Text(
                        'Подтвердить',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(children: [
              const Divider(
                thickness: 7,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox.adaptive(
                    value: _isSet,
                    onChanged: (value) => setState(
                      () {
                        _isSet = value ?? false;
                      },
                    ),
                  ),
                  Text(
                    'Является СЕТОМ',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
              if (_isSet)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextField(
                    controller: _descriptionController,
                    decoration:
                        const InputDecoration(labelText: 'Описание Сета'),
                    maxLength: 40,
                  ),
                ),
              if (_isSet)
                const Divider(
                  thickness: 7,
                ),
              if (_isSet)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                        onPressed: () async {
                          _pickedPhoto = await _picker.pickImage(
                              source: ImageSource.gallery);
                          setState(() {});
                        },
                        icon: Icon(Icons.image),
                        label: Text(
                          'Выбрать фото',
                          style: Theme.of(context).textTheme.bodyMedium,
                        )),
                    IconButton(
                        onPressed: _pickedPhoto == null
                            ? null
                            : () => setState(() => _pickedPhoto = null),
                        icon: Icon(
                          Icons.delete,
                          color: _pickedPhoto == null
                              ? Colors.grey
                              : Theme.of(context).colorScheme.error,
                        )),
                  ],
                ),
              if (_isSet)
                Center(
                    child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                    width: 0.5,
                  )),
                  width: 100,
                  height: 100,
                  child: _pickedPhoto == null
                      ? null
                      : Image.file(File(_pickedPhoto!.path)),
                )),
              const Divider(
                thickness: 7,
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
