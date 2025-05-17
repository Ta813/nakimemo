package com.example.nakimemo

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.appwidget.AppWidgetManager
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.SharedPreferences
import com.example.nakimemo.R
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetBackgroundService
import android.util.Log

class MyHomeWidgetProvider : HomeWidgetProvider() {
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
            Log.d("MyHomeWidgetProvider.onReceive", "uri: " + intent.getStringExtra("uri"))
            HomeWidgetBackgroundService.enqueueWork(context, intent)
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.home_widget)
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
}