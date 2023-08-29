// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lines_top_mobile/helpers/purchase_api.dart';
import 'package:lines_top_mobile/widgets/offer_item.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});
  static const routeName = '/info';
  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {


  Future fetchOffers() async {
    final offerings  = await PurchaseApi.fetchOffers();

    if (offerings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Нет предложений!',style: Theme.of(context).textTheme.bodyMedium,),backgroundColor: Colors.white70,));
    }
  final offer = offerings.first;
  print('Offer - $offer');
  }

  @override
  void initState() {
    
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/backgrounds/bg_10.jpg'),fit: BoxFit.cover,opacity: 0.5)),
        child:  const CustomScrollView(
          
          slivers: [
            SliverToBoxAdapter(child: SafeArea(child: SizedBox()),),
            SliverToBoxAdapter(child: OfferItem()),
        ],),
      ),
    );
  }
}