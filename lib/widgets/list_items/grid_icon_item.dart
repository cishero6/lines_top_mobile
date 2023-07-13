import 'package:flutter/material.dart';

class GridIconItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function() onTap;
  const GridIconItem(
      {required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(color: Colors.black26, width: 0.5),
                  bottom: BorderSide(color: Colors.black26, width: 0.5),
                  left: BorderSide(color: Colors.black26, width: 0.5),
                  right: BorderSide(color: Colors.black26, width: 0.5))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 80,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:8.0),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
              )
            ],
          )),
    );
  }
}
