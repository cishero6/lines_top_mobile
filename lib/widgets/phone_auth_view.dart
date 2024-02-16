// // ignore_for_file: use_build_context_synchronously

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:lines_top_mobile/providers/user_data_provider.dart';
// import 'package:lines_top_mobile/providers/verification_id_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
// import '../helpers/network_connectivity.dart';
// import '../helpers/phone_auth_status.dart';

// class PhoneAuthView extends StatefulWidget {
//   const PhoneAuthView({super.key});

//   @override
//   State<PhoneAuthView> createState() => _PhoneAuthViewState();
// }

// class _PhoneAuthViewState extends State<PhoneAuthView> with TickerProviderStateMixin{

//   late AnimationController _animationController;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _opacityAnimation;

//   TextEditingController _nameTextEditingController = TextEditingController();
//   TextEditingController _phoneTextEditingController = TextEditingController();
//   TextEditingController _codeTextEditingController = TextEditingController();


// late UserDataProvider userProvider;
// late VerificationIdProvider verificationProvider;

// bool _nameAnimated = false;
// bool _phoneAnimated = false;
// bool _pinAnimated = false;
// bool _choiceAnimated = false;

// late Widget Function() _currentBuild;




//   void _sendCode()async{
//     print('no way - send code');
//     FocusManager.instance.primaryFocus!.unfocus();
//     if(_phoneTextEditingController.text.length != 10){
//             ScaffoldMessenger.of(context).clearSnackBars();

//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Неверный формат номера!',style: Theme.of(context).textTheme.titleMedium,),backgroundColor: Colors.white70,));
//       return;
//     }
//         bool internetConnected = await NetworkConnectivity.checkConnection();
//     if(!internetConnected){
//       ScaffoldMessenger.of(context).clearSnackBars();
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Отсутвует подключение к интернету!',style: Theme.of(context).textTheme.titleMedium,),backgroundColor: Colors.white70,duration: const Duration(seconds: 6),));
//       return ;
//     }
//       bool exists = await userProvider.doesUserExist('+7${_phoneTextEditingController.text}');
//     if(!isReg!){
//       if (!exists){
//         ScaffoldMessenger.of(context).clearSnackBars();
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Такого пользователя нет!',style: Theme.of(context).textTheme.titleMedium,),backgroundColor: Colors.white70,duration: const Duration(seconds: 6),));
//         return;
//       }
//     }else{
//       if(exists){
//         ScaffoldMessenger.of(context).clearSnackBars();
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Номер уже используется!',style: Theme.of(context).textTheme.titleMedium,),backgroundColor: Colors.white70,duration: const Duration(seconds: 6),));
//         return;
//       }
//     }
//     String result = await userProvider.verifyPhoneNumber('+7${_phoneTextEditingController.text}',ctx: context);
//     if (result != ''){
//         ScaffoldMessenger.of(context).clearSnackBars();
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result,style: Theme.of(context).textTheme.titleMedium,),backgroundColor: Colors.white70,duration: const Duration(seconds: 6),));
//     }
//   }

//   void _tryAuth(String code)async{

//    String result = await userProvider.phoneSignInUser(verificationProvider.verificationId, code,_nameTextEditingController.text, context: Scaffold.of(context).context);

//     if (result == 'Успешно!') {
//       verificationProvider.setVerificationId('');
//       isReg = null;
//       _nameAnimated = false;
//       _phoneAnimated = false;
//       _pinAnimated = false;
//       _choiceAnimated = false;
//       return;
//     }
//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result,style: Theme.of(context).textTheme.titleMedium,),backgroundColor: Colors.white70,duration: const Duration(seconds: 6),));
//   }

//   void _submitName(){
//     FocusManager.instance.primaryFocus!.unfocus();
//     if(_nameTextEditingController.text.isEmpty){
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Неверный формат!',style: Theme.of(context).textTheme.titleMedium,),backgroundColor: Colors.white70,));
//       return;
//     }
//     print('got name');
//    setState(() {
//     phoneAuthStatus = 2;
//    });
//   }

