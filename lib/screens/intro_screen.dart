import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:nakimemo/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  List<Slide> slides = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    slides.add(
      Slide(
        title: AppLocalizations.of(context)!.introTitle1,
        description: AppLocalizations.of(context)!.introDesc1,
        pathImage: "lib/assets/intro1.png", // 任意の画像
        backgroundColor: Colors.blueAccent,
      ),
    );
    slides.add(
      Slide(
        title: AppLocalizations.of(context)!.introTitle2,
        description: AppLocalizations.of(context)!.introDesc2,
        pathImage: "lib/assets/intro2.png",
        backgroundColor: Colors.teal,
      ),
    );
    slides.add(
      Slide(
        title: AppLocalizations.of(context)!.introTitle3,
        description: AppLocalizations.of(context)!.introDesc3,
        pathImage: "lib/assets/intro3.png",
        backgroundColor: Colors.green,
      ),
    );
    slides.add(
      Slide(
        title: AppLocalizations.of(context)!.introTitle4,
        description: AppLocalizations.of(context)!.introDesc4,
        pathImage: "lib/assets/intro4.png",
        backgroundColor: Colors.deepPurple,
      ),
    );
    slides.add(
      Slide(
        title: AppLocalizations.of(context)!.introTitle5,
        description: AppLocalizations.of(context)!.introDesc5,
        pathImage: "lib/assets/intro5.png",
        backgroundColor: Colors.purple,
      ),
    );
    slides.add(Slide(
      title: AppLocalizations.of(context)!.introTitle6,
      description: AppLocalizations.of(context)!.introDesc6,
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
