package com.example.yourapp

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.SystemClock

class PowerButtonReceiver : BroadcastReceiver() {

    companion object {
        private const val CLICK_THRESHOLD = 3 // Number of presses
        private const val TIME_WINDOW = 2000L // Time window in milliseconds

        private var clickCount = 0
        private var lastClickTime: Long = 0
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (Intent.ACTION_SCREEN_OFF == intent.action) {
            val currentTime = SystemClock.elapsedRealtime()
            if (currentTime - lastClickTime < TIME_WINDOW) {
                clickCount++
            } else {
                clickCount = 1 // Reset count
            }
            lastClickTime = currentTime

            if (clickCount >= CLICK_THRESHOLD) {
                // Open the app
                val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
                if (launchIntent != null) {
                    launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    context.startActivity(launchIntent)
                }

                // Reset click count
                clickCount = 0
            }
        }
    }
}
