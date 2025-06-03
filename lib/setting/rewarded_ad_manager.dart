import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class RewardedAdManager {
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;

  void loadAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-2333753292729105/1246208416', // テスト用ID
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isAdLoaded = true;
          print('Rewarded ad loaded.');
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Failed to load rewarded ad: $error');
          _rewardedAd = null;
          _isAdLoaded = false;
        },
      ),
    );
  }

  void showAd(BuildContext context, Function onRewardEarned,
      {int retryCount = 0}) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('広告を読み込み中です...')),
      );

      // ロードを試みる
      loadAd();

      // リトライ回数が5未満なら1秒後に再試行
      if (retryCount < 5) {
        Future.delayed(const Duration(seconds: 3), () {
          showAd(context, onRewardEarned, retryCount: retryCount + 1);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('広告の読み込みに失敗しました。')),
        );
      }
    }
  }
}
