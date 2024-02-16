import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lines_top_mobile/models/blog_post.dart';
import 'package:lines_top_mobile/providers/blog_provider.dart';
import 'package:provider/provider.dart';

class EditBlogPostScreen extends StatefulWidget {
  final BlogPost blogPost;
  const EditBlogPostScreen(this.blogPost, {super.key});
  static const routeName = '/control_panel/edit_blog_post';
  @override
  State<EditBlogPostScreen> createState() => _EditBlogPostScreenState();
}

class _EditBlogPostScreenState extends State<EditBlogPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _shortDescriptionController =
      TextEditingController();
  final TextEditingController _bodyTextController = TextEditingController();

  late XFile? _mainImage = null;
  late List<XFile?> _otherImages = [];
  final ImagePicker _picker = ImagePicker();

  late BuildContext _dialogContext;


  bool _pickerUsed = false;
  bool _anythingChanged = false;
  late bool _isPrimary;


  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_mainImage == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Нет Главной Фотографии!'),
        ),
      );
      return;
    }
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        _dialogContext = ctx;
        return AlertDialog(
        content: const UnconstrainedBox(child: CircularProgressIndicator()),
        title: const Text('Загрузка'),
        actions: [Text(Provider.of<BlogProvider>(context).loadingText)],
      );
      },
    );
    Map<String, dynamic> newData = {};
    if (_pickerUsed) {
      newData.addAll({
        'images': [
          File(_mainImage!.path),
          ..._otherImages.map((image) => File(image!.path)),
        ]
      });
    }
    if (_titleController.text != widget.blogPost.title) {
      newData.addAll({'title': _titleController.text});
    }
    if (_shortDescriptionController.text != widget.blogPost.shortDesc) {
      newData.addAll({'short_desc': _shortDescriptionController.text});
    }
    if (_bodyTextController.text != widget.blogPost.bodyText) {
      newData.addAll({'body_text': _bodyTextController.text});
    }
    if (_isPrimary != widget.blogPost.isPrimary){
      newData.addAll({'is_primary': _isPrimary});
    }

    try {
      await Provider.of<BlogProvider>(context, listen: false)
          .editItem(widget.blogPost, newData);
      // ignore: use_build_context_synchronously
      Navigator.of(_dialogContext).pop();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Успешно!')));
    } catch (e) {
      print(e);
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Что-то пошло не так!')));
    }
  }

  @override
  void initState() {
    _isPrimary = widget.blogPost.isPrimary;
    _titleController.text = widget.blogPost.title;
    _bodyTextController.text = widget.blogPost.bodyText;
    _shortDescriptionController.text = widget.blogPost.shortDesc;
    List<XFile> tempList =
        widget.blogPost.images.map((e) => XFile(e.path)).toList();
    if (tempList.isNotEmpty) {
      _mainImage = tempList.removeAt(0);
      _otherImages = [...tempList];
    }

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
              'Изменить пост',
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
                          _anythingChanged = !(value == widget.blogPost.title)),
                      validator: (value) {
                        if (value == null || value == '')
                          return 'Введите текст!';
                        return null;
                      },
                      decoration:
                          const InputDecoration(hintText: 'Название поста'),
                      controller: _titleController,
                      maxLength: 25,
                    ),
                  ),
                  const Divider(
                    thickness: 6,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: TextFormField(
                      onChanged: (value) => setState(() => _anythingChanged =
                          !(value == widget.blogPost.shortDesc)),
                      validator: (value) {
                        if (value == null || value == '')
                          return 'Введите текст!';
                        return null;
                      },
                      decoration:
                          const InputDecoration(hintText: 'Краткое описание'),
                      controller: _shortDescriptionController,
                      maxLength: 160,
                    ),
                  ),
                  const Divider(
                    thickness: 6,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: TextFormField(
                      onChanged: (value) => setState(() => _anythingChanged =
                          !(value == widget.blogPost.bodyText)),
                      validator: (value) {
                        if (value == null || value == '')
                          return 'Введите текст!';
                        return null;
                      },
                      maxLines: null,
                      decoration:
                          const InputDecoration(hintText: 'Текст поста'),
                      controller: _bodyTextController,
                      maxLength: 2500,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => FocusScope.of(context).unfocus(),
                    child: const Text('Готово'),
                  ),
                  const Divider(
                    thickness: 5,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Главная картинка'),
                  ),
                  Container(
                    width: 300,
                    height: 300,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      image: _mainImage == null
                          ? null
                          : DecorationImage(
                              image: FileImage(
                                File(_mainImage!.path),
                              ),
                            ),
                    ),
                    child: _mainImage == null
                        ? const Text(
                            'Не выбрано',
                          )
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              _mainImage = await _picker.pickImage(
                                  source: ImageSource.gallery);
                              _anythingChanged = true;
                              _pickerUsed = true;
                              setState(() {});
                            },
                            child: const Text('Выбрать')),
                        ElevatedButton(
                            onPressed: () async {
                              _mainImage = null;
                              setState(() {});
                            },
                            child: const Text('Очистить')),
                      ],
                    ),
                  ),
                  const Divider(
                    thickness: 6,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Остальные картинки'),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (_otherImages.isEmpty)
                          Container(
                            color: Colors.black12,
                            width: 300,
                            height: 300,
                            alignment: Alignment.center,
                            child: const Text(
                              'Не выбрано',
                            ),
                          ),
                        ..._otherImages.map(
                          (e) => Container(
                            height: 300,
                            width: 300,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.contain,
                                image: FileImage(
                                  File(e!.path),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              _otherImages = await _picker.pickMultiImage();
                              setState(() {});
                              _anythingChanged = true;
                              _pickerUsed = true;
                            },
                            child: const Text('Выбрать')),
                        ElevatedButton(
                            onPressed: () async {
                              _otherImages = [];
                              setState(() {});
                            },
                            child: const Text('Очистить')),
                      ],
                    ),
                  ),
                  const Divider(
                    thickness: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox.adaptive(
                        value: _isPrimary,
                        onChanged: (value) => setState(
                          () {
                            _anythingChanged=true;
                            _isPrimary = value ?? false;
                          },
                        ),
                      ),
                      Text(
                        'Главный пост',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  const Divider(
                    thickness: 6,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: _anythingChanged ? _submit : null,
                      child: const Text('Подтвердить'))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
