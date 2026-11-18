package uz.dokon.dokon

import io.flutter.embedding.android.FlutterActivity

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)
        MethodChannel(engine.dartExecutor.binaryMessenger, "uz.dokon/sms").setMethodCallHandler { call, result ->
            if (call.method != "compose") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val intent = Intent(Intent.ACTION_SENDTO, Uri.fromParts("smsto", call.argument<String>("phone"), null))
            intent.putExtra("sms_body", call.argument<String>("body"))
            try {
                startActivity(intent)
                result.success(null)
            } catch (e: android.content.ActivityNotFoundException) {
                result.error("NO_SMS", "SMS application unavailable", null)
            }
        }
    }
}
