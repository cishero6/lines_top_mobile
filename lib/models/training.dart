import 'exercise.dart';
import 'lines_top_model.dart';

class Training extends LinesTopModel{
  @override
  String id = ''; // Идентификатор тренировки
  @override
  String title = ''; //Название тренировки
  Map<String,List<Exercise>> sections = {}; //Секции

  Training.empty();
  Training({this.id='',this.title = '',Map<String,List<Exercise>>? sections}){
    this.sections = sections ?? {};
  }


}