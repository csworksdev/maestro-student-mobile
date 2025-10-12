# Keep Firebase Messaging classes
-keep class com.google.firebase.** { *; }
-keep class io.flutter.plugins.firebase.** { *; }
-keep class io.flutter.plugins.firebasemessaging.** { *; }

# Keep FCM classes
-keep class com.google.firebase.messaging.** { *; }

# Keep classes that are accessed via reflection
-keep public class com.google.android.gms.common.internal.safeparcel.SafeParcelable {
    public static final *** NULL;
}

# Keep methods that are accessed via reflection
-keepclassmembers class * implements android.os.Parcelable {
    public static final *** CREATOR;
}

# Keep Notification related classes
-keep class androidx.core.app.NotificationCompat { *; }
-keep class androidx.core.app.NotificationManagerCompat { *; }
-keep class androidx.core.app.NotificationChannelCompat { *; }

# Keep required classes for notification in release mode
-keep class * extends androidx.core.app.NotificationCompat$Style { *; }
-keep class * extends androidx.core.app.NotificationCompat$Action { *; }

# Keep Serializable objects
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}