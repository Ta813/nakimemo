import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:nakimemo/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  List<Slide> slides = [];

  @override
  void initState() {
    super.initState();

    slides.add(
      Slide(
        title: "ようこそ",
        description: "ナキメモへようこそ！このアプリで泣いた時間を簡単に記録できます。",
        pathImage: "lib/assets/intro1.png", // 任意の画像
        backgroundColor: Colors.blueAccent,
      ),
    );
    slides.add(
      Slide(
        title: "記録方法",
        description: "「泣いた！」ボタンで時刻が自動記録されます。",
        pathImage: "lib/assets/intro2.png",
        backgroundColor: Colors.teal,
      ),
    );
    slides.add(
      Slide(
        title: "カテゴリ変更",
        description: "直感的に選べる6つのカテゴリを用意しています。\n\n"
            "泣いた理由がわからない場合は「泣いた！」のままにしておきましょう。",
        pathImage: "lib/assets/intro3.png",
        backgroundColor: Colors.green,
      ),
    );
    slides.add(
      Slide(
        title: "カレンダー管理",
        description: "カレンダー画面で記録を振り返ったり、編集したりできます。",
        pathImage: "lib/assets/intro4.png",
        backgroundColor: Colors.deepPurple,
      ),
    );
    slides.add(
      Slide(
        title: "統計画面",
        description: "泣いた時間をグラフで振り返ることができます。",
        pathImage: "lib/assets/intro5.png",
        backgroundColor: Colors.purple,
      ),
    );
    slides.add(Slide(
      title: "AIによる分析",
      description: "泣いた理由をAIが分析し、あなたに合ったアドバイスを提供します。\n\n"
          "※(月額課金)3回だけ無料で体験できます。\n\n",
      pathImage: "lib/assets/intro6.png",
      backgroundColor: Colors.deepPurpleAccent,
    ));
  }

  void onDonePress() async {
    // 初回起動済みフラグを保存
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_launch', false);

    // ホームへ遷移
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntroSlider(
      slides: this.slides,
      onDonePress: this.onDonePress,
      onSkipPress: this.onDonePress,
      showSkipBtn: true,
    );
  }
}
