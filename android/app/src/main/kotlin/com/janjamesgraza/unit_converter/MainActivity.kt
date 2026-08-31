package com.janjamesgraza.unit_converter

import android.app.KeyguardManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.PowerManager
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "unit_converter/presence"
    private var channel: MethodChannel? = null
    private var receiverRegistered = false

    private val screenReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val signal = when (intent?.action) {
                Intent.ACTION_SCREEN_OFF -> "screenOff"
                Intent.ACTION_SCREEN_ON -> "screenOn"
                Intent.ACTION_USER_PRESENT -> "deviceUnlocked"
                else -> null
            }
            signal?.let { channel?.invokeMethod("presenceSignal", it) }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getCurrentState" -> result.success(currentPresenceState())
                else -> result.notImplemented()
            }
        }

        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_OFF)
            addAction(Intent.ACTION_SCREEN_ON)
            addAction(Intent.ACTION_USER_PRESENT)
        }
        ContextCompat.registerReceiver(
            this,
            screenReceiver,
            filter,
            ContextCompat.RECEIVER_NOT_EXPORTED,
        )
        receiverRegistered = true
    }

    override fun onResume() {
        super.onResume()
        channel?.invokeMethod("presenceSignal", currentPresenceState())
    }

    override fun onDestroy() {
        if (receiverRegistered) {
            unregisterReceiver(screenReceiver)
            receiverRegistered = false
        }
        channel?.setMethodCallHandler(null)
        channel = null
        super.onDestroy()
    }

    private fun currentPresenceState(): String {
        val keyguard = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        val power = getSystemService(Context.POWER_SERVICE) as PowerManager
        return if (keyguard.isKeyguardLocked || !power.isInteractive) {
            "deviceLocked"
        } else {
            "deviceUnlocked"
        }
    }
}
