// ignore_for_file: must_be_immutable
import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewParametersListItem extends StatefulWidget {
  final String leadingText;
  late bool isFixed;
  final TextEditingController textEditingController;
  late String initialValue;
  final bool isNum;
  final bool isRightAligned;
  
  NewParametersListItem({required this.leadingText,required this.textEditingController,required this.initialValue,super.key,this.isNum = true,this.isRightAligned = false}){
    isFixed = false;
  }
  NewParametersListItem.fixed({required this.leadingText,required this.textEditingController,required this.initialValue,super.key,this.isNum = true,this.isRightAligned = false}){
    isFixed = true;
  }

  @override
  State<NewParametersListItem> createState() => _NewParametersListItemState();
}

class _NewParametersListItemState extends State<NewParametersListItem> {
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
        mainAxisAlignment: widget.isRightAligned ?  MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
              fit: FlexFit.tight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.leadingText,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white),
                  ),
                ),
              )),
          if (widget.isFixed)
            Flexible(
              fit: FlexFit.loose,
                child: SizedBox(
                    width: 65,
                    child: CupertinoTextField.borderless(
                      keyboardType: widget.isNum? TextInputType.number : TextInputType.text,
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
                      placeholderStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white),
                      readOnly: _readOnly,
                      focusNode: _focusNode,
                      cursorColor: Colors.white70,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white),
                    ))),
          if (widget.isFixed)
            Flexible(
              fit: FlexFit.loose,
              child: SizedBox(
                width: 100,
                child: TextButton(
                    onPressed: () {
                      setState(() {
                        _readOnly = false;
                      });
                      _focusNode.requestFocus();
                    },
                    child: Text(
                      'Изменить',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),
                    )),
              ),
            ),
          if (!widget.isFixed)
            Flexible(
              fit: FlexFit.loose,
                child: SizedBox(
                    width: 65,
                    child: Platform.isIOS
                        ? CupertinoTextField(
                            controller: widget.textEditingController,
                            placeholder: widget.initialValue.toString(),
                            cursorColor: CupertinoColors.darkBackgroundGray,
                            style: Theme.of(context).textTheme.bodyMedium,
                            keyboardType: widget.isNum? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
                          )
                        : TextField(
                            controller: widget.textEditingController,
                            decoration: InputDecoration(hintText: widget.initialValue.toString(),),
                            keyboardType: widget.isNum?const  TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
                          ))),
          if (!widget.isFixed)
            SizedBox(
              width: widget.isRightAligned ? 20: 100,
            ),
        ],
      ),
    );
  }
}