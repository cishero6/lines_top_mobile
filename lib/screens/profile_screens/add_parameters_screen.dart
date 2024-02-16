// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lines_top_mobile/widgets/list_items/new_parameters_list_item.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';

class AddParametersScreen extends StatefulWidget {
  const AddParametersScreen({super.key});
  static const routeName = 'profile/parameters/add_parameters';
  @override
  State<AddParametersScreen> createState() => _AddParametersScreenState();
}

class _AddParametersScreenState extends State<AddParametersScreen> {
  late UserProvider authData;

  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _chestController = TextEditingController();
  final TextEditingController _thighsController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();
  late num _activityCoefficient = 0;

  final Map<String,num> _activityOptions = {
    'Спортом не занимаюсь' : 1.2,
    'Спортом не занимаюсь, но много хожу (почти каждый день около 10к шагов и больше)' : 1.3,
    'Занимаюсь спортом 1-2 раза в неделю': 1.6,
    'Занимаюсь спортом 3-4 раза в неделю': 1.7,
    'Занимаюсь спортом более 5 раз в неделю': 1.9,
  };

  late String _dropDownValue;



  void _submit()async{
    FocusManager.instance.primaryFocus!.unfocus();
    Map<String,List<num>> newData = {};
    if(_ageController.text == '0'){
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Введите корректный возраст',style: Theme.of(context).textTheme.titleMedium,),backgroundColor: Colors.white70,));
      return;
    }
    if(_heightController.text == '0'){
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Введите корректный рост',style: Theme.of(context).textTheme.titleMedium,),backgroundColor: Colors.white70,));
      return;
    }
    if(_weightController.text == '0'){
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Введите корректный вес',style: Theme.of(context).textTheme.titleMedium,),backgroundColor: Colors.white70,));
      return;
    }
    if(_chestController.text == '0'){
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Введите корректный обхват груди',style: Theme.of(context).textTheme.titleMedium,),backgroundColor: Colors.white70,));
      return;
    }
    if(_thighsController.text == '0'){
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Введите корректный обхват бедер',style: Theme.of(context).textTheme.titleMedium,),backgroundColor: Colors.white70,));
      return;
    }
    if(_waistController.text == '0'){
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Введите корректный обхват талии',style: Theme.of(context).textTheme.titleMedium,),backgroundColor: Colors.white70,));
      return;
    }
    if(_ageController.text != ''){
      newData.addAll({'age': [double.parse(_ageController.text.replaceAll(',', '.'))]});
    }
    if(_thighsController.text != ''){
      newData.addAll({'thighs': [double.parse(_thighsController.text.replaceAll(',', '.'))]});
    }
    if(_heightController.text != ''){
      newData.addAll({'height': [double.parse(_heightController.text.replaceAll(',', '.'))]});
    }
    if(_weightController.text != ''){
      newData.addAll({'weight': [double.parse(_weightController.text.replaceAll(',', '.'))]});
    }
    if(_chestController.text != ''){
      newData.addAll({'chest': [double.parse(_chestController.text.replaceAll(',', '.'))]});
    }
    if(_waistController.text != ''){
      newData.addAll({'waist': [double.parse(_waistController.text.replaceAll(',', '.'))]});
    }
    if(_activityCoefficient != authData.statistics!['activity']!.last){
      newData.addAll({'activity': [_activityCoefficient]});
    }
    if(newData.isEmpty){
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Новых данных нет!',style: Theme.of(context).textTheme.titleMedium,),backgroundColor: Colors.white70,));
      return;
    }
    String result = await authData.updateStatistics(newData);
     if(result == '') Navigator.of(context).pop();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result == '' ? 'Успешно!' : result,style: Theme.of(context).textTheme.titleMedium,),backgroundColor: Colors.white70,));
  }

  @override
  void initState() {
    authData = Provider.of<UserProvider>(context,listen: false);
    _dropDownValue =_activityOptions.keys.toList()[_activityOptions.values.toList().indexOf(authData.statistics!['activity']!.last)];
        _activityCoefficient = _activityOptions[_dropDownValue]!;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/backgrounds/bg_15.jpg'),fit: BoxFit.cover)),
        child: CustomScrollView(
          slivers: [
              SliverAppBar.large(
                title: Text('Новые параметры',style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white,fontWeight: FontWeight.bold),),
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.white12,
              ),
              SliverList.list(children: [
                NewParametersListItem.fixed(leadingText: 'Возраст:', textEditingController: _ageController, initialValue: authData.statistics!['age']!.last.toString()),
                NewParametersListItem.fixed(leadingText: 'Рост (см):', textEditingController: _heightController, initialValue: authData.statistics!['height']!.last.toString()),
                NewParametersListItem(leadingText: 'Вес (кг):', textEditingController: _weightController,initialValue: authData.statistics!['weight']!.last.toString()),
                NewParametersListItem(leadingText: 'Обхват груди (см):', textEditingController: _chestController,initialValue: authData.statistics!['chest']!.last.toString(),isRightAligned: true,),
                NewParametersListItem(leadingText: 'Обхват бедра (см):', textEditingController: _thighsController,initialValue: authData.statistics!['thighs']!.last.toString(),isRightAligned: true),
                NewParametersListItem(leadingText: 'Обхват талии (см):', textEditingController: _waistController,initialValue: authData.statistics!['waist']!.last.toString(),isRightAligned: true),
                Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Моя активность:',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white),
                ),
              ),
              DropdownButton(
                dropdownColor: Colors.black54,
                isExpanded: true,
                value: _dropDownValue,
                items: _activityOptions.keys
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _dropDownValue = value!;
                    _activityCoefficient = _activityOptions[value]!;
                  });
                },
              ),
                
              ]),
            SliverToBoxAdapter(child: UnconstrainedBox(child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(onPressed: _submit, child: Text('Подтвердить',style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),)),
            )),),
          ],
        ),
      ),
    );
  }
}