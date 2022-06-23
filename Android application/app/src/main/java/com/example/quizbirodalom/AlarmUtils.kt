package com.example.quizbirodalom

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import java.util.*

class AlarmUtils(context: Context) {
    private var mContext = context
    private var alarmMgr: AlarmManager? = null
    private var alarmIntent: PendingIntent

    init {
        alarmMgr = mContext.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmIntent = Intent(mContext, AlarmReceiver::class.java).let { mIntent ->
            // if you want more than one notification use different requestCode
            // every notification need different requestCode
            PendingIntent.getBroadcast(mContext, 100, mIntent, 0)
        }
    }

    fun initRepeatingAlarm(calendar: Calendar) {
        val t = System.currentTimeMillis()

        calendar.apply {
            set(Calendar.HOUR_OF_DAY, 10)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
        }

        if (t <= calendar.getTimeInMillis())
        {
            alarmMgr?.set(AlarmManager.RTC_WAKEUP, calendar.getTimeInMillis(), alarmIntent)
        }
    }
}