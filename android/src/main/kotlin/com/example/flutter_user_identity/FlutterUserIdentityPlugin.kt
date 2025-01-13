package com.example.flutter_user_identity

import android.accounts.AccountManager
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class ExpoUserIdentityPlugin : FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler,
    PluginRegistry.ActivityResultListener {

    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var activity: Activity? = null
    private var resultCallback: MethodChannel.Result? = null

    private val USER_IDENTITY_CODE = 1

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "flutter_user_identity")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "getUserIdentity") {
            getUserIdentity(call, result)
        } else {
            result.notImplemented()
        }
    }

    private fun getUserIdentity(call: MethodCall, result: MethodChannel.Result) {
        val accountType = call.argument<String>("accountType") ?: "com.google"
        val message = call.argument<String>("message") ?: "Please sign in to continue"

        val intent = AccountManager.newChooseAccountIntent(
            null, null, arrayOf(accountType), message, null, null, null
        )

        activity?.startActivityForResult(intent, USER_IDENTITY_CODE)
        resultCallback = result
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == USER_IDENTITY_CODE) {
            if (resultCode == Activity.RESULT_OK && data != null) {
                val accountName = data.getStringExtra(AccountManager.KEY_ACCOUNT_NAME)
                resultCallback?.success(accountName)
            } else {
                resultCallback?.error(
                    "USER_CANCELLED",
                    "User cancelled the account selection.",
                    null
                )
            }
            resultCallback = null
            return true
        }
        return false
    }
}