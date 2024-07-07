import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../widgets/list_items/new_parameters_list_item.dart';

class RegisterParametersScreen extends StatefulWidget {
  const RegisterParametersScreen({super.key});
  static const routeName = 'profile/parameters/register_parameters';
  @override
  State<RegisterParametersScreen> createState() =>
      _RegisterParametersScreenState();
}

class _RegisterParametersScreenState extends State<RegisterParametersScreen>
    with TickerProviderStateMixin {
  late UserProvider authData;

  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _chestController = TextEditingController();
  final TextEditingController _thighsController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();
  late num _activityCoefficient = 0;

  final Map<String, num> _activityOptions = {
    'Спортом не занимаюсь': 1.2,
    'Спортом не занимаюсь, но много хожу (почти каждый день около 10к шагов и больше)':
        1.3,
    'Занимаюсь спортом 1-2 раза в неделю': 1.6,
    'Занимаюсь спортом 3-4 раза в неделю': 1.7,
    'Занимаюсь спортом более 5 раз в неделю': 1.9,
  };

  late String _dropDownValue;

  void _submit() async {
    FocusManager.instance.primaryFocus!.unfocus();
    Map<String, List<num>> newData = {};
    if (_ageController.text == '0' || _ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Введите корректный возраст',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        backgroundColor: Colors.white70,
      ));
      return;
    }
    if (_heightController.text == '0' || _heightController.text.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Введите корректный рост',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        backgroundColor: Colors.white70,
      ));
      return;
    }
    if (_weightController.text == '0' || _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Введите корректный вес',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        backgroundColor: Colors.white70,
      ));
      return;
    }
    if (_chestController.text == '0' || _chestController.text.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Введите корректный обхват груди',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        backgroundColor: Colors.white70,
      ));
      return;
    }
    if (_thighsController.text == '0' || _thighsController.text.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Введите корректный обхват бедер',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        backgroundColor: Colors.white70,
      ));
      return;
    }
    if (_waistController.text == '0' || _waistController.text.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Введите корректный обхват талии',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        backgroundColor: Colors.white70,
      ));
      return;
    }
    newData.addAll({
      'age': [double.parse(_ageController.text.replaceAll(',', '.'))]
    });
    newData.addAll({
      'thighs': [double.parse(_thighsController.text.replaceAll(',', '.'))]
    });
    newData.addAll({
      'height': [double.parse(_heightController.text.replaceAll(',', '.'))]
    });
    newData.addAll({
      'weight': [double.parse(_weightController.text.replaceAll(',', '.'))]
    });
    newData.addAll({
      'chest': [double.parse(_chestController.text.replaceAll(',', '.'))]
    });
    newData.addAll({
      'waist': [double.parse(_waistController.text.replaceAll(',', '.'))]
    });
    newData.addAll({
      'activity': [_activityCoefficient]
    });
    String result = await authData.updateStatistics(newData);
    if (result == '') {Navigator.of(context).pop();return;};
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        result,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      backgroundColor: Colors.white70,
    ));
  }

  @override
  void initState() {
    authData = Provider.of<UserProvider>(context, listen: false);
    _dropDownValue = _activityOptions.keys.toList()[0];
    _activityCoefficient = _activityOptions[_dropDownValue]!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/backgrounds/bg_15.jpg'),
                fit: BoxFit.cover)),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text(
                'Новые параметры',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.white12,
            ),
            SliverList.list(children: [
              NewParametersListItem(
                  leadingText: 'Возраст:',
                  textEditingController: _ageController,
                  initialValue: ''),
              NewParametersListItem(
                  leadingText: 'Рост (см):',
                  textEditingController: _heightController,
                  initialValue: ''),
              NewParametersListItem(
                  leadingText: 'Вес (кг):',
                  textEditingController: _weightController,
                  initialValue: ''),
              NewParametersListItem(
                leadingText: 'Обхват груди (см):',
                textEditingController: _chestController,
                initialValue: '',
                isRightAligned: true,
              ),
              NewParametersListItem(
                  leadingText: 'Обхват бедра (см):',
                  textEditingController: _thighsController,
                  initialValue: '',
                  isRightAligned: true),
              NewParametersListItem(
                  leadingText: 'Обхват талии (см):',
                  textEditingController: _waistController,
                  initialValue: '',
                  isRightAligned: true),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Моя активность',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.white),
                ),
              ),
              DropdownButton(
                  dropdownColor: Colors.black45,
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
                  }),
            ]),
            SliverToBoxAdapter(
              child: UnconstrainedBox(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(
                      'Подтвердить',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: Colors.white),
                    )),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
