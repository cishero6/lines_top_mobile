import 'package:flutter/material.dart';

class FlexibleSpace extends StatelessWidget {
  final String title;
  final bool lowSpace;
  final List<Widget> children;
  const FlexibleSpace({required this.title, required this.children,this.lowSpace = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: lowSpace ? Alignment.bottomCenter: null,
      height: MediaQuery.of(context).size.height / 5,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, top: 30.0, right: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              fit: FlexFit.tight,
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            ...children
          ],
        ),
      ),
    );
  }
}
