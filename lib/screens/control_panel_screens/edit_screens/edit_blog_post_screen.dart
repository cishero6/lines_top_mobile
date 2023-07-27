
import 'package:flutter/material.dart';
import 'package:lines_top_mobile/models/blog_post.dart';
import 'package:lines_top_mobile/providers/blog_provider.dart';
import 'package:provider/provider.dart';

class EditBlogPostScreen extends StatefulWidget {
  final BlogPost blogPost;
  const EditBlogPostScreen(this.blogPost,{super.key});
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

  bool _anythingChanged = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: const UnconstrainedBox(child: CircularProgressIndicator()),
        title: const Text('Загрузка'),
        actions: [Text(Provider.of<BlogProvider>(context).loadingText)],
      ),
    );
    Map<String,dynamic> newData = {};
    if(_titleController.text != widget.blogPost.title) newData.addAll({'title': _titleController.text});
    if(_shortDescriptionController.text != widget.blogPost.shortDesc) newData.addAll({'short_desc': _shortDescriptionController.text});
    if(_bodyTextController.text != widget.blogPost.bodyText) newData.addAll({'body_text': _titleController.text});


    try {
     await Provider.of<BlogProvider>(context,listen: false).editItem(widget.blogPost,newData);
      //await Provider.of<BlogProvider>(context,listen: false).addPost(newPost);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
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
        _titleController.text = widget.blogPost.title;
    _bodyTextController.text = widget.blogPost.bodyText;
    _shortDescriptionController.text = widget.blogPost.shortDesc;
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
                        onChanged: (value)=> setState(()=>_anythingChanged = !(value == widget.blogPost.title)),
                          validator: (value) {
                            if (value == null || value == '')
                              return 'Введите текст!';
                            return null;
                          },
                          decoration:
                              const InputDecoration(hintText: 'Название поста'),
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
                        onChanged: (value)=> setState(()=>_anythingChanged = !(value == widget.blogPost.shortDesc)),
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
                        onChanged: (value)=> setState(()=>_anythingChanged = !(value == widget.blogPost.bodyText)),
                          validator: (value) {
                            if (value == null || value == '')
                              return 'Введите текст!';
                            return null;
                          },
                          maxLines: null,
                          decoration:
                              const InputDecoration(hintText: 'Текст поста'),
                          controller: _bodyTextController,
                          maxLength: 500,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => FocusScope.of(context).unfocus(),
                        child: const Text('Готово'),
                      ),
                      const Divider(thickness: 5,),
                      const SizedBox(height: 20),
                      ElevatedButton(
                          onPressed: _anythingChanged ? _submit : null, child: const Text('Подтвердить'))
                ],
              ),
              ),
          ),
        ],
      ),
    );
  }
}
