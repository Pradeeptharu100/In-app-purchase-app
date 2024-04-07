import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:onepref/onepref.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  //List products
  late final List<ProductDetails> _products = [];
  bool isSubscribed = false;
  bool isRestore = false;

  //List of productId
  final List<ProductId> _productIds = [
    ProductId(id: 'weekly', isConsumable: false),
    ProductId(id: 'rc_premium_month', isConsumable: false),
    ProductId(id: 'rc_premium_year', isConsumable: false),
    ProductId(id: 'non_auto_renewable1', isConsumable: false),
    ProductId(id: 'normal_subscription', isConsumable: false),
  ];
  bool subExisting = false;
  late PurchaseDetails oldPurchaseDetail;

  //IApEngine
  final IApEngine iApEngine = IApEngine();

  //bool
  @override
  void initState() {
    super.initState();
    getProducts();
    isSubscribed = OnePref.getPremium()!;

    // iApEngine.inAppPurchase.purchaseStream.listen((listenOfPurchaseDetails) {
    // listenPurchases(listenOfPurchaseDetails);
    // });

    iApEngine.inAppPurchase.purchaseStream.listen((purchaseDetailList) {
      listenPurchases(purchaseDetailList);
      log('message : $purchaseDetailList');

      if (purchaseDetailList.isNotEmpty) {
        setState(() {
          subExisting = true;
          oldPurchaseDetail = purchaseDetailList[0];
        });
      }

      if (purchaseDetailList.isEmpty && isRestore) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          openSnackBar(
            context: context,
            btnName: 'OK',
            title: 'Restore',
            message: 'Oops!,You do not have a subscription to restore',
            color: Colors.yellow,
            bgColor: Colors.white,
          );
        });
      } else if (purchaseDetailList.isNotEmpty && isRestore) {
        openSnackBar(
          context: context,
          btnName: 'OK',
          title: 'Restore',
          message:
              'Congrats!,You got a purchase restore, it will be restored in a sec',
          color: Colors.yellow,
          bgColor: Colors.white,
        );
      }
    }, onDone: () {
      log('Done');
    }, onError: (error) {
      log('Error  :$error');
    });
  }

  restoreSub() {
    iApEngine.inAppPurchase.restorePurchases();
  }

  Future<void> listenPurchases(List<PurchaseDetails> list) async {
    if (list.isNotEmpty) {
      for (var purchaseDetails in list) {
        if (purchaseDetails.status == PurchaseStatus.restored ||
            purchaseDetails.status == PurchaseStatus.purchased) {
          //acknowledged false/true
          Map purchaseData = json
              .decode(purchaseDetails.verificationData.localVerificationData);
          log('purchase data : $purchaseData');
          if (purchaseData['acknowledged']) {
            log('restore purchased');
            updateIsSub(true);
          } else {
            log('First time purchased');
            if (Platform.isAndroid) {
              final InAppPurchaseAndroidPlatformAddition
                  androidPlatformAddition = iApEngine.inAppPurchase
                      .getPlatformAddition<
                          InAppPurchaseAndroidPlatformAddition>();
              await androidPlatformAddition
                  .consumePurchase(purchaseDetails)
                  .then((value) {
                updateIsSub(true);
              });
            }
            // complete purchase
            if (purchaseDetails.pendingCompletePurchase) {
              await iApEngine.inAppPurchase
                  .completePurchase(purchaseDetails)
                  .then((value) {
                updateIsSub(true);
              });
            }
          }
        }
      }
    } else {
      updateIsSub(false);
    }
  }

  updateIsSub(bool val) {
    setState(() {
      isSubscribed = val;
      OnePref.setPremium(isSubscribed);
    });
  }

  getProducts() async {
    try {
      await iApEngine.getIsAvailable().then((value) async {
        log('$value');
        if (value) {
          await iApEngine.queryProducts(_productIds).then((res) {
            log('${res.notFoundIDs}');
            _products.clear();
            setState(() {
              _products.addAll(res.productDetails);
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
        title: const Text(
          'Subscription',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text('IsSubscribed : $isSubscribed'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.deepOrange)),
                child: InkWell(
                    onTap: () {
                      iApEngine.inAppPurchase.restorePurchases();
                    },
                    child: const Text('Restore Subscription')),
              ),
              const SizedBox(height: 10),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => const SizedBox(
                  height: 20,
                ),
                itemCount: _products.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final data = _products[index];
                  return InkWell(
                    onTap: () async {
                      setState(() {
                        isRestore = false;
                      });
                      await iApEngine.inAppPurchase
                          .restorePurchases()
                          .whenComplete(() async =>
                              await Future.delayed(const Duration(seconds: 1))
                                  .then((value) async => {
                                        if (subExisting &&
                                            oldPurchaseDetail.productID !=
                                                _products[index].id)
                                          {
                                            await iApEngine
                                                .upgradeOrDowngradeSubscription(
                                                    oldPurchaseDetail,
                                                    _products[index])
                                                .then((value) => {
                                                      setState(() {
                                                        isRestore = false;
                                                      })
                                                    }),
                                          }
                                        else
                                          {
                                            iApEngine.handlePurchase(
                                                _products[index], _productIds),
                                          }
                                      }));
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.deepPurple)),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_products[index].price),
                              const SizedBox(height: 10),
                              Text(data.title),
                              const SizedBox(height: 10),
                              Text(data.description)
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
      ),
    );
  }

  void openSnackBar({
    required BuildContext context,
    required String btnName,
    required String title,
    required String message,
    required Color color,
    required Color bgColor,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              color: color,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: color,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                btnName,
                style: TextStyle(
                  color: color,
                ),
              ),
            ),
          ],
          backgroundColor: bgColor,
        );
      },
    );
  }
}
