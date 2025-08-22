package com.example.purchase_tracking_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.media.MediaScannerConnection
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.purchase_tracking_app/media_scan"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "forceScan" -> {
                    val filePath = call.argument<String>("path")
                    if (filePath != null) {
                        forceScanFile(filePath, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "File path is required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun forceScanFile(filePath: String, result: MethodChannel.Result) {
        try {
            val file = File(filePath)
            if (file.exists()) {
                // Force immediate media scan
                MediaScannerConnection.scanFile(
                    this,
                    arrayOf(filePath),
                    arrayOf("image/jpeg"),
                    object : MediaScannerConnection.OnScanCompletedListener {
                        override fun onScanCompleted(path: String?, uri: android.net.Uri?) {
                            if (uri != null) {
                                result.success("File scanned and visible in gallery")
                            } else {
                                result.error("SCAN_FAILED", "File scanned but URI is null", null)
                            }
                        }
                    }
                )
            } else {
                result.error("FILE_NOT_FOUND", "File does not exist", null)
            }
        } catch (e: Exception) {
            result.error("SCAN_ERROR", "Failed to scan file: ${e.message}", null)
        }
    }
}
