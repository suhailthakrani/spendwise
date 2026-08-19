# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# SQLCipher / sqlite3 (Drift encrypted store)
-keep class net.sqlcipher.** { *; }
-keep class org.sqlite.** { *; }
-dontwarn net.sqlcipher.**
-dontwarn org.sqlite.**

# Firebase / Crashlytics / Google Sign-In
-keepattributes SourceFile,LineNumberTable,*Annotation*
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class io.flutter.plugins.googlesignin.** { *; }
-keep class dev.flutter.pigeon.** { *; }
-dontwarn com.google.firebase.**
