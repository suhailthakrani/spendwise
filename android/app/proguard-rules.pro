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

# Firebase / Crashlytics
-keepattributes SourceFile,LineNumberTable,*Annotation*
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
