import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:in_app_purchase/in_app_purchase.dart';
// ignore: depend_on_referenced_packages
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:onepref/onepref.dart';
import 'package:revenue_cat_in_app_purchase/main.dart';
import 'package:revenue_cat_in_app_purchase/test%20data/utils/constants.dart';

import '../../components/snackbar.dart';

class Subscriptions extends StatefulWidget {
  const Subscriptions({super.key});

  @override
  State<Subscriptions> createState() => _SubscriptionsState();
}

class _SubscriptionsState extends State<Subscriptions> {
  late final List<ProductDetails> _products = <ProductDetails>[];
  IApEngine iApEngine = IApEngine();
  bool isSubscribed = false;
  bool isRestore = false;

  final List<ProductId> _productsIds = [
    ProductId(id: "non_auto_renewable1", isConsumable: false),
    ProductId(id: "normal_subscription", isConsumable: false),
    ProductId(id: "rc_premium_month", isConsumable: false),
    ProductId(id: "rc_premium_year", isConsumable: false),
    ProductId(id: "rc_test_99", isConsumable: false),
    ProductId(id: "rc_test_trail", isConsumable: false),
    ProductId(id: "weekly", isConsumable: false),
  ];
  void getExistingSubscriptionPackages(List<PurchaseDetails> purchases) {
    final existingPackages = purchases
        .where((purchase) =>
            purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored)
        .map((purchase) => purchase.productID)
        .toList();

    log('Existing subscription packages: $existingPackages');
  }

  final bool _isLoaded = false;

  bool subExisting = false;

  late PurchaseDetails oldPurchaseDetails;

