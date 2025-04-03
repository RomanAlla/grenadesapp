package com.example.grenadesapp

import io.flutter.app.FlutterApplication
import com.google.android.gms.security.ProviderInstaller
import com.google.android.gms.common.GooglePlayServicesUtil
import com.google.android.gms.common.GooglePlayServicesNotAvailableException
import com.google.android.gms.common.GooglePlayServicesRepairableException

class MainApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        try {
            ProviderInstaller.installIfNeeded(this)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
} 