package uz.dokon.dokon

import android.Manifest
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.telephony.SmsManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val SMS_PERMISSION_CODE = 2001
    private var pendingResult: MethodChannel.Result? = null
    private var pendingPhone: String? = null
    private var pendingBody: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Dastur ochilganda foydalanuvchidan SMS ruxsatini so'rab qo'yadi, keyin sotuvda bosish bilan to'g'ridan-to'g'ri ketadi
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.SEND_SMS),
                SMS_PERMISSION_CODE
            )
        }
    }

    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)
        MethodChannel(engine.dartExecutor.binaryMessenger, "uz.dokon/sms").setMethodCallHandler { call, result ->
            if (call.method != "compose") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            var phone = (call.argument<String>("phone") ?: "").replace(Regex("[^0-9+]"), "")
            if (phone.length == 9 && !phone.startsWith("+")) {
                phone = "+998$phone"
            }
            val body = call.argument<String>("body") ?: ""

            if (phone.isBlank()) {
                result.error("INVALID_PHONE", "Telefon raqami kiritilmagan", null)
                return@setMethodCallHandler
            }

            if (ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS) == PackageManager.PERMISSION_GRANTED) {
                sendDirectSms(phone, body, result)
            } else {
                pendingResult = result
                pendingPhone = phone
                pendingBody = body
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(Manifest.permission.SEND_SMS),
                    SMS_PERMISSION_CODE
                )
            }
        }
    }

    private fun sendDirectSms(phone: String, body: String, result: MethodChannel.Result?) {
        try {
            val smsManager: SmsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                getSystemService(SmsManager::class.java) ?: @Suppress("DEPRECATION") SmsManager.getDefault()
            } else {
                @Suppress("DEPRECATION")
                SmsManager.getDefault()
            }
            // GSM 7-bit toza SMS matnini bo'laklarga ajratish va to'g'ridan-to'g'ri SMS qilib yuborish (MMS ga aylanmaydi)
            val parts = smsManager.divideMessage(body)
            if (parts.size <= 1) {
                smsManager.sendTextMessage(phone, null, body, null, null)
            } else {
                smsManager.sendMultipartTextMessage(phone, null, parts, null, null)
            }
            result?.success("SENT_DIRECT")
        } catch (e: Exception) {
            fallbackToCompose(phone, body, result)
        }
    }

    private fun fallbackToCompose(phone: String, body: String, result: MethodChannel.Result?) {
        val intent = Intent(Intent.ACTION_SENDTO, Uri.parse("smsto:$phone"))
        intent.putExtra("sms_body", body)
        intent.putExtra(Intent.EXTRA_TEXT, body)
        try {
            startActivity(intent)
            result?.success("FALLBACK_COMPOSE")
        } catch (e: ActivityNotFoundException) {
            result?.error("NO_SMS", "SMS ilovasi topilmadi", null)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == SMS_PERMISSION_CODE) {
            val r = pendingResult
            val phone = pendingPhone ?: ""
            val body = pendingBody ?: ""
            pendingResult = null
            pendingPhone = null
            pendingBody = null

            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                if (phone.isNotEmpty()) {
                    sendDirectSms(phone, body, r)
                }
            } else {
                if (phone.isNotEmpty()) {
                    fallbackToCompose(phone, body, r)
                }
            }
        }
    }
}