//   @override
//   void initState() {
//     _animationController =AnimationController(vsync: this,duration: const Duration(milliseconds: 600));
//     _opacityAnimation = Tween(begin: 0.0,end: 1.0).animate(_animationController);
//     _slideAnimation = Tween(begin: const Offset(0, 1),end: const Offset(0.0, 0.0)).animate(CurvedAnimation(parent: _animationController, curve: Curves.fastLinearToSlowEaseIn));
//     Provider.of<VerificationIdProvider>(context,listen: false).removeVerificationId();
//     super.initState();
//   }


// Widget _buildAskName(){
//   print("ask NAME");
//    if(mounted && !_nameAnimated){
//        _nameAnimated = true;
//       _animationController.reset();
//       _animationController.forward();
//     }
// return FadeTransition(
//   opacity: _opacityAnimation,
//   child:   SlideTransition(
//     position: _slideAnimation,
//     child: Column(
//           children: [
//             Text(
//               'Введите ваше имя\n',
//               style: Theme.of(context)
//                   .textTheme
//                   .titleLarge!
//                   .copyWith(color: Colors.white),
//               textAlign: TextAlign.center,
//             ),
//             UnconstrainedBox(
//                 child: SizedBox(
//               width: MediaQuery.of(context).size.width * 0.5,
//               child: CupertinoTextField(
//                 controller: _nameTextEditingController,
//                 prefix: Text(
//                   ' ',
//                   style: Theme.of(context).textTheme.bodyLarge!,
//                 ),
//                 style: Theme.of(context).textTheme.bodyLarge,
//               ),
//             )),
//             UnconstrainedBox(
//               child: Padding(
//                 padding: const EdgeInsets.all(22.0),
//                 child: ElevatedButton(onPressed: _submitName, child: Text('Готово',style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white,fontWeight: FontWeight.w600),)),
//               ),
//             ),
//             UnconstrainedBox(
//               child: Padding(
//                 padding: const EdgeInsets.all(22.0),
//                 child: TextButton(onPressed: ()=>setState((){isReg = null;phoneAuthStatus = 0;}), child: Text('Назад',style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white,fontWeight: FontWeight.w600),)),
//               ),
//             ),
//           ],
//         ),
//   ),
// );
// }

//   Widget _buildPhoneNumberForm(){
//     print('Ask Number');
//     if(mounted && !_phoneAnimated){
//       _phoneAnimated = true;
//       _animationController.reset();
//       _animationController.forward();
//     }
//     print(_phoneTextEditingController.text);
//     print(isReg);
// return FadeTransition(
//   opacity: _opacityAnimation,
//   child:   SlideTransition(
//     position: _slideAnimation,
//     child: Column(
//           children: [
//             Text(
//               'Введите номер телефона\n',
//               style: Theme.of(context)
//                   .textTheme
//                   .titleLarge!
//                   .copyWith(color: Colors.white),
//               textAlign: TextAlign.center,
//             ),
//             UnconstrainedBox(
//                 child: SizedBox(
//               width: MediaQuery.of(context).size.width * 0.5,
//               child: CupertinoTextField(
//                 controller: _phoneTextEditingController,
//                 prefix: Text(
//                   ' +7',
//                   style: Theme.of(context).textTheme.bodyLarge!,
//                 ),
//                 keyboardType: TextInputType.number,
//                 style: Theme.of(context).textTheme.bodyLarge,
//               ),
//             )),
//             UnconstrainedBox(
//               child: Padding(
//                 padding: const EdgeInsets.all(22.0),
//                 child: ElevatedButton(onPressed: _sendCode, child: Text('Выслать код',style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white,fontWeight: FontWeight.w600),)),
//               ),
//             ),
//             UnconstrainedBox(
//               child: Padding(
//                 padding: const EdgeInsets.all(22.0),
//                 child: TextButton(onPressed: ()=>setState((){phoneAuthStatus = isReg! ? 1 : 0; isReg = null;}), child: Text('Назад',style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white,fontWeight: FontWeight.w600),)),
//               ),
//             ),
//           ],
//         ),
//   ),
// );
//   }

