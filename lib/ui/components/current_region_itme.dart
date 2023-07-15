import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/domain/provider/weather_provider.dart';
import 'package:weather_app/ui/theme/app_colors.dart';
import 'package:weather_app/ui/theme/app_style.dart';

class CurrentRegionItem extends StatelessWidget {
  const CurrentRegionItem({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<WeatherProvider>();
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          image: DecorationImage(
              image: AssetImage(
                model.setBg(),
              ),
              fit: BoxFit.cover),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CurrentRegionTimeZone(
              currentCity: model.weatherData?.timezone,
              currentZone: model.weatherData?.timezone,
            ),
          CurrentRegionTemp(),
          ],
        ),
      ),
    );
  }
}

class CurrentRegionTimeZone extends StatelessWidget {
  const CurrentRegionTimeZone(
      {super.key, required this.currentCity, required this.currentZone});
  final String? currentCity, currentZone;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(
        'Текущее место',
        style: AppStyle.fontStyle.copyWith(
          color: AppColors.iconColor,
          fontSize: 12,
        ),
      ),
      const SizedBox(
        height: 6,
      ),
      Text(
        currentZone ?? 'Error',
        style: AppStyle.fontStyle.copyWith(
            color: AppColors.iconColor,
            fontSize: 18,
            fontWeight: FontWeight.w700),
      ),
      const SizedBox(
        height: 6,
      ),
      Text(
        currentCity ?? 'Error',
        style: AppStyle.fontStyle.copyWith(
            color: AppColors.iconColor,
            fontSize: 14,
            fontWeight: FontWeight.w700),
      ),
    ]);
  }
}


class CurrentRegionTemp extends StatelessWidget {
  const CurrentRegionTemp({super.key, });


  @override
  Widget build(BuildContext context) {
    final model = context.watch<WeatherProvider>();
    return Row(
      children: [
        Image.network(model.iconData(),),
        Text('${model.setCurrentTemp()} °C',
        style: AppStyle.fontStyle.copyWith(
          fontSize: 18,
          color: AppColors.iconColor,
        ),
        ),
      ],
    );
  }
}