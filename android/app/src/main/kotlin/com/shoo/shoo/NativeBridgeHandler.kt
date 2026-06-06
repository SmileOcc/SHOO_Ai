package com.shoo.shoo

import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * SHOO Platform Channel 原生桩 — 与 Dart [SHONativeBridge] 对应。
 *
 * 耗时操作请在后台线程执行，完成后切回主线程调用 result.success/error。
 */
object NativeBridgeHandler {
    private const val METHOD_CHANNEL = "com.shoo.shoo/native_bridge"
    private const val MESSAGE_CHANNEL = "com.shoo.shoo/native_message"
    private const val EVENT_CHANNEL = "com.shoo.shoo/native_event"

    fun register(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "ping" -> result.success(
                        mapOf(
                            "ok" to true,
                            "platform" to "android",
                        ),
                    )

                    "getPlatformVersion" -> result.success("Android ${Build.VERSION.RELEASE}")

                    else -> result.notImplemented()
                }
            }

        io.flutter.plugin.common.BasicMessageChannel<Any>(
            flutterEngine.dartExecutor.binaryMessenger,
            MESSAGE_CHANNEL,
            io.flutter.plugin.common.StandardMessageCodec.INSTANCE,
        ).setMessageHandler { message, reply ->
            reply.reply(mapOf("echo" to message, "platform" to "android"))
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                private var handler: Handler? = null
                private var runnable: Runnable? = null
                private var tick = 0

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    tick = 0
                    handler = Handler(Looper.getMainLooper())
                    runnable = object : Runnable {
                        override fun run() {
                            tick += 1
                            events?.success(
                                mapOf(
                                    "kind" to (arguments?.toString() ?: "debug_tick"),
                                    "tick" to tick,
                                    "platform" to "android",
                                    "timestamp" to System.currentTimeMillis(),
                                ),
                            )
                            handler?.postDelayed(this, 1000)
                        }
                    }
                    handler?.post(runnable!!)
                }

                override fun onCancel(arguments: Any?) {
                    runnable?.let { handler?.removeCallbacks(it) }
                    handler = null
                    runnable = null
                }
            })
    }
}
