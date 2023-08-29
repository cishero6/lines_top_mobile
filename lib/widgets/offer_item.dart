import 'package:flutter/material.dart';

import '../helpers/parallax_flow_delegate.dart';

class OfferItem extends StatefulWidget {
  const OfferItem({super.key});

  @override
  State<OfferItem> createState() => _OfferItemState();
}

class _OfferItemState extends State<OfferItem> {
 final GlobalKey _backgroundImageKey = GlobalKey();
  static const List<String> _labels = [
    'Pro-доступ к приложению',
    'Вы получаете:\n - Неограниченный доступ ко всем программам Lines-Top!',
    '999 руб.',
  ];




  void _tryStart(){

  }




  Widget _buildParallaxBackground(BuildContext context) {
    return Flow(
        delegate: ParallaxFlowDelegate(
          scrollable: Scrollable.of(context),
          listItemContext: context,
          backgroundImageKey: _backgroundImageKey,
          isHorizontal: true,
        ),
        children: [
          Image.asset(
            'assets/images/backgrounds/bg_4.jpg',
            key: _backgroundImageKey,
            fit: BoxFit.cover,
          ),
        ]);
  }

  Widget _buildGradient() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.2, 0.95],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndSubtitle() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _labels[0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Text(
                _labels[1],
                overflow: TextOverflow.ellipsis,
                maxLines: 4,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Text(
                _labels[2],
                overflow: TextOverflow.ellipsis,
                maxLines: 4,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 10,),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      const MaterialStatePropertyAll(Colors.white60),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)))),
              onPressed: _tryStart,
              child: Text(
                'Начать',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height*0.6,
      margin: const EdgeInsets.symmetric(horizontal: 26),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(children: [
          _buildParallaxBackground(context),
          _buildGradient(),
          _buildTitleAndSubtitle(),
        ]),
      ),
    );
  }
}
