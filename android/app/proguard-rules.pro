# Keep llama_flutter_android classes and members
-keep class com.write4me.llama_flutter_android.** { *; }
-keepclassmembers class com.write4me.llama_flutter_android.** { *; }

# Keep Kotlin metadata (often needed for reflection/JNI)
-keep class kotlin.Metadata { *; }

# Keep Kotlin function interfaces (crucial for JNI callbacks)
-keep interface kotlin.jvm.functions.** { *; }
-keep class kotlin.jvm.functions.** { *; }
