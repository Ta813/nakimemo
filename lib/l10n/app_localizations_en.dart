// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get stats_title => 'Stats';

  @override
  String get adviceButton => 'Advice';

  @override
  String get noRecords => 'No records found';

  @override
  String get input_title => 'Log Cry Event';

  @override
  String get save_button => 'Save';

  @override
  String get cancel_button => 'Cancel';

  @override
  String get calendar_title => 'Cry Calendar';

  @override
  String get help_title => 'Input Help';

  @override
  String get help_text_1 =>
      '・Tap a button like \'Milk\' or \'Diaper\' to record the time.';

  @override
  String get help_text_2 => '・Records are automatically saved per day.';

  @override
  String get help_text_3 => '・Swipe to delete a log, or tap to edit category.';

  @override
  String get help_text_4 => '・Use the trash icon to clear today\'s records.';

  @override
  String get delete_today_tooltip => 'Delete today\'s records';

  @override
  String get help_tooltip => 'Help';

  @override
  String get edit_category_title => 'Edit Category';

  @override
  String get edit_category_label => 'Category';

  @override
  String get stats_help_title => 'How to Use the Statistics Screen';

  @override
  String get stats_help_content =>
      'This screen summarizes past childcare records by category for each month and displays them in a graph.\n\n📌 Categories shown:\n🍼 Milk, 💩 Diaper, 🌙 Night Crying, 🐾 Other\n\n📆 You can change the year and month at the top.\n\n💡 Tap the \"Get AI Advice\" button to receive parenting tips from AI.';

  @override
  String get close => 'Close';

  @override
  String get ai_advice_title => 'AI Advice';

  @override
  String get error_title => 'Error';

  @override
  String get advice_fetch_failed =>
      'Failed to fetch advice. Please check your network or API key.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get layout => 'Layout';

  @override
  String get nakimemo => 'ナキメモ';

  @override
  String get input_label => 'Input';

  @override
  String get calendar_label => 'Calendar';

  @override
  String get stats_label => 'Stats';

  @override
  String get setting_label => 'Setting';

  @override
  String get font => 'Font';

  @override
  String get show_guide => 'Show Guide';

  @override
  String get introTitle1 => 'Welcome';

  @override
  String get introDesc1 =>
      'Welcome to Nakimemo! This app lets you easily log your crying time.';

  @override
  String get introTitle2 => 'How to record';

  @override
  String get introDesc2 =>
      'Just tap the \"I Cried!\" button to automatically log the time.';

  @override
  String get introTitle3 => 'Change category';

  @override
  String get introDesc3 =>
      'You can choose from 6 intuitive categories.\n\nIf you\'re unsure why you cried, just leave it as \"I Cried!\".';

  @override
  String get introTitle4 => 'Calendar view';

  @override
  String get introDesc4 => 'Check and edit your records in the calendar view.';

  @override
  String get introTitle5 => 'Statistics';

  @override
  String get introDesc5 => 'Review your crying time with graphs and charts.';

  @override
  String get introTitle6 => 'AI Analysis';

  @override
  String get introDesc6 =>
      'The AI analyzes why you cried and offers personalized advice.\n\n*You can use it by watching an ad every 5 times. Unlimited use is available with a monthly subscription (\$1).\n\n';

  @override
  String get cry => 'Cried!';

  @override
  String get milk => 'Milk';

  @override
  String get diaper => 'Diaper';

  @override
  String get sleepy => 'Sleepy';

  @override
  String get hold => 'Hold';

  @override
  String get uncomfortable => 'Upset';

  @override
  String get sick => 'Sick';

  @override
  String get select_category => 'Select Category';

  @override
  String get edit_memo => 'Edit Memo';

  @override
  String get enter_memo => 'Enter memo';

  @override
  String get log_added => ' was added';

  @override
  String get log_deleted => ' was deleted';

  @override
  String get log_updated => ' was updated';

  @override
  String get saved_memo => 'Memo saved to';

  @override
  String get cry_instruction =>
      'Press the \"Cried!\" button when your child starts crying.';

  @override
  String get cry_note =>
      'Once things calm down, please select a category.\nIt\'s okay to leave it as \"Cried!\".';

  @override
  String get memo => 'Memo';

  @override
  String get calendar_help_title => 'Calendar Screen Help';

  @override
  String get calendar_help_1 =>
      '・Tap a date on the calendar to view the records for that day.';

  @override
  String get calendar_help_2 =>
      '・The icon next to each record indicates its category.';

  @override
  String get calendar_help_3 => '・Tap a record to edit its category.';

  @override
  String get calendar_help_4 => '・Swipe a record to delete it.';

  @override
  String get calendar_help_5 =>
      '・A circular marker under the date means there are records on that day.';

  @override
  String get add_record => 'Add Record';

  @override
  String get select_time => 'Select Time:';

  @override
  String get add_button => 'Add';

  @override
  String get future_time_error => 'Cannot record a future time';

  @override
  String get error => 'Error';

  @override
  String get ok => 'OK';

  @override
  String year_label(Object year) {
    return '$year';
  }

  @override
  String month_label(Object month) {
    return '$month';
  }

  @override
  String day_label(Object day) {
    return 'Day $day';
  }

  @override
  String week_label(Object week) {
    return 'Week $week';
  }

  @override
  String get ai_consultation_title => 'Ask AI';

  @override
  String get consultation_input_hint => 'Enter your concern';

  @override
  String get send_button => 'Send';

  @override
  String get advice_fetch_error => 'Failed to fetch advice:';

  @override
  String get encouragement_fetch_error => 'Failed to fetch inspire message';

  @override
  String get ai_response_title => 'AI Response';

  @override
  String get ai_response_failed => 'Failed to get AI response';

  @override
  String get upgrade_to_premium => 'Upgrade to Premium';

  @override
  String get free_limit_reached =>
      'You don’t need to watch ads every 5 uses of the AI feature.\nGet unlimited, ad-free access with a monthly subscription (\$1).';

  @override
  String get day => 'Day';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get overall => 'All';

  @override
  String get purchase => 'Purchase';

  @override
  String get cryingTrendByTime => 'Crying trend by time of day';

  @override
  String get itemCount => 'items';

  @override
  String get aiFeature => 'AI Features';

  @override
  String get encouragement => 'Inspire';

  @override
  String get encouragementFromAI => 'Inspire from AI';

  @override
  String get consultation => 'Ask';

  @override
  String get promptAdviceFromData =>
      'Based on the following \'Reasons Why the Child Cried\' data, provide one short and practical piece of advice for the parent. The entry \'Cried!\' in the data has the same meaning as \'Unknown reason\'.';

  @override
  String get roleNurseryTeacher =>
      'You are a nursery teacher who gives kind and accurate advice to parents.';

  @override
  String get promptEncouragement =>
      'Provide one short message to encourage parents who are tired from childcare.';

  @override
  String get roleEncouragingAI =>
      'You are a gentle AI that encourages parents.';

  @override
  String get roleHelpfulAssistant =>
      'You are a kind and knowledgeable assistant.';

  @override
  String get limitCharacters150 =>
      'Please keep your answer within 150 characters.';

  @override
  String get data => 'Data';

  @override
  String get times => 'times';

  @override
  String get theme_pinkLight => '🌸 Pink (Light)';

  @override
  String get theme_pinkDark => '🌸 Pink (Dark)';

  @override
  String get theme_mintLight => '🌿 Mint (Light)';

  @override
  String get theme_mintDark => '🌿 Mint (Dark)';

  @override
  String get theme_lavenderLight => '💜 Lavender (Light)';

  @override
  String get theme_lavenderDark => '💜 Lavender (Dark)';

  @override
  String get theme_white => '⬜ White (Simple)';

  @override
  String get theme_black => '⬛ Black (Dark)';

  @override
  String get auth_wrong_password => 'Incorrect password';

  @override
  String get auth_user_not_found => 'User not found';

  @override
  String get auth_email_already_exists =>
      'This email address is already in use';

  @override
  String get auth_invalid_password => 'Password must be at least 6 characters';

  @override
  String get auth_invalid_credential => 'Authentication failed';

  @override
  String get auth_invalid_email => 'The email address format is incorrect';

  @override
  String get reward => 'Reward';

  @override
  String get aiUsesAdded => 'You can now use the AI feature 5 more times!';

  @override
  String get watchAdToUseAI =>
      'Watch an ad to use the AI feature 5 times.\nTo remove ads, upgrade to Premium in your user info (1 USD/month).';

  @override
  String get watchAd => 'Watch Ad';

  @override
  String get emailNotVerified =>
      'Email not verified. Please check the confirmation link.';

  @override
  String get otherException => 'Other exception:';

  @override
  String get createAccount => 'Create Account';

  @override
  String get email => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get enterEmail => 'Please enter your email address';

  @override
  String get enterPassword => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters long';

  @override
  String get register => 'Register';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get registeredEmail => 'Registered Email Address';

  @override
  String get resetEmailSent => 'Reset email has been sent';

  @override
  String get login => 'Login';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get createNewAccount => 'Create a new account';

  @override
  String get startWithoutLogin => 'Start without logging in';

  @override
  String get loginWithGoogle => 'Login with Google';

  @override
  String get verifyEmail => 'Please verify your email';

  @override
  String get autoNavigateAfterVerification =>
      'After clicking the verification link, you will be redirected automatically.';

  @override
  String get userInfo => 'User Info';

  @override
  String get guestUser => 'Guest (not logged in)';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get logout => 'Log Out';

  @override
  String get premiumUser => 'Premium User';
}
