# Flutter's Gradle plugin already applies proguard-android-optimize.txt
# and flutter_proguard_rules.pro. R8 full mode is the AGP 8+ default.
# Keep this file narrow. Blanket keeps on io.flutter, Firebase, or Play
# services block the shrinking and obfuscation Play measures.

-keepattributes SourceFile,LineNumberTable

# SQLCipher / sqlite3 JNI entry points.
-keep class net.sqlcipher.** { *; }
-keep class org.sqlite.** { *; }
-dontwarn net.sqlcipher.**
-dontwarn org.sqlite.**
