
import 'package:flutter/material.dart';
import 'package:lines_top_mobile/models/program.dart';

class ProgramDescriptionScreen extends StatelessWidget {
  final Program program;
  static const routeName = '/program_description';
  const ProgramDescriptionScreen(this.program);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            elevation: 1,
            pinned: true,
            title: Text(
              program.title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Image.file(program.image,fit: BoxFit.cover,),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    program.bodyText,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 90,
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    style: ButtonStyle(
                                            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)))),
                    onPressed: () {},
                    child: Text(
                      'Начать',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
