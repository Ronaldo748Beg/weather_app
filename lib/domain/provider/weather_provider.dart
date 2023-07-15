import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/domain/api/api.dart';
import 'package:weather_app/domain/hive/favorite_history.dart';
import 'package:weather_app/domain/hive/hive_boxes.dart';
import 'package:weather_app/domain/model/coord.dart';
import 'package:weather_app/domain/model/weather_data.dart';
import 'package:weather_app/ui/resources/app_bg.dart';
import 'package:weather_app/ui/theme/app_colors.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherProvider() {
    setBg();
  }
  // хранение координат
  static Coord? coords;

  // хранение данных о погоде
  WeatherData? weatherData;

  // Хранение текущих данных о погоде
  Current? current;

  // Контролер поиска

  final SearchController = TextEditingController();

  // Главная функция
  Future<WeatherData?> setUp({String? cityName}) async {
    final pref = await SharedPreferences.getInstance();
    cityName = pref.getString('city_name');
    
    coords = await Api.getCoords(cityName: cityName ?? 'Ташкент');
    weatherData = await Api.getWeather(coords);
    current = weatherData?.current;

    setCurrentTime();
    setCurrentTemp();
    setMaxTemp();
    setMiniTemp();
    setSevenDays();
    getCurrentZone();
    return weatherData;
  }

// установка текущего города

void setCurrentCity(BuildContext context , {String? cityName}) async{
  if (SearchController.text != ''){
    cityName = SearchController.text;
    final pref = await SharedPreferences.getInstance();
    await pref.setString('city_name', cityName);
    await setUp(cityName: pref.getString('city_name'))
    .then((value) => Navigator.pop(context))
    .then((value) => SearchController.clear());
    notifyListeners();
  }
}

// получение города

