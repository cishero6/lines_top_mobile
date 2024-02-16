// // ignore_for_file: use_build_context_synchronously

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:lines_top_mobile/providers/user_data_provider.dart';
// import 'package:lines_top_mobile/providers/verification_id_provider.dart';
// import 'package:lines_top_mobile/screens/navigation_bar_screens/profile_screen.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
// import 'package:provider/provider.dart';

// class DeleteAccountVerificationScreen extends StatefulWidget {
//   const DeleteAccountVerificationScreen({super.key});
//   static const routeName = 'profile/change_data/delete_account_verification';
//   @override
//   State<DeleteAccountVerificationScreen> createState() => _DeleteAccountVerificationScreenState();
// }

// class _DeleteAccountVerificationScreenState extends State<DeleteAccountVerificationScreen> {

//   late UserDataProvider userDataProvider;
//   late VerificationIdProvider verificationIdProvider;
  
//   final TextEditingController _codeTextEditingController = TextEditingController();

//   late Widget Function() _currentBuild;

//   bool _codeDone = false;
//   String _smsCode='';


//   void _deleteUser()async{
//     String result = await userDataProvider.deleteUser(PhoneAuthProvider.credential(verificationId: verificationIdProvider.verificationId, smsCode: _smsCode));
//     if(result == 'Успешно!'){
//       Navigator.of(context).pushNamedAndRemoveUntil(ProfileScreen.routeName, (route) => false);
//     }
//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result,style: Theme.of(context).textTheme.titleSmall,),backgroundColor: Colors.white70,));
//   }


//   void _sendCode() async {
//     FocusManager.instance.primaryFocus!.unfocus();
//     await userDataProvider.verifyPhoneNumber(userDataProvider.phoneNumber!,ctx: context);
//   }

//   Widget _buildInfoColumn(){
// return Column(children: [
//         const SizedBox(height: 100,),
//         SizedBox(width: MediaQuery.of(context).size.width * 0.7,child: Text('Для удаления аккаунта нам потребуется подтверждение, что вы владеете аккаунтом. Необходимо подтверждение номера!',style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),maxLines: 10,textAlign: TextAlign.center,)),
//         Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: SizedBox(width: MediaQuery.of(context).size.width * 0.7,child: Text('Ваш номер - ${userDataProvider.phoneNumber}',style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white,fontWeight: FontWeight.bold),textAlign: TextAlign.center,)),
//         ),
//         ElevatedButton(onPressed: _sendCode, child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Text('Отправить СМС-код',style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),),
//         )),
//       ],);
//   }

//   Widget _buildLastConfirm(){
//     return Column(children: [
//         SizedBox(height: MediaQuery.of(context).size.height*0.2,),
//         SizedBox(width: MediaQuery.of(context).size.width * 0.7,height: 70,child: Text('Удалить аккаунт?',textAlign: TextAlign.center,style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white,fontWeight: FontWeight.bold))),
//         ElevatedButton(onPressed: _deleteUser, child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Text('Да, я хочу удалить аккаунт',style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.red),),
//         )),
//       ],);
//   }

//   Widget _buildAskCode(){
//     return UnconstrainedBox(
//       child: ConstrainedBox(
//                 constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.8,minWidth: 100),
//         child: Column(
//                   children: [
//                     SizedBox(height: MediaQuery.of(context).size.height*0.2,),
//                     Text('Код из SMS',style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white),),
//                     PinCodeTextField(
//                       appContext: context,
//                       length: 6,
//                       controller: _codeTextEditingController,
//                       cursorColor: Colors.white70,
//                       keyboardType: TextInputType.number,
//                       onCompleted: (value){
//                         setState(() {
//                           _codeDone = true;
//                           _smsCode = value;
//                         });
//                       },
//                       textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),
//                     ),
//                   ],),
//       ),
//     );
//   }
//   @override
//   void initState() {
//     verificationIdProvider = Provider.of<VerificationIdProvider>(context,listen:false);
//     userDataProvider = Provider.of<UserDataProvider>(context,listen: false);
//     verificationIdProvider.removeVerificationId();
//     super.initState();
//   }

//   void _setCurrentBuild(){
//     if(verificationIdProvider.verificationId == ''){
//       _currentBuild = _buildInfoColumn;
//       return;
//     }
//     if(!_codeDone){
//       _currentBuild = _buildAskCode;
//       return;
//     }
//     _currentBuild = _buildLastConfirm;
//   }

//   @override
//   Widget build(BuildContext context) {
//     verificationIdProvider = Provider.of<VerificationIdProvider>(context);

//     _setCurrentBuild();
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/backgrounds/bg_14.jpg'),fit: BoxFit.cover)),
//         child: CustomScrollView(slivers: [
//               SliverAppBar(
//                 title: Text('Удаление аккаунта',style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white,fontWeight: FontWeight.bold),),
//                 backgroundColor: Colors.transparent,
//                 surfaceTintColor: Colors.white12,
//               ),
//               SliverToBoxAdapter(child: _currentBuild(),),
//         ]),),
//     );
//   }
// }