package com.example.image_cropping

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    val CHANNEL = "flutter_image_compress"
    val METHOD = "compress"

    companion object {
        var showLog = true
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD -> result.success("yes")
                else -> result.success("no")
            }
        }
    }

}
