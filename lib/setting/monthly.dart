import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class Monthly {
  final InAppPurchase _iap = InAppPurchase.instance;
  final String _monthlyId = 'nakimemo_monthly'; // Google/AppleのIDに合わせる

  Future<bool> isPremium() async {
    // 課金状態を確認するロジックを実装
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('subscribed') ?? false; // 課金状態を保存している場合
  }

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
  Future<bool> initIAP() async {
    final isAvailable = await _iap.isAvailable();
    if (!isAvailable) return false;

    final response = await _iap.queryProductDetails({_monthlyId});
    if (response.notFoundIDs.isNotEmpty) {
      // エラー処理
      return false;
    }

    final product = response.productDetails.first;

    final purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam); // 定期課金用
    return true;
  }

  // 購入の確認
  void listenToPurchaseUpdates() {
    final purchaseUpdated = _iap.purchaseStream;
    purchaseUpdated.listen((purchases) async {
      final prefs = await SharedPreferences.getInstance();
      for (var purchase in purchases) {
        if (purchase.productID == _monthlyId) {
          if (purchase.status == PurchaseStatus.purchased) {
            prefs.setBool('subscribed', true); // 購入成功時
          } else if (purchase.status == PurchaseStatus.canceled ||
              purchase.status == PurchaseStatus.error) {
            prefs.setBool('subscribed', false); // 購入キャンセル時
          }
        }
      }
    });
  }
}
