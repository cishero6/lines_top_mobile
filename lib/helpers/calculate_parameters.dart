


num CalculateGeneralCalories({required num age,required num height,required num weight,required num coefficient}){
  return (655 + 9.6 * weight + 1.8 * height + 4.7 * age * coefficient).round();
}

Map<String,num> CalculateBZU({required num calories}){
  if (calories < 1200) {
    return {'Белки (г)': (calories * 0.27).round(), 'Жиры (г)': (calories * 0.19).round(), 'Углеводы (г)': (calories * 0.54).round()};
  }
  if(calories < 1800){
    return {'Белки (г)': (calories * 0.30).round(), 'Жиры (г)': (calories * 0.20).round(), 'Углеводы (г)': (calories * 0.50).round()};
  }
  if(calories< 2250){
    return {'Белки (г)': (calories * 0.19).round(), 'Жиры (г)': (calories * 0.27).round(), 'Углеводы (г)': (calories * 0.54).round()};
  }
  return {'Белки (г)': (calories * 0.19).round(), 'Жиры (г)': (calories * 0.26).round(), 'Углеводы (г)': (calories * 0.55).round()
  };
}

Map<String,String> CalculateBZUStrings({required num calories}){
  if (calories < 1200) {
    return {'Белки (г)': 'Белки | ${(calories * 0.27).round().toString()} г | 27%', 'Жиры (г)': 'Жиры | ${(calories * 0.19).round().toString()} г | 19%', 'Углеводы (г)': 'Углеводы | ${(calories * 0.54).round().toString()} г | 54%'};
  }
  if(calories < 1800){
    return {'Белки (г)': 'Белки | ${(calories * 0.3).round().toString()} г | 30%', 'Жиры (г)': 'Жиры | ${(calories * 0.20).round().toString()} г | 20%', 'Углеводы (г)': 'Углеводы | ${(calories * 0.50).round().toString()} г | 50%'};
  }
  if(calories< 2250){
    return {'Белки (г)': 'Белки | ${(calories * 0.19).round().toString()} г | 19%', 'Жиры (г)': 'Жиры | ${(calories * 0.27).round().toString()} г | 27%', 'Углеводы (г)': 'Углеводы | ${(calories * 0.54).round().toString()} г | 54%'};
  }
  return {'Белки (г)': 'Белки | ${(calories * 0.19).round().toString()} г | 19%', 'Жиры (г)': 'Жиры | ${(calories * 0.26).round().toString()} г | 26%', 'Углеводы (г)': 'Углеводы | ${(calories * 0.55).round().toString()} г | 55%'
  };
}

Map<String,num> CalculatePercentBZU({required num calories}){
   if (calories < 1200) {
    return {'Белки (г)': 27, 'Жиры (г)': 19, 'Углеводы (г)': 54};
  }
  if(calories < 1800){
    return {'Белки (г)': 30, 'Жиры (г)':20, 'Углеводы (г)':50};
  }
  if(calories< 2250){
    return {'Белки (г)': 19, 'Жиры (г)':27, 'Углеводы (г)': 54};
  }
  return {'Белки (г)': 19, 'Жиры (г)': 26, 'Углеводы (г)': 55
  };
}

Map<String,num> CalculateDistribution({required num calories}){
  return {
    'Завтрак': (calories*0.25).round(),
    '2-ой завтрак': (calories*0.1).round(),
    'Обед': (calories*0.35).round(),
    'Полдник': (calories*0.1).round(),
    'Ужин': (calories*0.2).round(),
  };
} 
Map<String,num> GetDistributionPercentages() {
  return {
    'Завтрак': 25,
    '2-ой завтрак':10,
    'Обед':35,
    'Полдник':10,
    'Ужин':20,
  };
}

