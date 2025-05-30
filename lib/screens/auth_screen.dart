import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nakimemo/setting/locale_provider.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _formKeyMake = GlobalKey<FormState>();
  final _formKeyForgot = GlobalKey<FormState>();
  String? _errorMessage;
  bool _isLoading = false;
  late Locale _locale;
  bool isDark = false; // ダークモードの状態を管理

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
          _errorMessage = '${AppLocalizations.of(context)!.emailNotVerified}';
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
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // キャンセル

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = '${e.code} - ${e.message}';
      });
    } catch (e) {
      print('${AppLocalizations.of(context)!.otherException} $e');
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
              title: Text(AppLocalizations.of(context)!.createAccount,
                  style:
                      TextStyle(color: isDark ? Colors.white : Colors.black)),
              content: Form(
                key: _formKeyMake, // ← 事前に定義しておいてください
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.email),
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '${AppLocalizations.of(context)!.enterEmail}';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.password),
                        obscureText: true,
                        inputFormatters: [LengthLimitingTextInputFormatter(30)],
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '${AppLocalizations.of(context)!.enterPassword}';
                          } else if (value.length < 6) {
                            return '${AppLocalizations.of(context)!.passwordMinLength}';
                          }
                          return null;
                        },
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
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.cancel_button),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!_formKeyMake.currentState!.validate()) {
                            return; // バリデーション失敗
                          }

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
                                builder: (_) => const EmailVerificationScreen(),
                              ),
                            );
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
                      : Text(AppLocalizations.of(context)!.register),
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
              title: Text(AppLocalizations.of(context)!.resetPassword,
                  style:
                      TextStyle(color: isDark ? Colors.white : Colors.black)),
              content: Form(
                key: _formKeyForgot, // ← Stateクラス内で定義しておく必要があります
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context)!.registeredEmail,
                      ),
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '${AppLocalizations.of(context)!.enterEmail}';
                        }
                        return null;
                      },
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
                  child: Text(AppLocalizations.of(context)!.cancel_button),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!_formKeyForgot.currentState!.validate()) {
                            return;
                          }

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
                                SnackBar(
                                  content: Text(AppLocalizations.of(context)!
                                      .resetEmailSent),
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
                      : Text(AppLocalizations.of(context)!.send_button),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String getAuthErrorMessage(FirebaseAuthException e) {
    final l10n = AppLocalizations.of(context)!;
    String errorMessage;

    switch (e.code) {
      case 'wrong-password':
        errorMessage = l10n.auth_wrong_password;
        break;
      case 'user-not-found':
        errorMessage = l10n.auth_user_not_found;
        break;
      case 'email-already-in-use':
        errorMessage = l10n.auth_email_already_exists;
        break;
      case 'weak-password':
        errorMessage = l10n.auth_invalid_password;
        break;
      case 'invalid-credential':
        errorMessage = l10n.auth_invalid_credential;
        break;
      case 'invalid-email':
        errorMessage = l10n.auth_invalid_email;
        break;
      default:
        errorMessage = "${e.code} - ${e.message}";
    }
    return errorMessage;
  }

  @override
  Widget build(BuildContext context) {
    isDark = Theme.of(context).brightness == Brightness.dark;
    //firebaseの言語設定を行う。
    final provider = Provider.of<LocaleProvider>(context);
    _locale = provider.locale!;
    FirebaseAuth.instance.setLanguageCode(_locale.languageCode);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.login)),
      body: Form(
        key: _formKey,
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
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.email),
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '${AppLocalizations.of(context)!.enterEmail}';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.of(context)!.password),
                          obscureText: true,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(30)
                          ],
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '${AppLocalizations.of(context)!.enterPassword}';
                            } else if (value.length < 6) {
                              return '${AppLocalizations.of(context)!.passwordMinLength}';
                            }
                            return null;
                          },
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
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // バリデーションOK: ログイン処理をここで実行
                                _submit();
                              }
                            },
                            child: Text(AppLocalizations.of(context)!.login),
                          ),
                        TextButton(
                          onPressed: _showForgotPasswordDialog,
                          child: Text(
                              AppLocalizations.of(context)!.forgotPassword),
                        ),
                        TextButton(
                          onPressed: _showSignUpDialog,
                          child: Text(
                              AppLocalizations.of(context)!.createNewAccount),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: signInAnonymously,
                    child:
                        Text(AppLocalizations.of(context)!.startWithoutLogin),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Image.asset(
                      'lib/assets/google_logo.png',
                      height: 24,
                      width: 24,
                    ),
                    label: Text(AppLocalizations.of(context)!.loginWithGoogle),
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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.verifyEmail)),
      body: Center(
        child:
            Text(AppLocalizations.of(context)!.autoNavigateAfterVerification),
      ),
    );
  }
}
