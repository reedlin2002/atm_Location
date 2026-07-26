import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties().apply {
    val localPropertiesFile = rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        localPropertiesFile.inputStream().use(::load)
    }
}

fun injectedValue(name: String): String? =
    providers.gradleProperty(name).orNull
        ?: System.getenv(name)?.takeIf { it.isNotBlank() }
        ?: localProperties.getProperty(name)?.takeIf { it.isNotBlank() }

val uploadKeystorePath = injectedValue("ATM_UPLOAD_KEYSTORE")
val uploadKeyAlias = injectedValue("ATM_UPLOAD_KEY_ALIAS")
val uploadStorePassword = injectedValue("ATM_UPLOAD_STORE_PASSWORD")
val uploadKeyPassword = injectedValue("ATM_UPLOAD_KEY_PASSWORD")
val signingValues = listOf(
    uploadKeystorePath,
    uploadKeyAlias,
    uploadStorePassword,
    uploadKeyPassword,
)
val releaseSigningAvailable = signingValues.all { !it.isNullOrBlank() }
if (signingValues.any { !it.isNullOrBlank() } && !releaseSigningAvailable) {
    throw GradleException("Release signing injection is incomplete")
}

android {
    namespace = "com.reedlin2002.atmfinder"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.reedlin2002.atmfinder"
        minSdk = 24
        // Google Play requires API 36 for new apps/updates from 2026-08-31.
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["MAPS_API_KEY"] =
            injectedValue("MAPS_API_KEY") ?: ""
    }

    signingConfigs {
        if (releaseSigningAvailable) {
            create("release") {
                storeFile = file(uploadKeystorePath!!)
                storePassword = uploadStorePassword
                keyAlias = uploadKeyAlias
                keyPassword = uploadKeyPassword
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
            if (releaseSigningAvailable) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
