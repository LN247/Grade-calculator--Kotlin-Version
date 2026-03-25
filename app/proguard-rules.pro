# Keep Apache POI classes used for Excel parsing
-keep class org.apache.poi.** { *; }
-keep class org.openxmlformats.schemas.** { *; }
-dontwarn org.apache.poi.**
-dontwarn org.openxmlformats.**
-dontwarn com.microsoft.**

# Keep all Kotlin data classes (data models)
-keep class com.example.studentgradeapp.data.** { *; }
