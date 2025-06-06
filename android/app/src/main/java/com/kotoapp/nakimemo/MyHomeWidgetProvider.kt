package com.kotoapp.nakimemo

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.appwidget.AppWidgetManager
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.SharedPreferences
import com.kotoapp.nakimemo.R
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetBackgroundService
import android.util.Log
import android.content.ComponentName
import android.app.NotificationChannel
import android.app.NotificationManager
import androidx.core.app.NotificationCompat

class MyHomeWidgetProvider : HomeWidgetProvider() {
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        if (intent.action == "com.kotoapp.nakimemo.ACTION_NOTIFY_IF_NEEDED") {
            val lastOp = getLastOperationTime(context)
            val now = System.currentTimeMillis()
            val oneHour = 60 * 60 * 1000L

            if (now - lastOp >= oneHour) {
                showCryNotification(context)
            }
        }

        if (intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
            Log.d("MyHomeWidgetProvider.onReceive", "uri: " + intent.getStringExtra("uri"))
            
            if (intent.getStringExtra("uri") == "myapp://cry") {
                // ボタンが押されたときの処理
                val now = java.text.SimpleDateFormat("YYYY-MM-dd HH:mm:ss.SSS", java.util.Locale.getDefault()).format(java.util.Date())
                val nowNoMillis = now.replace(Regex("\\.\\d{3}$"), "") // ミリ秒だけ削除
                val views = RemoteViews(context.packageName, R.layout.home_widget)
                Log.d("MyHomeWidgetProvider.onReceive", "lastCryTime: $now")

                views.setTextViewText(R.id.text_last_cry, nowNoMillis)

                // SharedPreferencesに現在時刻を保存
                val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
                prefs.edit().putString("last_cry_time", now).apply()
                
                // ホームウィジェットの更新
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val thisWidget = ComponentName(context, MyHomeWidgetProvider::class.java)
                val appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
                for (appWidgetId in appWidgetIds) {
                    appWidgetManager.updateAppWidget(appWidgetId, views)
                }

                // 現在時刻をIntentに追加してFlutter側に渡す
                // dataにクエリパラメータとして時刻を含める
                val newIntent = Intent(context, MyHomeWidgetProvider::class.java).apply {
                    action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    setPackage(context.packageName)
                    putExtra("uri", "myapp://cry")
                    data = Uri.parse("myapp://cry?last_cry_time=$now")
                }

                // バックグラウンドサービスを起動
                HomeWidgetBackgroundService.enqueueWork(context, newIntent)
            }
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        Log.d("MyHomeWidgetProvider.onUpdate", "called")

        // cry_logsの最新日時を取得
        val lastCryTime = widgetData.getString("last_cry_time", "") ?: ""
        val displayText = if (lastCryTime.isEmpty()) "ボタンを押してね！" else lastCryTime
        val displayTextNoMillis = displayText.replace(Regex("\\.\\d{3}$"), "") // ミリ秒だけ削除

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.home_widget)
            views.setTextViewText(R.id.text_last_cry, displayTextNoMillis)

            // ボタンのクリックイベントを設定
            val intent = Intent(context, MyHomeWidgetProvider::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                setPackage(context.packageName)
                putExtra("uri", "myapp://cry")
                data = Uri.parse("myapp://cry")
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.button_cry, pendingIntent)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    fun showCryNotification(context: Context) {
        val channelId = "cry_action_channel"
        val channelName = "泣いたアクション"
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            val channel = NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_DEFAULT)
            notificationManager.createNotificationChannel(channel)
        }

        val intent = Intent(context, MyHomeWidgetProvider::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra("uri", "myapp://cry")
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context, 1, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.drawable.ic_launcher)
            .setContentTitle("泣きメモ")
            .setContentText("泣いたら下のリンクを押して記録しよう！")
            .addAction(R.drawable.ic_launcher, "泣いた！", pendingIntent)
            .setAutoCancel(true)
            .build()

        notificationManager.notify(1001, notification)
    }

    fun getLastOperationTime(context: Context): Long {
        val prefs = context.getSharedPreferences("nakimemo_prefs", Context.MODE_PRIVATE)
        return prefs.getLong("last_operation_time", 0L)
    }
}