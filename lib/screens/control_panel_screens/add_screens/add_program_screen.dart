import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lines_top_mobile/models/program.dart';
import 'package:lines_top_mobile/providers/programs_provider.dart';
import 'package:lines_top_mobile/providers/trainings_provider.dart';
import 'package:provider/provider.dart';
import '../../../models/training.dart';

class AddProgramScreen extends StatefulWidget {
  const AddProgramScreen({super.key});
  static const routeName = '/control_panel/add_program';
  @override
  State<AddProgramScreen> createState() => _AddProgramScreenState();
}

class _AddProgramScreenState extends State<AddProgramScreen> {
  late List<Training> _trainings;
  late List<Program> _programs;
  List<Training> _chosenTrainings = [];
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();  
  late XFile? _pickedPhoto = null;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _bodyTextController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  Color _containerColor = Colors.white70;
  late BuildContext _dialogContext;

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_pickedPhoto == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Добавьте фото!')));
      return;
    }
    if (_chosenTrainings.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Добавьте тренировки!')));
      return;
    }
    if (_chosenTrainings.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Добавьте тренировки!')));
      return;
    }
    for (Program program in _programs) {
      if (_titleController.text == program.title) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Программа с таким названием уже есть! Введите другое название')));
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
        actions: [Text(Provider.of<ProgramsProvider>(context).loadingText)],
        content: const UnconstrainedBox(child: CircularProgressIndicator()),
      );}
    );
    var newProgram = Program(
        title: _titleController.text,
        bodyText: _bodyTextController.text,
        subtext: _descriptionController.text,
        image: File(_pickedPhoto!.path),
        trainings: _chosenTrainings);
    try {
      await Provider.of<ProgramsProvider>(context, listen: false)
          .addProgram(newProgram);
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
    _trainings = Provider.of<TrainingsProvider>(context, listen: false).items.where((element) => !element.isSet).toList();
    _programs = Provider.of<ProgramsProvider>(context, listen: false).items;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
                SliverAppBar(
                  pinned: true,
                  title: Text(
                    'Добавить программу',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Form(
                  key: _formKey,
                  child: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 14),
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value == '')
                                return 'Введите текст!';
                              return null;
                            },
                            decoration: const InputDecoration(
                                hintText: 'Название Программы'),
                            controller: _titleController,
                            maxLength: 60,
                          ),
                        ),
                        const Divider(
                          thickness: 6,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 14),
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value == '')
                                return 'Введите текст!';
                              return null;
                            },
                            maxLines: null,
                            decoration: const InputDecoration(
                                hintText: 'Краткое описание программы'),
                            controller: _descriptionController,
                            maxLength: 140,
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 14),
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value == '')
                                return 'Введите текст!';
                              return null;
                            },
                            maxLines: null,
                            decoration: const InputDecoration(
                                hintText: 'Текст про программу'),
                            controller: _bodyTextController,
                            maxLength: 2600,
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
                          thickness: 6,
                        ),
                      ],
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
                                'Все тренировки',
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
                                      children: _trainings
                                          .map((e) => Draggable<Training>(
                                              data: e,
                                              childWhenDragging: Container(
                                                height: 50,
                                                color: Colors.grey,
                                              ),
                                              feedback: Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                      border:
                                                          Border.all(width: 0.5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  alignment: Alignment.centerLeft,
                                                  child: Text(
                                                    e.title,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium,
                                                  )),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    border:
                                                        Border.all(width: 0.5)),
                                                padding: const EdgeInsets.all(8),
                                                height: 50,
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  e.title,
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
                                'Выбранные тренировки',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: DragTarget(
                                    onLeave: (details) => setState(() {
                                      _containerColor = Colors.white70;
                                    }),
                                    onMove: (details) => setState(() {
                                      _containerColor = Colors.black12;
                                    }),
                                    onAccept: (Training data) {
                                      _chosenTrainings.add(data);
                                      _containerColor = Colors.white70;
                                      setState(() {});
                                    },
                                    builder: (_, __, ___) => _chosenTrainings
                                            .isEmpty
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
                                            children: _chosenTrainings
                                                .map(
                                                  (e) => Container(
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
                                                            e.title,
                                                            overflow: TextOverflow
                                                                .ellipsis,
                                                            style:
                                                                Theme.of(context)
                                                                    .textTheme
                                                                    .labelSmall,
                                                          ),
                                                        ),
                                                        IconButton(
                                                          splashRadius: 1,
                                                          onPressed: () =>
                                                              setState(() =>
                                                                  _chosenTrainings
                                                                      .remove(e)),
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: ElevatedButton(
                        onPressed: () => _submit(),
                        child: const Text('Подтвердить')),
                  ),
                ),
              ],
      ),
    );
  }
}
