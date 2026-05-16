package com.smartenergy.smart_energy_controller

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class EnergyWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.energy_widget)
            
            val powerKw = widgetData.getString("powerKw", "-- kW")
            val status = widgetData.getString("status", "Offline")
            
            views.setTextViewText(R.id.widget_power, powerKw)
            views.setTextViewText(R.id.widget_status, status)
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
