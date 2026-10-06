plugins {

    id("com.android.application")

    id("kotlin-android")

    id("dev.flutter.flutter-gradle-plugin")

}



import java.util.Properties

import java.io.FileInputStream



val keystorePropertiesFile = rootProject.file("key.properties")

val keystoreProperties = Properties()

if (keystorePropertiesFile.exists()) {

    keystoreProperties.load(FileInputStream(keystorePropertiesFile))

}



android {

    namespace = "com.edzkool.app"

    compileSdk = 36

    ndkVersion = flutter.ndkVersion



    compileOptions {

        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_17

        targetCompatibility = JavaVersion.VERSION_17

    }



    kotlinOptions {

        jvmTarget = JavaVersion.VERSION_17.toString()

    }



    signingConfigs {

        create("release") {

            if (keystorePropertiesFile.exists()) {

                keyAlias = keystoreProperties["keyAlias"] as String

                keyPassword = keystoreProperties["keyPassword"] as String

                val rawStoreFile = keystoreProperties["storeFile"] as String

                val rootRelative = rootProject.file(rawStoreFile)

                storeFile = if (rootRelative.exists()) rootRelative else file(rawStoreFile)

                storePassword = keystoreProperties["storePassword"] as String

            }

        }

    }



    defaultConfig {

        applicationId = "com.edzkool.app"

        minSdk = flutter.minSdkVersion

        targetSdk = 36

        versionCode = flutter.versionCode

        versionName = flutter.versionName

    }



    buildTypes {

        release {

            signingConfig = if (keystorePropertiesFile.exists()) {

                signingConfigs.getByName("release")

            } else {

                signingConfigs.getByName("debug")

            }

            isMinifyEnabled = true

            isShrinkResources = true

            proguardFiles(

                getDefaultProguardFile("proguard-android-optimize.txt"),

                "proguard-rules.pro"

            )

        }

    }

}



flutter {

    source = "../.."

}



dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

