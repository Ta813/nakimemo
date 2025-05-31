import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../main.dart';
import '../setting/monthly.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool isDark = false; // ダークモードの状態を管理
  Monthly monthly = Monthly();

  Future<void> _showSubscribedDialog(Monthly monthly) async {
    // ダイアログで課金を促す
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.upgrade_to_premium,
            style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Text(AppLocalizations.of(context)!.free_limit_reached,
            style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.cancel_button),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(AppLocalizations.of(context)!.purchase),
            onPressed: () {
              Navigator.pop(context);
              monthly.initIAP(); // 課金処理を開始
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.userInfo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${AppLocalizations.of(context)!.email}: ${user?.email ?? AppLocalizations.of(context)!.guestUser}',
                style: TextStyle(color: isDark ? Colors.white : Colors.black)),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () => _showSubscribedDialog(monthly),
                child: Text(AppLocalizations.of(context)!.upgradeToPremium),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  //サインアウト処理
                  await FirebaseAuth.instance.signOut();
                  await GoogleSignIn().signOut();

                  await
                      // ログイン画面に遷移
                      Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AuthGate()),
                  );
                },
                child: Text(AppLocalizations.of(context)!.logout),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
