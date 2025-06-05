// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get stats_title => '統計';

  @override
  String get adviceButton => 'アドバイス';

  @override
  String get noRecords => '記録がありません';

  @override
  String get input_title => 'ボタンを押してね！';

  @override
  String get save_button => '保存';

  @override
  String get cancel_button => 'キャンセル';

  @override
  String get calendar_title => '泣きカレンダー';

  @override
  String get help_title => '入力画面ヘルプ';

  @override
  String get help_text_1 => '・「ミルク」「おむつ」などのボタンを押すと、その時刻で記録されます。';

  @override
  String get help_text_2 => '・記録は1日単位で自動的に保存されます。';

  @override
  String get help_text_3 => '・リストをスワイプで削除、タップでカテゴリ編集ができます。';

  @override
  String get help_text_4 => '・画面右上のゴミ箱アイコンで当日の全記録を削除できます。';

  @override
  String get delete_today_tooltip => '今日の記録を削除';

  @override
  String get help_tooltip => 'ヘルプ';

  @override
  String get edit_category_title => 'カテゴリを編集';

  @override
  String get edit_category_label => 'カテゴリ';

  @override
  String get stats_help_title => '統計画面の使い方';

  @override
  String get stats_help_content =>
      'この画面では、過去の育児記録をカテゴリ別に月ごとで集計し、グラフで表示します。\n\n📌 表示カテゴリ:\n🍼 ミルク, 💩 おむつ, 🌙 夜泣き, 🐾 その他\n\n📆 上部で年月を切り替えることができます。\n\n💡「アドバイス」ボタンで、AIからの育児ヒントも得られます。';

  @override
  String get close => '閉じる';

  @override
  String get ai_advice_title => 'AIアドバイス';

  @override
  String get error_title => 'エラー';

  @override
  String get advice_fetch_failed => 'アドバイスの取得に失敗しました。ネットワークやAPIキーをご確認ください。';

  @override
  String get settingsTitle => '設定';

  @override
  String get language => '言語';

  @override
  String get theme => 'テーマ';

  @override
  String get layout => 'レイアウト';

  @override
  String get nakimemo => 'ナキメモ';

  @override
  String get input_label => '入力';

  @override
  String get calendar_label => 'カレンダー';

  @override
  String get stats_label => '統計';

  @override
  String get setting_label => '設定';

  @override
  String get font => 'フォント';

  @override
  String get show_guide => '使い方ガイドを表示';

  @override
  String get introTitle1 => 'ようこそ';

  @override
  String get introDesc1 => 'ナキメモへようこそ！このアプリで泣いた時間を簡単に記録できます。';

  @override
  String get introTitle2 => '記録方法';

  @override
  String get introDesc2 => '「泣いた！」ボタンで時刻が自動記録されます。';

  @override
  String get introTitle3 => 'カテゴリ変更';

  @override
  String get introDesc3 =>
      '直感的に選べる6つのカテゴリを用意しています。\n\n泣いた理由がわからない場合は「泣いた！」のままにしておきましょう。';

  @override
  String get introTitle4 => 'カレンダー管理';

  @override
  String get introDesc4 => 'カレンダー画面で記録を振り返ったり、編集したりできます。';

  @override
  String get introTitle5 => '統計画面';

  @override
  String get introDesc5 => '泣いた時間をグラフで振り返ることができます。';

  @override
  String get introTitle6 => 'AIによる分析';

  @override
  String get introDesc6 =>
      '泣いた理由をAIが分析し、あなたに合ったアドバイスを提供します。\n\n※5回毎に広告を見れば使用できます。月額課金(1ドル)で無制限に使用できます。\n\n';

  @override
  String get cry => '泣いた！';

  @override
  String get milk => 'ミルク';

  @override
  String get diaper => 'おむつ';

  @override
  String get sleepy => '眠い';

  @override
  String get hold => '抱っこ';

  @override
  String get uncomfortable => '不快';

  @override
  String get sick => '体調不良';

  @override
  String get select_category => 'カテゴリを選択';

  @override
  String get edit_memo => 'メモを編集';

  @override
  String get enter_memo => 'メモを入力してください';

  @override
  String get log_added => ' を追加しました';

  @override
  String get log_deleted => ' を削除しました';

  @override
  String get log_updated => ' に変更しました';

  @override
  String get saved_memo => 'にメモを保存しました';

  @override
  String get cry_instruction => '子どもが泣いた時に「泣いた！」ボタンを押してください。';

  @override
  String get cry_note => '落ち着いたらカテゴリを選んでください。\n「泣いた！」のままでも大丈夫です。';

  @override
  String get memo => 'メモ';

  @override
  String get calendar_help_title => 'カレンダー画面ヘルプ';

  @override
  String get calendar_help_1 => '・カレンダーの日付をタップすると、その日の記録が表示されます。';

  @override
  String get calendar_help_2 => '・記録の横のアイコンはカテゴリを示しています。';

  @override
  String get calendar_help_3 => '・記録をタップするとカテゴリを編集できます。';

  @override
  String get calendar_help_4 => '・記録をスワイプすると削除できます。';

  @override
  String get calendar_help_5 => '・日付の下に丸いマーカーが表示されている日は、記録が存在する日です。';

  @override
  String get add_record => '記録を追加';

  @override
  String get select_time => '時間を選択:';

  @override
  String get add_button => '追加';

  @override
  String get future_time_error => '未来の時刻は記録できません';

  @override
  String get error => 'エラー';

  @override
  String get ok => 'OK';

  @override
  String year_label(Object year) {
    return '$year年';
  }

  @override
  String month_label(Object month) {
    return '$month月';
  }

  @override
  String day_label(Object day) {
    return '$day日';
  }

  @override
  String week_label(Object week) {
    return '第$week週';
  }

  @override
  String get ai_consultation_title => 'AIに相談する';

  @override
  String get consultation_input_hint => '相談内容を入力してください';

  @override
  String get send_button => '送信';

  @override
  String get advice_fetch_error => 'アドバイスの取得に失敗しました:';

  @override
  String get encouragement_fetch_error => '励ましメッセージの取得に失敗しました';

  @override
  String get ai_response_title => 'AIの回答';

  @override
  String get ai_response_failed => 'AIの回答を取得できませんでした';

  @override
  String get upgrade_to_premium => 'プレミアムにアップグレード';

  @override
  String get free_limit_reached =>
      'AI機能について5回毎に広告を見なくてよくなります。\n月額課金(1ドル)で広告なしで無制限に利用できます。';

  @override
  String get day => '日';

  @override
  String get week => '週';

  @override
  String get month => '月';

  @override
  String get overall => '全体';

  @override
  String get purchase => '購入';

  @override
  String get cryingTrendByTime => '時間帯ごとの泣く傾向';

  @override
  String get itemCount => '件';

  @override
  String get aiFeature => 'AI機能';

  @override
  String get encouragement => '励まし';

  @override
  String get encouragementFromAI => 'AIからの励まし';

  @override
  String get consultation => '相談';

  @override
  String get promptAdviceFromData =>
      '以下の「子どもが泣いた理由データ」に基づいて、親に対する短く実用的なアドバイスを1つ提示してください。「子どもが泣いた理由データ」の「泣いた！」の項目は「原因不明」と同じ意味です。';

  @override
  String get roleNurseryTeacher => 'あなたは親にやさしく的確なアドバイスをする保育士です。';

  @override
  String get promptEncouragement => '育児で疲れている親を励ます短いメッセージを1つ提供してください。';

  @override
  String get roleEncouragingAI => 'あなたは親を励ます優しいAIです。';

  @override
  String get roleHelpfulAssistant => 'あなたは親切で知識豊富なアシスタントです。';

  @override
  String get limitCharacters150 => '150文字以内で答えてください。';

  @override
  String get data => 'データ';

  @override
  String get times => '回';

  @override
  String get theme_pinkLight => '🌸 ピンク（ライト）';

  @override
  String get theme_pinkDark => '🌸 ピンク（ダーク）';

  @override
  String get theme_mintLight => '🌿 ミント（ライト）';

  @override
  String get theme_mintDark => '🌿 ミント（ダーク）';

  @override
  String get theme_lavenderLight => '💜 ラベンダー（ライト）';

  @override
  String get theme_lavenderDark => '💜 ラベンダー（ダーク）';

  @override
  String get theme_white => '⬜ ホワイト（シンプル）';

  @override
  String get theme_black => '⬛ ブラック（ダーク）';

  @override
  String get auth_wrong_password => 'パスワードが間違っています';

  @override
  String get auth_user_not_found => 'ユーザーが見つかりません';

  @override
  String get auth_email_already_exists => 'このメールアドレスはすでに使用されています';

  @override
  String get auth_invalid_password => 'パスワードは6文字以上で入力してください';

  @override
  String get auth_invalid_credential => '認証に失敗しました';

  @override
  String get auth_invalid_email => 'メールアドレスの形式が正しくありません';

  @override
  String get reward => '報酬';

  @override
  String get aiUsesAdded => 'AI機能が5回使えるようになりました！';

  @override
  String get watchAdToUseAI =>
      '広告を見るとAI機能を5回使えます。\n広告を出さないためにはユーザ情報でプレミアムにアップグレードする必要があります。(月額1ドル)';

  @override
  String get watchAd => '広告を見る';

  @override
  String get emailNotVerified => 'メールアドレスが未確認です。確認リンクをチェックしてください。';

  @override
  String get otherException => 'その他の例外:';

  @override
  String get createAccount => '新規アカウント作成';

  @override
  String get email => 'メールアドレス';

  @override
  String get password => 'パスワード';

  @override
  String get enterEmail => 'メールアドレスを入力してください';

  @override
  String get enterPassword => 'パスワードを入力してください';

  @override
  String get passwordMinLength => 'パスワードは6文字以上で入力してください';

  @override
  String get register => '登録';

  @override
  String get resetPassword => 'パスワードをリセット';

  @override
  String get registeredEmail => '登録済みのメールアドレス';

  @override
  String get resetEmailSent => '再設定メールを送信しました';

  @override
  String get login => 'ログイン';

  @override
  String get forgotPassword => 'パスワードをお忘れですか？';

  @override
  String get createNewAccount => 'アカウントを作成する';

  @override
  String get startWithoutLogin => 'ログインせずに始める';

  @override
  String get loginWithGoogle => 'Googleでログイン';

  @override
  String get verifyEmail => 'メール認証を確認してください';

  @override
  String get autoNavigateAfterVerification => 'メールの確認リンクをクリックしたら自動的に次の画面へ行きます。';

  @override
  String get userInfo => 'ユーザ情報';

  @override
  String get guestUser => 'ゲスト（ログインなし）';

  @override
  String get upgradeToPremium => 'プレミアムにアップグレード';

  @override
  String get logout => 'ログアウト';

  @override
  String get premiumUser => 'プレミアムユーザ';
}
