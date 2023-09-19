// ignore_for_file: must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChangeDataListItem extends StatefulWidget {
  final String leadingText;
  final TextEditingController textEditingController;
  late FocusNode focusNode;
  final bool readOnly;
  
  ChangeDataListItem({required this.leadingText,required this.textEditingController,this.readOnly = false,FocusNode? focusNode,super.key}){
    this.focusNode = focusNode ?? FocusNode();
  }

  @override
  State<ChangeDataListItem> createState() => _ChangeDataListItemState();
}

class _ChangeDataListItemState extends State<ChangeDataListItem> {
  late FocusNode _focusNode = FocusNode();
  





  @override
  void initState() {
    _focusNode = widget.focusNode;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
              fit: FlexFit.loose,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.leadingText,
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),
                  ),
                ),
              )),
            Flexible(
              flex: 5,
              fit: FlexFit.tight,
                child: CupertinoTextField.borderless(
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  controller: widget.textEditingController,
                  onSubmitted: (value) {
                    _focusNode.unfocus();
                  },
                  focusNode: _focusNode,
                  readOnly: widget.readOnly,
                  cursorColor: Colors.white70,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),
                )),
        ],
      ),
    );
  }
}