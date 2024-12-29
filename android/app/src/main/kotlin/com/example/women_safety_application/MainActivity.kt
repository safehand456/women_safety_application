package com.example.women_safety_application
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity




class MainActivity: FlutterActivity() {
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val feature = intent.getStringExtra("feature")
        if (feature == "help") {
            // Pass the feature to Flutter
            intent.putExtra("feature", "help")
        }
    }
}

