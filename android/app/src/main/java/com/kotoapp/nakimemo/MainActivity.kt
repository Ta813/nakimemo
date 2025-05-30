package com.kotoapp.nakimemo

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import java.util.*
import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Android 13以上なら通知権限をリクエスト
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS)
                != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                    1001
                )
                // 許可後に通知を出すのでここではreturn
                return
            }
        }

        saveLastOperationTime(this)
        setAlarm()
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 1001 && grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            // 許可されたら通知を出す
            saveLastOperationTime(this)
            setAlarm()
        }
    }

    private fun setAlarm() {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, MyHomeWidgetProvider::class.java).apply {
            action = "com.kotoapp.nakimemo.ACTION_NOTIFY_IF_NEEDED"
        }
        val pendingIntent = PendingIntent.getBroadcast(
            this, 2, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val intervalMillis = 60 * 60 * 1000L // 1時間
        val triggerAtMillis = System.currentTimeMillis() + intervalMillis
        alarmManager.setRepeating(
            AlarmManager.RTC_WAKEUP,
            triggerAtMillis,
            intervalMillis,
            pendingIntent
        )
    }
    
    override fun onUserInteraction() {
        super.onUserInteraction()
        saveLastOperationTime(this)
    }

    fun saveLastOperationTime(context: Context) {
        val prefs = context.getSharedPreferences("nakimemo_prefs", Context.MODE_PRIVATE)
        prefs.edit().putLong("last_operation_time", System.currentTimeMillis()).apply()
    }
}