String currentZone = '';
Future<String> getCurrentZone()async{
  final pref = await SharedPreferences.getInstance();
  currentZone = pref.getString('city_name') ?? '';
  return currentZone;
}




  // Изменение заднего фона
  String? currentBg;

  String setBg() {
    int id = current?.weather?[0].id ?? -1;
    if (id == -1 || current?.sunset == null || current?.dt == null) {
      currentBg = AppBg.shinyDay;
    }

    try {
      if (current!.sunset! < current!.dt!) {
        if (id >= 200 && id <= 531) {
          currentBg = AppBg.rainyNight;
        } else if (id >= 600 && id <= 622) {
          currentBg = AppBg.snowNight;
        } else if (id >= 701 && id <= 781) {
          currentBg = AppBg.fogNight;
        } else if (id == 800) {
          currentBg = AppBg.shinyNight;
          AppColors.iconColor = AppColors.whiteColor;
        } else if (id >= 801 && id <= 804) {
          currentBg = AppBg.cloudyNight;
        }
      } else {
        if (id >= 200 && id <= 531) {
          currentBg = AppBg.rainyDay;
        } else if (id >= 600 && id <= 622) {
          currentBg = AppBg.snowDay;
        } else if (id >= 701 && id <= 781) {
          currentBg = AppBg.fogDay;
        } else if (id == 800) {
          currentBg = AppBg.shinyDay;
        } else if (id >= 801 && id <= 804) {
          currentBg = AppBg.cloudyDay;
        }
      }
    } catch (e) {
      return AppBg.shinyDay;
    }

    return currentBg ?? AppBg.shinyDay;
  }

  //текущее времья
  String? currentTime;
  String setCurrentTime() {
    final getTime = (current?.dt ?? 0) + (weatherData?.timezoneOffset ?? 0);
    final setTime = DateTime.fromMillisecondsSinceEpoch(getTime * 1000);
    currentTime = DateFormat('HH:mm a').format(setTime);
    return currentTime ?? 'error';
  }

  String capitalize(String str) => str[0].toUpperCase() + str.substring(1);
  // текущий статус погоды
  String currentStatus = 'Error';
  String getCurrentStatus() {
    currentStatus = current?.weather?[0].description ?? 'Error';
    return capitalize(currentStatus);
  }

  //https://openweathermap.org/img/wn/

  String weatherIconsUrl = 'https://openweathermap.org/img/wn/';
  //получение текущей иконки
  String iconData() {
    return '$weatherIconsUrl${current?.weather?[0].icon}.png';
  }

  // пол текущей темп
  int kelvin = -273;
  int currentTemp = 0;
  int setCurrentTemp() {
    currentTemp = ((current?.temp ?? -kelvin) + kelvin).round();
    return currentTemp;
  }

  // max temp
  dynamic maxTemp = 0;
  int setMaxTemp() {
    maxTemp = ((weatherData?.daily?[0].temp?.max ?? -kelvin) + kelvin).round();

    return maxTemp;
  }

  dynamic minTemp;
  setMiniTemp() {
    minTemp = ((weatherData?.daily?[0].temp?.min ?? -kelvin) + kelvin).round();

    return minTemp;
  }

  //установка дни недели

  final List<String> _date = [];
  List<String> get date => _date;

  List<Daily> _daily = [];
  List<Daily> get daily => _daily;
  void setSevenDays() {
    _daily = weatherData?.daily ?? [];

    for (var i = 0; i < _daily.length; i++) {
      if (i == 0 && _daily.isNotEmpty) {
        _date.clear();
      }

      if (i == 0) {
        date.add('Сегодня');
      } else {
        var timeNum = _daily[i].dt * 1000;
        var itemDate = DateTime.fromMillisecondsSinceEpoch(timeNum);
        _date.add(capitalize(DateFormat('EEEE', 'ru').format(itemDate)));
      }
    }
  }

  // получение иконок для каждлго дня недели
  final String _iconUrlPath = 'https://openweathermap.org/img/wn/';
  String setDailyIcon(int index) {
    final String getIcon = '${weatherData?.daily?[index].weather?[0].icon}';
    final String setIcon = '$_iconUrlPath$getIcon.png';

    return setIcon;
  }

  // получение дневной теп на каждый день
  int dailyTemp = 0;
  int setDailyTemp(int index) {
    dailyTemp =
        ((weatherData?.daily?[index].temp?.day ?? -kelvin) + kelvin).round();

    return dailyTemp;
  }

  // получение дневной теп на каждый день
  int nightTemp = 0;
  int setNightTemp(int index) {
    nightTemp =
        ((weatherData?.daily?[index].temp?.night ?? -kelvin) + kelvin).round();

    return nightTemp;
  }

  // добавление данных по погодных условияъ
  final List<dynamic> _weatherValues = [];
  List<dynamic> get weatherValues => _weatherValues;
  dynamic setValues(int index) {
    _weatherValues.add(current?.windSpeed ?? 0);
    _weatherValues.add(((current?.feelsLike ?? -kelvin) + kelvin).round());
    _weatherValues.add((current?.humidity ?? 0) / 1);
    print(current?.humidity);
    _weatherValues.add((current?.visibility ?? 0) / 1000);
    print(current?.visibility);
    return weatherValues[index];
  }

  //текущее время восхода
  String sunRise = '';
  String setCurrentSunrise() {
    final getSunTime =
        (current?.sunrise ?? 0) + (weatherData?.timezoneOffset ?? 0);
    final setSunRise = DateTime.fromMillisecondsSinceEpoch(getSunTime * 1000);
    sunRise = DateFormat('HH:mm a').format(setSunRise);
    return sunRise;
  }

// тек время заката
  String sunSet = '';
  String setCurrentSunSent() {
    final getSunTime =
        (current?.sunset ?? 0) + (weatherData?.timezoneOffset ?? 0);
    final setSunSet = DateTime.fromMillisecondsSinceEpoch(getSunTime * 1000);
    sunSet = DateFormat('HH:mm a').format(setSunSet);
    return sunSet;
  }
  // добавление в избранное

Future<void> setFavorite(BuildContext context, {String? cityName}) async {
  var box = Hive.box<FavoriteHistory>(HiveBoxes.favoriteBox);

  box.add(
    FavoriteHistory(weatherData?.timezone ?? 'Error',
    currentBg ?? AppBg.shinyDay,
    AppColors.iconColor.value
    ),
  )
  .then((value) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
    backgroundColor: AppColors.sevenDaysBoxColor,
    content: Text( 'Город $cityName добавлен в избранное',),
    ),
    ),
    );
}

// удаление из избранного

Future<void> deleteFavorite(int index) async{
    var box = Hive.box<FavoriteHistory>(HiveBoxes.favoriteBox);
    box.deleteAt(index);
}


}


