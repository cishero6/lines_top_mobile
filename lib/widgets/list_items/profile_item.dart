import 'dart:io';

import 'package:flutter/material.dart';

import '../../helpers/parallax_flow_delegate.dart';


class ProfileItem extends StatefulWidget {
  final String title;
  final String subtext;
  final File? image;
  final void Function() onTap;
  final bool isGrid;
  final double? width;
  final int? maxLines;
  const ProfileItem({this.isGrid = false,required this.title,required this.subtext,required this.onTap,this.maxLines,this.width,this.image,super.key});

  @override
  State<ProfileItem> createState() => _ProfileItemState();
}

class _ProfileItemState extends State<ProfileItem> {
  bool _isGrid = false;
  final GlobalKey _backgroundImageKey = GlobalKey();
  late String _title;
  late String _subtext;
  late File? _image;
  late void Function() _onTap;

  @override
  void initState() {
    _title = widget.title;
    _subtext = widget.subtext;
    _onTap = widget.onTap;
    _image = widget.image;
    _isGrid = widget.isGrid;
    super.initState();
  }

  Widget _buildParallaxBackground(BuildContext context) {
    return Flow(
      delegate: ParallaxFlowDelegate(
        scrollable: Scrollable.of(context),
        listItemContext: context,
        backgroundImageKey: _backgroundImageKey
      ),
      children: [
        if(_image != null) Image.file(_image!,key: _backgroundImageKey,fit: BoxFit.cover,),
        //if(_image == null) Container(key: _backgroundImageKey,decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.black,Color.fromARGB(255, 105, 105, 105)],begin: Alignment.topLeft,end: Alignment.bottomRight)),height: 300,),
        if(_image == null) Image.asset('assets/images/backgrounds/bg_8.jpg',key: _backgroundImageKey,fit: BoxFit.cover,),
      ],
    );
  }

  Widget _buildGradient() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.6, 0.95],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndSubtitle() {
    return Positioned(
      left: 20,
      bottom: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Text(
              _subtext,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(
            width: widget.width != null ? widget.width!-50:null,
            child: widget.maxLines != 1? Text(
              _title,
              maxLines: widget.maxLines ?? 2,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ): FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                _title,
                maxLines: widget.maxLines ?? 2,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        margin: const EdgeInsets.all(10),
        height: _isGrid ? null : 200,
        width: _isGrid? 180 : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(children: [
            _buildParallaxBackground(context),
            _buildGradient(),
            _buildTitleAndSubtitle(),
          ]),
        ),
      ),
    );
  }
}