import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:onepref/onepref.dart';
import 'package:revenue_cat_in_app_purchase/main.dart';

class BuyCoins extends StatefulWidget {
  const BuyCoins({super.key});

  @override
  State<BuyCoins> createState() => _BuyCoinsState();
}

class _BuyCoinsState extends State<BuyCoins> {
  final List<ProductDetails> products = [];
  int rewards = 0;
  final List<ProductId> storeProductId = [
    ProductId(id: "rc_trail_test", isConsumable: true, reward: 10),
    ProductId(id: "rc_premium_monthly", isConsumable: true, reward: 10),
    ProductId(id: "rc_premium_yearly", isConsumable: true, reward: 10),
    ProductId(id: "coins_10", isConsumable: true, reward: 10),
  ];
  @override
  void initState() {
    super.initState();

    iApEngine.inAppPurchase.purchaseStream.listen((listen) {
      log('Listen Purchased  : $listen');
      listenPurchase(listen);
    });
    getProducts();
    rewards = OnePref.getInt('coins') ?? 0;
  }

  getProducts() async {
    try {
      await iApEngine.getIsAvailable().then((value) async {
        log('$value');
        if (value) {
          await iApEngine.queryProducts(storeProductId).then((res) {
            log('${res.notFoundIDs}');
            products.clear();
            setState(() {
              products.addAll(res.productDetails);
            });
          });
        }
      });
    } catch (error) {
      log('$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          'Reward pint : $rewards',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BuyCoins(),
                      ));
                },
                child: const Text('Go to subscription screen')),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => const SizedBox(
                height: 10,
              ),
              padding: const EdgeInsets.all(20),
              shrinkWrap: true,
              itemCount: products.length,
              itemBuilder: (context, index) {
                final data = products[index];
                log('${products.length}');
                return InkWell(
                  onTap: () {
                    iApEngine.handlePurchase(products[index], storeProductId);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.deepPurple)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Text(data.price),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(data.title),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(data.description),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> listenPurchase(List<PurchaseDetails> list) async {
    for (final purchase in list) {
      if (purchase.status == PurchaseStatus.restored ||
          purchase.status == PurchaseStatus.purchased) {
        if (Platform.isAndroid &&
            iApEngine
                .getProductIdsOnly(storeProductId)
                .contains(purchase.productID)) {
          final InAppPurchaseAndroidPlatformAddition androidAddition = iApEngine
              .inAppPurchase
              .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
          log('message  : ${androidAddition.userChoiceDetailsStream}');
        }
        if (purchase.pendingCompletePurchase) {
          await iApEngine.inAppPurchase.completePurchase(purchase);
        }
        // deliver the products
        giveUserCoins(purchase);
        // rewards = OnePref.getInt('coins') ?? 0;
      }
    }
  }

  void giveUserCoins(PurchaseDetails purchaseDetails) {
    rewards = OnePref.getInt('coins') ?? 0;

    for (var product in storeProductId) {
      if (product.id == purchaseDetails.productID) {
        setState(() {
          rewards = rewards + product.reward!;
          OnePref.setInt('coins', rewards);
        });
      }
    }
  }
}