//   Widget _buildChoice(){
//     print('Ask choice');
//     if(mounted && !_choiceAnimated){
//       _choiceAnimated = true;
//       _animationController.reset();
//       _animationController.forward();
//     }
//     return FadeTransition(opacity: _opacityAnimation,child: SlideTransition(position: _slideAnimation,child: 
//       Column(
//         children: [
//           const SizedBox(height: 100,),
//           ElevatedButton(onPressed: (){
//             phoneAuthStatus = 2;
//             setState(() {
//             isReg = false;
//           });}, child: Text('Войти',style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white,fontWeight: FontWeight.bold),)),
//           const SizedBox(height: 50,),
//           TextButton(onPressed: (){
//             phoneAuthStatus = 1;
//             setState(() {
//             isReg = true;
//           });
//           }, child: Text('Регистрация',style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),)),
//         ],
//       ),
//     ),);
//   }

//   Widget _buildCodeForm(){
//     if(mounted && !_pinAnimated){
//       _pinAnimated = true;
//       _animationController.reset();
//       _animationController.forward();
//     }
//     return UnconstrainedBox(
//       child: ConstrainedBox(
//         constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.8,minWidth: 100),
//         child: FadeTransition(
//           opacity: _opacityAnimation,
//           child: SlideTransition(
//             position: _slideAnimation,
//             child: Column(
//               children: [
//                 Text('Код из SMS',style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white),),
//                 PinCodeTextField(
//                   appContext: context,
//                   length: 6,
//                   controller: _codeTextEditingController,
//                   cursorColor: Colors.white70,
//                   keyboardType: TextInputType.number,
//                   onCompleted: _tryAuth,
//                   textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),
//                 ),
//                 ElevatedButton(onPressed: (){_phoneAnimated = false; verificationProvider.setVerificationId('');phoneAuthStatus = 2;}, child: Text('Назад',style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white,fontWeight: FontWeight.w600),)),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }


//   void _buildCurrent() {
//     switch (phoneAuthStatus) {
//       case 0:
//         _currentBuild = _buildChoice;
//         break;
//       case 1:
//         _currentBuild = _buildAskName;
//         return;
//       case 2:
//         _currentBuild = _buildPhoneNumberForm;
//         return;
//       case 3:
//         _currentBuild = _buildCodeForm;
//         return;
//       default:
//     }
//     // print('new call \n isReg - $isReg\n needs name - $_needsName\n ver is empty -${verificationProvider.verificationId.isEmpty}');
//     // if(isReg == null){
      
//     //   return;
//     // }
//     // if(isReg!){
//     //   if(_needsName){
        
//     //   }
//     // }
//     // if(verificationProvider.verificationId.isEmpty){
        
//     //   }
//     // if(verificationProvider.verificationId.isNotEmpty){
      
//     // }
//     // _currentBuild = _buildChoice;
//     // return;
//   }




//   @override
//   Widget build(BuildContext context) {
    
//    userProvider  = Provider.of<UserDataProvider>(context,listen: false);
//    verificationProvider = Provider.of<VerificationIdProvider>(context);
//   _buildCurrent();
//     return CustomScrollView(
//       physics: BouncingScrollPhysics(),
//       slivers: [
//         SliverAppBar.large(
//               backgroundColor: Colors.transparent,
//               automaticallyImplyLeading: false,
//               pinned: true,
//               title: Text(
//                 'Вход',
//                 style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.white,fontWeight: FontWeight.bold),
//               ),
//         ),
//        SliverToBoxAdapter(child: _currentBuild(),),
//       ],
//     );
//   }


//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
// }
