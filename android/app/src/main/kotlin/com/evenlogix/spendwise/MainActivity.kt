package com.evenlogix.spendwise

import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Backward-compatible edge-to-edge for Android 14 and below.
        // Android 15+ enforces it when the app targets SDK 35.
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        // FlutterFragmentActivity applies a status-bar scrim after setContentView.
        // Re-apply so that scrim does not stick on pre-Android 15 devices.
        enableEdgeToEdge()
    }
}
