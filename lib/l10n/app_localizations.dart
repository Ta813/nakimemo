import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('zh')
  ];

  /// No description provided for @stats_title.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats_title;

  /// No description provided for @adviceButton.
  ///
  /// In en, this message translates to:
  /// **'Advice'**
  String get adviceButton;

  /// No description provided for @noRecords.
  ///
  /// In en, this message translates to:
  /// **'No records found'**
  String get noRecords;

  /// No description provided for @input_title.
  ///
  /// In en, this message translates to:
  /// **'Log Cry Event'**
  String get input_title;

  /// No description provided for @save_button.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save_button;

  /// No description provided for @cancel_button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel_button;

  /// No description provided for @calendar_title.
  ///
  /// In en, this message translates to:
  /// **'Cry Calendar'**
  String get calendar_title;

  /// No description provided for @help_title.
  ///
  /// In en, this message translates to:
  /// **'Input Help'**
  String get help_title;

  /// No description provided for @help_text_1.
  ///
  /// In en, this message translates to:
  /// **'・Tap a button like \'Milk\' or \'Diaper\' to record the time.'**
  String get help_text_1;

  /// No description provided for @help_text_2.
  ///
  /// In en, this message translates to:
  /// **'・Records are automatically saved per day.'**
  String get help_text_2;

  /// No description provided for @help_text_3.
  ///
  /// In en, this message translates to:
  /// **'・Swipe to delete a log, or tap to edit category.'**
  String get help_text_3;

  /// No description provided for @help_text_4.
  ///
  /// In en, this message translates to:
  /// **'・Use the trash icon to clear today\'s records.'**
  String get help_text_4;

  /// No description provided for @delete_today_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete today\'s records'**
  String get delete_today_tooltip;

  /// No description provided for @help_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help_tooltip;

  /// No description provided for @edit_category_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get edit_category_title;

  /// No description provided for @edit_category_label.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get edit_category_label;

  /// No description provided for @stats_help_title.
  ///
  /// In en, this message translates to:
  /// **'How to Use the Statistics Screen'**
  String get stats_help_title;

  /// No description provided for @stats_help_content.
  ///
  /// In en, this message translates to:
  /// **'This screen summarizes past childcare records by category for each month and displays them in a graph.\n\n📌 Categories shown:\n🍼 Milk, 💩 Diaper, 🌙 Night Crying, 🐾 Other\n\n📆 You can change the year and month at the top.\n\n💡 Tap the \"Get AI Advice\" button to receive parenting tips from AI.'**
  String get stats_help_content;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ai_advice_title.
  ///
  /// In en, this message translates to:
  /// **'AI Advice'**
  String get ai_advice_title;

  /// No description provided for @error_title.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error_title;

  /// No description provided for @advice_fetch_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch advice. Please check your network or API key.'**
  String get advice_fetch_failed;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @layout.
  ///
  /// In en, this message translates to:
  /// **'Layout'**
  String get layout;

  /// No description provided for @nakimemo.
  ///
  /// In en, this message translates to:
  /// **'ナキメモ'**
  String get nakimemo;

  /// No description provided for @input_label.
  ///
  /// In en, this message translates to:
  /// **'Input'**
  String get input_label;

  /// No description provided for @calendar_label.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar_label;

  /// No description provided for @stats_label.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats_label;

  /// No description provided for @setting_label.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get setting_label;

  /// No description provided for @font.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get font;

  /// No description provided for @show_guide.
  ///
  /// In en, this message translates to:
  /// **'Show Guide'**
  String get show_guide;

  /// No description provided for @introTitle1.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get introTitle1;

  /// No description provided for @introDesc1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Nakimemo! This app lets you easily log your crying time.'**
  String get introDesc1;

  /// No description provided for @introTitle2.
  ///
  /// In en, this message translates to:
  /// **'How to record'**
  String get introTitle2;

  /// No description provided for @introDesc2.
  ///
  /// In en, this message translates to:
  /// **'Just tap the \"I Cried!\" button to automatically log the time.'**
  String get introDesc2;

  /// No description provided for @introTitle3.
  ///
  /// In en, this message translates to:
  /// **'Change category'**
  String get introTitle3;

  /// No description provided for @introDesc3.
  ///
  /// In en, this message translates to:
  /// **'You can choose from 6 intuitive categories.\n\nIf you\'re unsure why you cried, just leave it as \"I Cried!\".'**
  String get introDesc3;

  /// No description provided for @introTitle4.
  ///
  /// In en, this message translates to:
  /// **'Calendar view'**
  String get introTitle4;

  /// No description provided for @introDesc4.
  ///
  /// In en, this message translates to:
  /// **'Check and edit your records in the calendar view.'**
  String get introDesc4;

  /// No description provided for @introTitle5.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get introTitle5;

  /// No description provided for @introDesc5.
  ///
  /// In en, this message translates to:
  /// **'Review your crying time with graphs and charts.'**
  String get introDesc5;

  /// No description provided for @introTitle6.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis'**
  String get introTitle6;

  /// No description provided for @introDesc6.
  ///
  /// In en, this message translates to:
  /// **'The AI analyzes why you cried and offers personalized advice.\n\n*You can use it by watching an ad every 5 times. Unlimited use is available with a monthly subscription (\$1).\n\n'**
  String get introDesc6;

  /// No description provided for @cry.
  ///
  /// In en, this message translates to:
  /// **'Cried!'**
  String get cry;

  /// No description provided for @milk.
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get milk;

  /// No description provided for @diaper.
  ///
  /// In en, this message translates to:
  /// **'Diaper'**
  String get diaper;

  /// No description provided for @sleepy.
  ///
  /// In en, this message translates to:
  /// **'Sleepy'**
  String get sleepy;

  /// No description provided for @hold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get hold;

  /// No description provided for @uncomfortable.
  ///
  /// In en, this message translates to:
  /// **'Upset'**
  String get uncomfortable;

  /// No description provided for @sick.
  ///
  /// In en, this message translates to:
  /// **'Sick'**
  String get sick;

  /// No description provided for @select_category.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get select_category;

  /// No description provided for @edit_memo.
  ///
  /// In en, this message translates to:
  /// **'Edit Memo'**
  String get edit_memo;

  /// No description provided for @enter_memo.
  ///
  /// In en, this message translates to:
  /// **'Enter memo'**
  String get enter_memo;

  /// No description provided for @log_added.
  ///
  /// In en, this message translates to:
  /// **' was added'**
  String get log_added;

  /// No description provided for @log_deleted.
  ///
  /// In en, this message translates to:
  /// **' was deleted'**
  String get log_deleted;

  /// No description provided for @log_updated.
  ///
  /// In en, this message translates to:
  /// **' was updated'**
  String get log_updated;

  /// No description provided for @saved_memo.
  ///
  /// In en, this message translates to:
  /// **'Memo saved to'**
  String get saved_memo;

  /// No description provided for @cry_instruction.
  ///
  /// In en, this message translates to:
  /// **'Press the \"Cried!\" button when your child starts crying.'**
  String get cry_instruction;

  /// No description provided for @cry_note.
  ///
  /// In en, this message translates to:
  /// **'Once things calm down, please select a category.\nIt\'s okay to leave it as \"Cried!\".'**
  String get cry_note;

  /// No description provided for @memo.
  ///
  /// In en, this message translates to:
  /// **'Memo'**
  String get memo;

  /// No description provided for @calendar_help_title.
  ///
  /// In en, this message translates to:
  /// **'Calendar Screen Help'**
  String get calendar_help_title;

  /// No description provided for @calendar_help_1.
  ///
  /// In en, this message translates to:
  /// **'・Tap a date on the calendar to view the records for that day.'**
  String get calendar_help_1;

  /// No description provided for @calendar_help_2.
  ///
  /// In en, this message translates to:
  /// **'・The icon next to each record indicates its category.'**
  String get calendar_help_2;

  /// No description provided for @calendar_help_3.
  ///
  /// In en, this message translates to:
  /// **'・Tap a record to edit its category.'**
  String get calendar_help_3;

  /// No description provided for @calendar_help_4.
  ///
  /// In en, this message translates to:
  /// **'・Swipe a record to delete it.'**
  String get calendar_help_4;

  /// No description provided for @calendar_help_5.
  ///
  /// In en, this message translates to:
  /// **'・A circular marker under the date means there are records on that day.'**
  String get calendar_help_5;

  /// No description provided for @add_record.
  ///
  /// In en, this message translates to:
  /// **'Add Record'**
  String get add_record;

  /// No description provided for @select_time.
  ///
  /// In en, this message translates to:
  /// **'Select Time:'**
  String get select_time;

  /// No description provided for @add_button.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add_button;

  /// No description provided for @future_time_error.
  ///
  /// In en, this message translates to:
  /// **'Cannot record a future time'**
  String get future_time_error;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @year_label.
  ///
  /// In en, this message translates to:
  /// **'{year}'**
  String year_label(Object year);

  /// No description provided for @month_label.
  ///
  /// In en, this message translates to:
  /// **'{month}'**
  String month_label(Object month);

  /// No description provided for @day_label.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String day_label(Object day);

  /// No description provided for @week_label.
  ///
  /// In en, this message translates to:
  /// **'Week {week}'**
  String week_label(Object week);

  /// No description provided for @ai_consultation_title.
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get ai_consultation_title;

  /// No description provided for @consultation_input_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your concern'**
  String get consultation_input_hint;

  /// No description provided for @send_button.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send_button;

  /// No description provided for @advice_fetch_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch advice:'**
  String get advice_fetch_error;

  /// No description provided for @encouragement_fetch_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch inspire message'**
  String get encouragement_fetch_error;

  /// No description provided for @ai_response_title.
  ///
  /// In en, this message translates to:
  /// **'AI Response'**
  String get ai_response_title;

  /// No description provided for @ai_response_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to get AI response'**
  String get ai_response_failed;

  /// No description provided for @upgrade_to_premium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgrade_to_premium;

  /// No description provided for @free_limit_reached.
  ///
  /// In en, this message translates to:
  /// **'You don’t need to watch ads every 5 uses of the AI feature.\nGet unlimited, ad-free access with a monthly subscription (\$1).'**
  String get free_limit_reached;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @overall.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get overall;

  /// No description provided for @purchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchase;

  /// No description provided for @cryingTrendByTime.
  ///
  /// In en, this message translates to:
  /// **'Crying trend by time of day'**
  String get cryingTrendByTime;

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get itemCount;

  /// No description provided for @aiFeature.
  ///
  /// In en, this message translates to:
  /// **'AI Features'**
  String get aiFeature;

  /// No description provided for @encouragement.
  ///
  /// In en, this message translates to:
  /// **'Inspire'**
  String get encouragement;

  /// No description provided for @encouragementFromAI.
  ///
  /// In en, this message translates to:
  /// **'Inspire from AI'**
  String get encouragementFromAI;

  /// No description provided for @consultation.
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get consultation;

  /// No description provided for @promptAdviceFromData.
  ///
  /// In en, this message translates to:
  /// **'Based on the following \'Reasons Why the Child Cried\' data, provide one short and practical piece of advice for the parent. The entry \'Cried!\' in the data has the same meaning as \'Unknown reason\'.'**
  String get promptAdviceFromData;

  /// No description provided for @roleNurseryTeacher.
  ///
  /// In en, this message translates to:
  /// **'You are a nursery teacher who gives kind and accurate advice to parents.'**
  String get roleNurseryTeacher;

  /// No description provided for @promptEncouragement.
  ///
  /// In en, this message translates to:
  /// **'Provide one short message to encourage parents who are tired from childcare.'**
  String get promptEncouragement;

  /// No description provided for @roleEncouragingAI.
  ///
  /// In en, this message translates to:
  /// **'You are a gentle AI that encourages parents.'**
  String get roleEncouragingAI;

  /// No description provided for @roleHelpfulAssistant.
  ///
  /// In en, this message translates to:
  /// **'You are a kind and knowledgeable assistant.'**
  String get roleHelpfulAssistant;

  /// No description provided for @limitCharacters150.
  ///
  /// In en, this message translates to:
  /// **'Please keep your answer within 150 characters.'**
  String get limitCharacters150;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @times.
  ///
  /// In en, this message translates to:
  /// **'times'**
  String get times;

  /// No description provided for @theme_pinkLight.
  ///
  /// In en, this message translates to:
  /// **'🌸 Pink (Light)'**
  String get theme_pinkLight;

  /// No description provided for @theme_pinkDark.
  ///
  /// In en, this message translates to:
  /// **'🌸 Pink (Dark)'**
  String get theme_pinkDark;

  /// No description provided for @theme_mintLight.
  ///
  /// In en, this message translates to:
  /// **'🌿 Mint (Light)'**
  String get theme_mintLight;

  /// No description provided for @theme_mintDark.
  ///
  /// In en, this message translates to:
  /// **'🌿 Mint (Dark)'**
  String get theme_mintDark;

  /// No description provided for @theme_lavenderLight.
  ///
  /// In en, this message translates to:
  /// **'💜 Lavender (Light)'**
  String get theme_lavenderLight;

  /// No description provided for @theme_lavenderDark.
  ///
  /// In en, this message translates to:
  /// **'💜 Lavender (Dark)'**
  String get theme_lavenderDark;

  /// No description provided for @theme_white.
  ///
  /// In en, this message translates to:
  /// **'⬜ White (Simple)'**
  String get theme_white;

  /// No description provided for @theme_black.
  ///
  /// In en, this message translates to:
  /// **'⬛ Black (Dark)'**
  String get theme_black;

  /// No description provided for @auth_wrong_password.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get auth_wrong_password;

  /// No description provided for @auth_user_not_found.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get auth_user_not_found;

  /// No description provided for @auth_email_already_exists.
  ///
  /// In en, this message translates to:
  /// **'This email address is already in use'**
  String get auth_email_already_exists;

  /// No description provided for @auth_invalid_password.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get auth_invalid_password;

  /// No description provided for @auth_invalid_credential.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get auth_invalid_credential;

  /// No description provided for @auth_invalid_email.
  ///
  /// In en, this message translates to:
  /// **'The email address format is incorrect'**
  String get auth_invalid_email;

  /// No description provided for @reward.
  ///
  /// In en, this message translates to:
  /// **'Reward'**
  String get reward;

  /// No description provided for @aiUsesAdded.
  ///
  /// In en, this message translates to:
  /// **'You can now use the AI feature 5 more times!'**
  String get aiUsesAdded;

  /// No description provided for @watchAdToUseAI.
  ///
  /// In en, this message translates to:
  /// **'Watch an ad to use the AI feature 5 times.\nTo remove ads, upgrade to Premium in your user info (1 USD/month).'**
  String get watchAdToUseAI;

  /// No description provided for @watchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad'**
  String get watchAd;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified. Please check the confirmation link.'**
  String get emailNotVerified;

  /// No description provided for @otherException.
  ///
  /// In en, this message translates to:
  /// **'Other exception:'**
  String get otherException;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long'**
  String get passwordMinLength;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @registeredEmail.
  ///
  /// In en, this message translates to:
  /// **'Registered Email Address'**
  String get registeredEmail;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Reset email has been sent'**
  String get resetEmailSent;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// No description provided for @createNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Create a new account'**
  String get createNewAccount;

  /// No description provided for @startWithoutLogin.
  ///
  /// In en, this message translates to:
  /// **'Start without logging in'**
  String get startWithoutLogin;

  /// No description provided for @loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Login with Google'**
  String get loginWithGoogle;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email'**
  String get verifyEmail;

  /// No description provided for @autoNavigateAfterVerification.
  ///
  /// In en, this message translates to:
  /// **'After clicking the verification link, you will be redirected automatically.'**
  String get autoNavigateAfterVerification;

  /// No description provided for @userInfo.
  ///
  /// In en, this message translates to:
  /// **'User Info'**
  String get userInfo;

  /// No description provided for @guestUser.
  ///
  /// In en, this message translates to:
  /// **'Guest (not logged in)'**
  String get guestUser;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @premiumUser.
  ///
  /// In en, this message translates to:
  /// **'Premium User'**
  String get premiumUser;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
