import 'package:flutter/material.dart';
import 'package:onepref/onepref.dart';
import 'package:revenue_cat_in_app_purchase/revenue_cat/views/buy_coins.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text(
          'Total coins : ${OnePref.getInt('coins')}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BuyCoins(),
                      ));
                },
                child: const Text('Buy Coins')),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BuyCoins(),
                      ));
                },
                child: const Text('Subscription'))
          ],
        ),
      ),
    );
  }
}
