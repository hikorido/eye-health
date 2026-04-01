package com.example.eye_health

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {

    private val unlockChannelName = "com.example.eye_health/unlock"
    private var eventSink: EventChannel.EventSink? = null

    private val unlockReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == Intent.ACTION_USER_PRESENT) {
                eventSink?.success("unlock")
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            unlockChannelName
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
                eventSink = sink
                registerReceiver(
                    unlockReceiver,
                    IntentFilter(Intent.ACTION_USER_PRESENT)
                )
            }

            override fun onCancel(arguments: Any?) {
                unregisterReceiver(unlockReceiver)
                eventSink = null
            }
        })
    }
}
