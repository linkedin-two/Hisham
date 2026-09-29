# Flutter ProGuard Rules for Release Build
# These rules prevent code obfuscation issues with network/HTTP libraries

# Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep this app's classes
-keep class com.edzkool.app.** { *; }

# Keep HTTP/Dart networking classes
-keep class com.google.gson.** { *; }
-keep class org.apache.http.** { *; }
-keep class org.apache.commons.codec.** { *; }
-keep class org.apache.commons.logging.** { *; }

# Keep SSL/TLS classes for HTTPS
-keep class javax.net.ssl.** { *; }
-keep class java.security.cert.** { *; }
-keep class java.security.** { *; }

# Keep HTTP client implementations
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Keep Dart/Flutter method channels
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.android.** { *; }

# Keep any custom exception classes
-keep class * extends java.lang.Exception { *; }

# ============================================================================
# KEEP DART/FLUTTER MODEL CLASSES (Critical for Release Build)
# ============================================================================
# Keep all classes with Model, Entity, or Data suffix
-keep class *Model { *; }
-keep class *Entity { *; }
-keep class *Data { *; }

# Keep all class members that are used for JSON serialization
-keepclassmembers class *Model {
    <fields>;
    <init>(...);
    *** fromJson(...);
    *** toJson(...);
}

-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep enums used for API responses
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Play Core (optional Flutter deferred components — not bundled in release APK)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

