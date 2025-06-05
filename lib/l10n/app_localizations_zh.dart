// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get stats_title => '统计';

  @override
  String get adviceButton => '获取建议';

  @override
  String get noRecords => '没有记录';

  @override
  String get input_title => '记录哭闹事件';

  @override
  String get save_button => '保存';

  @override
  String get cancel_button => '取消';

  @override
  String get calendar_title => '哭闹日历';

  @override
  String get help_title => '输入页面帮助';

  @override
  String get help_text_1 => '・点击“奶”、“尿布”等按钮记录时间。';

  @override
  String get help_text_2 => '・记录会按天自动保存。';

  @override
  String get help_text_3 => '・滑动可删除记录，点击可编辑类别。';

  @override
  String get help_text_4 => '・点击右上角垃圾桶图标可清除当天记录。';

  @override
  String get delete_today_tooltip => '删除今天的记录';

  @override
  String get help_tooltip => '帮助';

  @override
  String get edit_category_title => '编辑类别';

  @override
  String get edit_category_label => '类别';

  @override
  String get stats_help_title => '统计页面使用说明';

  @override
  String get stats_help_content =>
      '此页面按类别和月份汇总过去的育儿记录，并以图表方式显示。\n\n📌 显示类别：\n🍼 喂奶, 💩 换尿布, 🌙 夜间哭闹, 🐾 其他\n\n📆 可在顶部切换年月。\n\n💡 点击“获取 AI 建议”按钮，获得 AI 提供的育儿建议。';

  @override
  String get close => '关闭';

  @override
  String get ai_advice_title => 'AI 建议';

  @override
  String get error_title => '错误';

  @override
  String get advice_fetch_failed => '获取建议失败。请检查网络连接或 API 密钥。';

  @override
  String get settingsTitle => '设置';

  @override
  String get language => '语言';

  @override
  String get theme => '主题';

  @override
  String get layout => '布局';

  @override
  String get nakimemo => 'ナキメモ';

  @override
  String get input_label => '输入';

  @override
  String get calendar_label => '日历';

  @override
  String get stats_label => '统计';

  @override
  String get setting_label => '设置';

  @override
  String get font => '字体';

  @override
  String get show_guide => '显示使用指南';

  @override
  String get introTitle1 => '欢迎';

  @override
  String get introDesc1 => '欢迎使用Nakimemo！这个应用程序可以轻松记录你哭泣的时间。';

  @override
  String get introTitle2 => '如何记录';

  @override
  String get introDesc2 => '点击“我哭了！”按钮即可自动记录时间。';

  @override
  String get introTitle3 => '更改分类';

  @override
  String get introDesc3 => '我们提供了6种直观的分类可供选择。\n\n如果你不确定哭泣的原因，就保持“我哭了！”即可。';

  @override
  String get introTitle4 => '日历管理';

  @override
  String get introDesc4 => '你可以在日历页面回顾和编辑记录。';

  @override
  String get introTitle5 => '统计页面';

  @override
  String get introDesc5 => '通过图表查看哭泣的时间。';

  @override
  String get introTitle6 => 'AI分析';

  @override
  String get introDesc6 => 'AI会分析你哭泣的原因，并为你提供个性化建议。\n\n※（订阅服务）可免费试用5次。\n\n';

  @override
  String get cry => '哭了！';

  @override
  String get milk => '奶粉';

  @override
  String get diaper => '尿布';

  @override
  String get sleepy => '困了';

  @override
  String get hold => '抱抱';

  @override
  String get uncomfortable => '不舒服';

  @override
  String get sick => '身体不适';

  @override
  String get select_category => '选择类别';

  @override
  String get edit_memo => '编辑备注';

  @override
  String get enter_memo => '请输入备注';

  @override
  String get log_added => ' 已添加';

  @override
  String get log_deleted => ' 已删除';

  @override
  String get log_updated => ' 已修改';

  @override
  String get saved_memo => '已保存备注至';

  @override
  String get cry_instruction => '当孩子哭时，请按“哭了！”按钮。';

  @override
  String get cry_note => '等孩子安静下来后请选择一个类别。\n保持为“哭了！”也没关系。';

  @override
  String get memo => '备注';

  @override
  String get calendar_help_title => '日历画面帮助';

  @override
  String get calendar_help_1 => '・点击日历上的日期可以查看当天的记录。';

  @override
  String get calendar_help_2 => '・记录旁边的图标表示其分类。';

  @override
  String get calendar_help_3 => '・点击记录可编辑其分类。';

  @override
  String get calendar_help_4 => '・滑动记录即可删除。';

  @override
  String get calendar_help_5 => '・日期下方有圆形标记的表示该天有记录。';

  @override
  String get add_record => '添加记录';

  @override
  String get select_time => '选择时间：';

  @override
  String get add_button => '添加';

  @override
  String get future_time_error => '无法记录未来的时间';

  @override
  String get error => '错误';

  @override
  String get ok => '确定';

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
    return '第$week周';
  }

  @override
  String get ai_consultation_title => '咨询 AI';

  @override
  String get consultation_input_hint => '请输入您的问题';

  @override
  String get send_button => '发送';

  @override
  String get advice_fetch_error => '获取建议失败：';

  @override
  String get encouragement_fetch_error => '获取鼓励信息失败';

  @override
  String get ai_response_title => 'AI的回答';

  @override
  String get ai_response_failed => '无法获取AI的回答';

  @override
  String get upgrade_to_premium => '升级为高级版';

  @override
  String get free_limit_reached =>
      '使用 AI 功能每 5 次无需观看广告。\n订阅月费（1 美元）即可无限制无广告使用。';

  @override
  String get day => '日';

  @override
  String get week => '周';

  @override
  String get month => '月';

  @override
  String get overall => '整体';

  @override
  String get purchase => '购买';

  @override
  String get cryingTrendByTime => '按时间段的哭泣趋势';

  @override
  String get itemCount => '件';

  @override
  String get aiFeature => 'AI功能';

  @override
  String get encouragement => '鼓励';

  @override
  String get encouragementFromAI => '来自AI的鼓励';

  @override
  String get consultation => '咨询';

  @override
  String get promptAdviceFromData =>
      '请根据以下“孩子哭泣的原因数据”，为家长提供一条简短且实用的建议。“哭了！”表示“原因不明”。';

  @override
  String get roleNurseryTeacher => '你是一名善良且能为家长提供准确建议的保育员。';

  @override
  String get promptEncouragement => '请为因育儿疲惫的家长提供一句简短的鼓励语。';

  @override
  String get roleEncouragingAI => '你是一位温柔鼓励家长的AI。';

  @override
  String get roleHelpfulAssistant => '你是一位亲切且知识丰富的助手。';

  @override
  String get limitCharacters150 => '请将回答控制在150个字符以内。';

  @override
  String get data => '数据';

  @override
  String get times => '次';

  @override
  String get theme_pinkLight => '🌸 粉色（浅色）';

  @override
  String get theme_pinkDark => '🌸 粉色（深色）';

  @override
  String get theme_mintLight => '🌿 薄荷（浅色）';

  @override
  String get theme_mintDark => '🌿 薄荷（深色）';

  @override
  String get theme_lavenderLight => '💜 薰衣草（浅色）';

  @override
  String get theme_lavenderDark => '💜 薰衣草（深色）';

  @override
  String get theme_white => '⬜ 白色（简约）';

  @override
  String get theme_black => '⬛ 黑色（深色）';

  @override
  String get auth_wrong_password => '密码错误';

  @override
  String get auth_user_not_found => '找不到用户';

  @override
  String get auth_email_already_exists => '该电子邮件地址已被使用';

  @override
  String get auth_invalid_password => '密码必须至少包含6个字符';

  @override
  String get auth_invalid_credential => '认证失败';

  @override
  String get auth_invalid_email => '电子邮件地址格式不正确';

  @override
  String get reward => '奖励';

  @override
  String get aiUsesAdded => '您现在可以额外使用5次AI功能！';

  @override
  String get watchAdToUseAI => '观看广告可使用AI功能5次。\n如要移除广告，请在用户信息中升级为高级用户（每月1美元）。';

  @override
  String get watchAd => '观看广告';

  @override
  String get emailNotVerified => '邮箱未验证。请检查确认链接。';

  @override
  String get otherException => '其他异常：';

  @override
  String get createAccount => '创建新账户';

  @override
  String get email => '电子邮件地址';

  @override
  String get password => '密码';

  @override
  String get enterEmail => '请输入电子邮件地址';

  @override
  String get enterPassword => '请输入密码';

  @override
  String get passwordMinLength => '密码必须至少6个字符';

  @override
  String get register => '注册';

  @override
  String get resetPassword => '重置密码';

  @override
  String get registeredEmail => '已注册的电子邮件地址';

  @override
  String get resetEmailSent => '已发送重置邮件';

  @override
  String get login => '登录';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get createNewAccount => '创建账户';

  @override
  String get startWithoutLogin => '无需登录开始使用';

  @override
  String get loginWithGoogle => '使用 Google 登录';

  @override
  String get verifyEmail => '请确认您的电子邮件';

  @override
  String get autoNavigateAfterVerification => '点击验证链接后将自动跳转到下一个页面。';

  @override
  String get userInfo => '用户信息';

  @override
  String get guestUser => '访客（未登录）';

  @override
  String get upgradeToPremium => '升级为高级版';

  @override
  String get logout => '登出';

  @override
  String get premiumUser => '高级用户';
}
