import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../main.dart';

class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('ユーザ情報'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('メールアドレス: ${user?.email ?? "ゲスト（ログインなし）"}'),
            SizedBox(height: 10),
            ElevatedButton(
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
              child: Text('ログアウト'),
            )
          ],
        ),
      ),
    );
  }
}
