plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.fastshare.app"
    compileSdk = 36
    
    // الحل لخطأ الـ NDK الذي ظهر في GitHub Actions
    ndkVersion = "28.2.13676358"

    defaultConfig {
        applicationId = "com.fastshare.app"
        minSdk = 23
        targetSdk = 36
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // إضافة إعدادات التوقيع (Signing) هنا إذا كنت ستقوم برفع التطبيق للمتجر مستقبلاً
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("debug") 
        }
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.window:window:1.3.0") // تحديث بسيط للإصدار
    implementation("androidx.window:window-java:1.3.0")
}
