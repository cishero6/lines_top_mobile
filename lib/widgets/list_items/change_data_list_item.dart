// ignore_for_file: must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChangeDataListItem extends StatefulWidget {
  final String leadingText;
  final TextEditingController textEditingController;
  final String initialValue;
  
  ChangeDataListItem({required this.leadingText,required this.textEditingController,required this.initialValue,super.key});

  @override
  State<ChangeDataListItem> createState() => _ChangeDataListItemState();
}

class _ChangeDataListItemState extends State<ChangeDataListItem> {
  final FocusNode _focusNode = FocusNode();
  String _placeholderText = '';
  bool _readOnly = true;




  @override
  void initState() {
    _placeholderText = widget.initialValue;
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
                    style: Theme.of(context).textTheme.titleMedium,
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
                    setState(() {
                     if(value != ''){
                      _placeholderText = value;
                     }
                      _readOnly = true;
                    });
                    _focusNode.unfocus();
                  },
                  placeholder: _placeholderText,
                  placeholderStyle: Theme.of(context).textTheme.titleMedium,
                  readOnly: _readOnly,
                  focusNode: _focusNode,
                  style: Theme.of(context).textTheme.titleMedium,
                )),
            Flexible(
              flex: 2,
              fit: FlexFit.loose,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: TextButton(
                    onPressed: () {
                      setState(() {
                        _readOnly = false;
                      });
                      _focusNode.requestFocus();
                    },
                    child: Text(
                      'Изменить',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )),
              ),
            ),
        ],
      ),
    );
  }
}