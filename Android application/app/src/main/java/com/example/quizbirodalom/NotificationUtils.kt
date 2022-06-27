package com.example.quizbirodalom

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory.decodeResource
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat.getSystemService
import com.example.webview_kotlin.R


class NotificationUtils(context:Context) {

    private var mContext = context
    private lateinit var notificationBuilder: NotificationCompat.Builder
    val notificationManager = NotificationManagerCompat.from(mContext)
    private val CHANNEL_ID = "My_Notification_Channel"


    init {
        createNotificationChannel()
        initNotificationBuilder()
    }


    fun launchNotification(){
        with(NotificationManagerCompat.from(mContext)) {
            // notificationId is a unique int for each notification that you must define
            notificationManager.notify(0, notificationBuilder.build())
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Channel Name"
            val descriptionText = "Channel Description"
            val importance = NotificationManager.IMPORTANCE_DEFAULT
            val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
                description = descriptionText
            }
            val notifiManager: NotificationManager =
                mContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notifiManager.createNotificationChannel(channel)
        }
    }

    private fun initNotificationBuilder() {

        val sampleIntent = Intent(mContext, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }

        sampleIntent.setAction(Intent.ACTION_MAIN)
        sampleIntent.addCategory(Intent.CATEGORY_LAUNCHER)

        val pendingIntent: PendingIntent = PendingIntent.getActivity(
            mContext, 0, sampleIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_ONE_SHOT)

        val bitmap = decodeResource(mContext.resources, R.drawable.steamtwo)
        val bitmapLargeIcon = decodeResource(mContext.resources, R.drawable.androidtwo)
       
        notificationBuilder = NotificationCompat.Builder(mContext, CHANNEL_ID)
            .setSmallIcon(R.drawable.androidtwo)
            .setContentTitle("QuizBirodalom - Napi belépés")
            .setContentText("Lépj be ma is az oldalra, gyűjts pontokat és vegyél részt izgalmas kvízeinken!")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            // Set the intent that will fire when the user taps the notification
            .setContentIntent(pendingIntent)
            .setLargeIcon(bitmapLargeIcon)
            .setStyle(NotificationCompat.BigPictureStyle().bigPicture(bitmap))
            // Automatically removes the notification when the user taps it.
            .setAutoCancel(true)
            .setOngoing(true)
    }
}
