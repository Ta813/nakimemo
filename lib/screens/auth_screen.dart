import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nakimemo/setting/locale_provider.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;
  late Locale _locale;

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ログイン
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        // ユーザーにはメール認証を促す
        setState(() {
          _errorMessage = 'メールアドレスが未確認です。確認リンクをチェックしてください。';
        });
        await user.sendEmailVerification(); // 必要なら再送信
        return;
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = getAuthErrorMessage(e);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      //何もしない
    }
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // キャンセル

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      //何もしない
    }
  }

  // ダイアログで新規アカウント作成
  Future<void> _showSignUpDialog() async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String? errorMessage;
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('新規アカウント作成'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'メールアドレス'),
                    ),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: 'パスワード'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    if (errorMessage != null)
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('キャンセル'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                            errorMessage = null;
                          });

                          try {
                            //アカウント作成
                            await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            );
                            //メールアドレスに確認メールを送信
                            await FirebaseAuth.instance.currentUser
                                ?.sendEmailVerification();

                            //すぐにホーム画面に行かないように一旦ログアウト
                            await FirebaseAuth.instance.signOut();

                            // 画面をメール確認待ち画面に遷移
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const EmailVerificationScreen()),
                            );

                            if (context.mounted) Navigator.of(context).pop();
                          } on FirebaseAuthException catch (e) {
                            setState(() {
                              errorMessage = getAuthErrorMessage(e);
                            });
                          } finally {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('登録'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ダイアログでパスワードリセット
  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController();
    String? errorMessage;
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('パスワードをリセット'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: '登録済みのメールアドレス',
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (errorMessage != null)
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('キャンセル'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                            errorMessage = null;
                          });

                          try {
                            await FirebaseAuth.instance.sendPasswordResetEmail(
                              email: emailController.text.trim(),
                            );
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('再設定メールを送信しました'),
                                ),
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            setState(() {
                              errorMessage = getAuthErrorMessage(e);
                            });
                          } finally {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('送信'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String getAuthErrorMessage(FirebaseAuthException e) {
    final code = e.code;

    const errorMessages = {
      'email-already-in-use': {
        'ja': 'このメールアドレスはすでに使用されています。',
        'en': 'The email address is already in use.',
        'zh': '此电子邮件地址已被使用。',
      },
      'invalid-email': {
        'ja': '無効なメールアドレスです。',
        'en': 'Invalid email address.',
        'zh': '无效的电子邮件地址。',
      },
      'user-not-found': {
        'ja': 'ユーザーが見つかりません。',
        'en': 'User not found.',
        'zh': '找不到用户。',
      },
      'wrong-password': {
        'ja': 'パスワードが間違っています。',
        'en': 'Wrong password.',
        'zh': '密码错误。',
      },
      // 他のエラーコードも必要に応じて追加
    };

    final lang = _locale.languageCode;
    return errorMessages[code]?[lang] ??
        {
          'ja': '不明なエラーが発生しました。',
          'en': 'An unknown error occurred.',
          'zh': '发生未知错误。',
        }[lang]!;
  }

  @override
  Widget build(BuildContext context) {
    //firebaseの言語設定を行う。
    final provider = Provider.of<LocaleProvider>(context);
    _locale = provider.locale!;
    FirebaseAuth.instance.setLanguageCode(_locale.languageCode);

    return Scaffold(
      appBar: AppBar(title: const Text('ログイン')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 500,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(labelText: 'メールアドレス'),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(labelText: 'パスワード'),
                          obscureText: true,
                        ),
                        const SizedBox(height: 16),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        if (_isLoading)
                          CircularProgressIndicator()
                        else
                          ElevatedButton(
                            onPressed: _submit,
                            child: Text('ログイン'),
                          ),
                        TextButton(
                          onPressed: _showForgotPasswordDialog,
                          child: Text('パスワードをお忘れですか？'),
                        ),
                        TextButton(
                          onPressed: _showSignUpDialog,
                          child: Text('アカウントを作成する'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: signInAnonymously,
                    child: const Text('ログインせずに始める'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Image.asset(
                      'lib/assets/google_logo.png',
                      height: 24,
                      width: 24,
                    ),
                    label: const Text('Googleでログイン'),
                    onPressed: signInWithGoogle,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // 定期的に確認
    _timer =
        Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerified());
  }

  //メール確認したかチェック
  Future<void> checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    if (user != null && user.emailVerified) {
      _timer?.cancel();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => AuthGate()));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("メール認証を確認してください")),
      body: const Center(
        child: Text("メールの確認リンクをクリックしたら自動的に次の画面へ行きます。"),
      ),
    );
  }
}
