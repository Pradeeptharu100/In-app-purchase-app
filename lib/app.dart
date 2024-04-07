import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:revenue_cat_in_app_purchase/model/styles.dart';
import 'package:revenue_cat_in_app_purchase/views/buy_coins.dart';

class MagicWeatherFlutter extends StatelessWidget {
  const MagicWeatherFlutter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      localizationsDelegates: [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        barBackgroundColor: kColorBar,
        primaryColor: kColorText,
        textTheme: CupertinoTextThemeData(
          primaryColor: kColorText,
        ),
      ),
      home: BuyCoins(),
    );
  }
}
