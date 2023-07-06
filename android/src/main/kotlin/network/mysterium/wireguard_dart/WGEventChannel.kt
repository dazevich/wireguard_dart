package network.mysterium.wireguard_dart

import android.os.Handler
import io.flutter.plugin.common.EventChannel
import java.util.*

class WGEventChannel : EventChannel.StreamHandler {
    var sink: EventChannel.EventSink? = null

    fun send(state: String) {
        when (state) {
            "UP" -> sink?.success("connected")
            "DOWN" -> sink?.success("disconnected")
            "TOGGLE" -> sink?.success("connecting")
            else -> sink?.success("none")
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }
}