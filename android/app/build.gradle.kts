import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") version "4.4.0" apply false
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
println("KeyStore Path: ${keystoreProperties["storeFile"]}")

android {
    namespace = "com.esx.app"
    compileSdk = 34
    ndkVersion = "27.2.12479018"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.esx.app"
        minSdk = 26
        targetSdk = 34
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String? ?: "defaultAlias"
            keyPassword = keystoreProperties["keyPassword"] as String? ?: "defaultPassword"
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) } ?: file("./upload-keystore.jks")
            storePassword = keystoreProperties["storePassword"] as String? ?: "defaultPassword"
        }
    }

    buildTypes {
        release {
            signingConfig = null
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
    implementation(platform("com.google.firebase:firebase-bom:32.7.1"))
    implementation("com.google.firebase:firebase-messaging")
    implementation("androidx.multidex:multidex:2.0.1")
}
