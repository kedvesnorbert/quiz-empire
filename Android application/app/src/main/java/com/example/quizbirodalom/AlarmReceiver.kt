package com.example.quizbirodalom

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import java.util.*

class AlarmReceiver:BroadcastReceiver() {
    override fun onReceive(context: Context?, mIntent: Intent?) {
        val notificationUtils = NotificationUtils(context!!)
        notificationUtils.launchNotification()

        val calendar = Calendar.getInstance()
        calendar.add(Calendar.DAY_OF_YEAR, 1)
        val daysNextCalendar = calendar
        val alarmUtils = AlarmUtils(context)
        alarmUtils.initRepeatingAlarm(daysNextCalendar)

    }
}