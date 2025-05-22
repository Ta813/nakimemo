import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class Monthly {
  final InAppPurchase _iap = InAppPurchase.instance;
  final String _monthlyId = 'monthly_subscription_id'; // Google/AppleのIDに合わせる

  // 無料トライアルの回数をカウントする
  // 課金しているかどうかを確認する
  Future<bool> canUseFeature() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt('usage_count') ?? 0;
    final subscribed = prefs.getBool('subscribed') ?? false;

    if (subscribed) {
      return true; // 課金済みなら常に true
    }

    if (count < 5) {
      prefs.setInt('usage_count', count + 1); // カウントアップ
      return true;
    }

    return false; // 無料上限に達し、未課金なら false
  }

  // 課金の初期化
  // 定期課金の初期化
  Future<void> initIAP() async {
    final isAvailable = await _iap.isAvailable();
    if (!isAvailable) return;

    final response = await _iap.queryProductDetails({_monthlyId});
    if (response.notFoundIDs.isNotEmpty) {
      // エラー処理
      return;
    }

    final product = response.productDetails.first;

    final purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam); // 定期課金用
  }

  // 購入の確認
  void listenToPurchaseUpdates() {
    final purchaseUpdated = _iap.purchaseStream;
    purchaseUpdated.listen((purchases) async {
      for (var purchase in purchases) {
        if (purchase.productID == _monthlyId &&
            purchase.status == PurchaseStatus.purchased) {
          final prefs = await SharedPreferences.getInstance();
          prefs.setBool('subscribed', true);
        }
      }
    });
  }
}
