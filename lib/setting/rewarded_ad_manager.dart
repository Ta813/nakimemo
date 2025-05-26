import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdManager {
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;

  void loadAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917', // テスト用ID
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isAdLoaded = true;
          print('Rewarded ad loaded.');
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Failed to load rewarded ad: $error');
          _isAdLoaded = false;
        },
      ),
    );
  }

  void showAd(Function onRewardEarned) {
    if (_isAdLoaded && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadAd(); // 再読み込み
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
        },
      );

      _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        print('User earned reward: ${reward.amount} ${reward.type}');
        onRewardEarned(); // ユーザーに報酬を与える処理
      });

      _rewardedAd = null;
      _isAdLoaded = false;
    } else {
      print("Ad not loaded yet.");
    }
  }
}
