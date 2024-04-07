import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:onepref/onepref.dart';
import 'package:revenue_cat_in_app_purchase/main.dart';
import 'package:revenue_cat_in_app_purchase/views/buy_coins.dart';
import 'package:revenue_cat_in_app_purchase/views/subsctiption_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    restoreSub();
    iApEngine.inAppPurchase.purchaseStream.listen((list) {
      if (list.isNotEmpty) {
        int i = 0;

        for (var element in list) {
          log('List  Data: ${list[i].verificationData.localVerificationData}');
          log('element :${element.verificationData.localVerificationData}');
          i++;
        }
        log('Form A');
        OnePref.setPremium(true);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SubscriptionScreen(),
            ));
      } else {
        log('Form B');

        OnePref.setPremium(false);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BuyCoins(),
            ));
      }
    });
  }

  restoreSub() {
    iApEngine.inAppPurchase.restorePurchases();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Loading ....'),
        ],
      ),
    );
  }
}