  @override
  void initState() {
    super.initState();

    isSubscribed = OnePref.getPremium()!;

    iApEngine.inAppPurchase.purchaseStream.listen((purchaseDetailsList) {
      //listen to the purchase

      if (purchaseDetailsList.isNotEmpty) {
        setState(() {
          subExisting = true;
          oldPurchaseDetails = purchaseDetailsList[0];
        });
      }

      listenPurchasedActivities(purchaseDetailsList);
      getExistingSubscriptionPackages(purchaseDetailsList);

      if (purchaseDetailsList.isEmpty && isRestore) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          openSnackBar(
            context: context,
            btnName: "OK",
            title: "Restore",
            message: "Oops! You do not have a subscription to restore",
            color: Colors.accents,
            bgColor: Constants.txtColor,
          );
        });
      } else if (purchaseDetailsList.isNotEmpty && isRestore) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          openSnackBar(
            context: context,
            btnName: "OK",
            title: "Restore",
            message:
                "Congrats! You got a purchase to restore, it will be restored in a sec.",
            color: Colors.accents,
            bgColor: Colors.green,
          );
        });
      }
    }, onDone: () {
      print("onDone");
    }, onError: (Object error) {
      print("onError");
    });

    //get products
    getProducts();
  }

  void getProducts() async {
    await iApEngine.getIsAvailable().then((value) async => {
          if (value)
            {
              await iApEngine.queryProducts(_productsIds).then((value) {
                setState(() {
                  _products.addAll(value.productDetails);
                });
                if (value.notFoundIDs.isNotEmpty) {}
              })
            }
        });
  }

  Future<void> listenPurchasedActivities(List<PurchaseDetails> list) async {
    if (list.isNotEmpty) {
      getExistingSubscriptionPackages(list);
      for (var purchaseDetails in list) {
        if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          //This is for the android
          if (Platform.isAndroid &&
              iApEngine
                  .getProductIdsOnly(_productsIds)
                  .contains(purchaseDetails.productID) &&
              _productsIds
                      .where(
                          (element) => element.id == purchaseDetails.productID)
                      .first
                      .isConsumable ==
                  true) {
            final InAppPurchaseAndroidPlatformAddition androidPlatformAddition =
                iApEngine.inAppPurchase.getPlatformAddition<
                    InAppPurchaseAndroidPlatformAddition>();

            await androidPlatformAddition.consumePurchase(purchaseDetails).then(
                  (value) => setState(() {
                    OnePref.setPremium(true);
                    isSubscribed = OnePref.getPremium() ?? false;
                    print('Subscription success details:');
                    print({
                      'source': purchaseDetails.verificationData.source,
                      'productId': purchaseDetails.productID,
                      'verificationData': purchaseDetails
                          .verificationData.serverVerificationData
                    });
                  }),
                );
          }

          //handles pending purchases
          if (purchaseDetails.pendingCompletePurchase) {
            await iApEngine.inAppPurchase
                .completePurchase(purchaseDetails)
                .then(
                  (value) => setState(() {
                    OnePref.setPremium(true);
                    isSubscribed = OnePref.getPremium() ?? false;
                    log('Subscription success details:');
                    log('ProductId: ${purchaseDetails.productID}');
                    log('Source: ${purchaseDetails.verificationData.source}');
                    log('verification Data: ${purchaseDetails.verificationData.serverVerificationData}');
                  }),
                );
          }
        }
      }
    } else {
      setState(() {
        OnePref.setPremium(false);
        isSubscribed = OnePref.getPremium() ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                image: AssetImage('assets/images/coins_bg.jpeg'),
                fit: BoxFit.cover,
                opacity: 0.7,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OnClickAnimation(
                          onTap: () => {
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const MyHomePage()),
                                    (Route<dynamic> route) => false)
                              },
                          child: const Text(
                            "Dismiss",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                      OnClickAnimation(
                        onTap: () async => {
                          await InAppPurchase.instance.restorePurchases().then(
                            (value) {
                              isRestore = true;
                              _products.clear();
                              getProducts();
                            },
                          ),
                        },
                        child: const Text(
                          "Restore",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50.0, vertical: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Text(
                              "${Constants.appName} Go ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color:
                                    isSubscribed ? Colors.green : Colors.orange,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "PRO",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    itemCount: Constants.benefits.length,
                    itemBuilder: (context, index) => Benefit(
                      title: Constants.benefits[index],
                      icon: Icons.check,
                      iconBackgroundColor: Colors.orange,
                      iconColor: Colors.white,
                      titleStyle: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Visibility(
                  visible: !_products.isNotEmpty,
                  child: const SizedBox(
                    height: 90,
                    width: 90,
                    child: CircularProgressIndicator(),
                  ),
                ),
                Expanded(
                  child: Visibility(
                    visible: _products.isNotEmpty,
                    child: ListView.builder(
                      itemBuilder: ((context, index) => Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 25.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.orange,
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0,
                                          ),
                                          child: ListTile(
                                            title: Text(
                                              _products[index].price,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            subtitle: Text(
                                              _products[index].title,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            trailing: OnClickAnimation(
                                              onTap: () async {
                                                log('message :${_products[index].runtimeType}');
                                                setState(() {
                                                  isRestore = false;
                                                });

                                                await iApEngine.inAppPurchase
                                                    .restorePurchases()
                                                    .whenComplete(() async {
                                                  await Future.delayed(
                                                          const Duration(
                                                              seconds: 1))
                                                      .then((value) async {
                                                    if (subExisting &&
                                                        oldPurchaseDetails
                                                                .productID !=
                                                            _products[index]
                                                                .id) {
                                                      await iApEngine
                                                          .upgradeOrDowngradeSubscription(
                                                              oldPurchaseDetails,
                                                              _products[index])
                                                          .then((value) {
                                                        setState(() {
                                                          subExisting = false;
                                                        });
                                                      });
                                                    } else {
                                                      iApEngine.handlePurchase(
                                                          _products[index],
                                                          _productsIds);
                                                    }
                                                  });
                                                });
                                              },
                                              child: const Text(
                                                "Subscribe",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ))),
                                ),
                              ],
                            ),
                          )),
                      itemCount: _products.length,
                    ),
                  ),
                ),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 25.0, horizontal: 25.0),
                  child: Text(
                    "The above ad will be removed if the user has subscribed to one of our subscrptions\n---------\nSubscritions automatically renews monthly until canceled.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
}
