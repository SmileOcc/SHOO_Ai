package com.shoo.shoo

import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * SHOO Platform Channel 原生桩 — 与 Dart [SHONativeBridge] 对应。
 */
object NativeBridgeHandler {
    private const val METHOD_CHANNEL = "com.shoo.shoo/native_bridge"
    private const val MESSAGE_CHANNEL = "com.shoo.shoo/native_message"
    private const val EVENT_CHANNEL = "com.shoo.shoo/native_event"

    private data class EventArgs(val kind: String, val params: Map<String, String>)

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
                private var downloadProgress = 0.0
                private var args = EventArgs("debug_tick", emptyMap())

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    tick = 0
                    downloadProgress = 0.0
                    args = parseArgs(arguments)
                    handler = Handler(Looper.getMainLooper())
                    runnable = object : Runnable {
                        override fun run() {
                            tick += 1
                            val payload = when (args.kind) {
                                "payment" -> paymentPayload(args, tick)
                                "download" -> downloadPayload(args, tick)
                                "logistics" -> logisticsPayload(args, tick)
                                else -> mapOf(
                                    "kind" to "debug_tick",
                                    "tick" to tick,
                                    "platform" to "android",
                                    "timestamp" to System.currentTimeMillis(),
                                )
                            }
                            events?.success(payload)
                            val delay = when (args.kind) {
                                "payment" -> if (tick >= 3) 0L else 2000L
                                "download" -> if (downloadProgress >= 1.0) 0L else 400L
                                "logistics" -> 5000L
                                else -> 1000L
                            }
                            if (delay > 0) {
                                handler?.postDelayed(this, delay)
                            }
                        }
                    }
                    handler?.post(runnable!!)
                }

                override fun onCancel(arguments: Any?) {
                    runnable?.let { handler?.removeCallbacks(it) }
                    handler = null
                    runnable = null
                }

                private fun paymentPayload(args: EventArgs, tick: Int): Map<String, Any?> {
                    val orderId = args.params["orderId"] ?: ""
                    return if (tick >= 3) {
                        mapOf(
                            "kind" to "payment",
                            "orderId" to orderId,
                            "status" to "success",
                            "transactionId" to "mock_tx_${System.currentTimeMillis()}",
                            "platform" to "android",
                            "timestamp" to System.currentTimeMillis(),
                        )
                    } else {
                        mapOf(
                            "kind" to "payment",
                            "orderId" to orderId,
                            "status" to "processing",
                            "message" to "Confirming payment...",
                            "platform" to "android",
                            "timestamp" to System.currentTimeMillis(),
                        )
                    }
                }

                private fun downloadPayload(args: EventArgs, tick: Int): Map<String, Any?> {
                    downloadProgress = (tick * 0.12).coerceAtMost(1.0)
                    val taskId = args.params["taskId"] ?: "mock_download"
                    return mapOf(
                        "kind" to "download",
                        "taskId" to taskId,
                        "progress" to downloadProgress,
                        "status" to if (downloadProgress >= 1.0) "completed" else "running",
                        "platform" to "android",
                        "timestamp" to System.currentTimeMillis(),
                    )
                }

                private fun logisticsPayload(args: EventArgs, tick: Int): Map<String, Any?> {
                    val orderId = args.params["orderId"] ?: ""
                    val events = listOf(
                        "Package picked up",
                        "In transit to hub",
                        "Out for delivery",
                        "Delivered",
                    )
                    val event = events[(tick - 1) % events.size]
                    return mapOf(
                        "kind" to "logistics",
                        "orderId" to orderId,
                        "event" to event,
                        "message" to "Logistics update #$tick",
                        "platform" to "android",
                        "timestamp" to System.currentTimeMillis(),
                    )
                }
            })
    }

    private fun parseArgs(arguments: Any?): EventArgs {
        val raw = arguments?.toString() ?: "debug_tick"
        val parts = raw.split(":", limit = 2)
        val kind = parts[0]
        val params = mutableMapOf<String, String>()
        if (parts.size == 2) {
            parts[1].split(",").forEach { pair ->
                val kv = pair.split("=", limit = 2)
                if (kv.size == 2) {
                    params[kv[0].trim()] = kv[1].trim()
                }
            }
        }
        return EventArgs(kind, params)
    }
}
