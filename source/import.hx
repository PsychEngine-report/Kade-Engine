import Paths;

#if sys
import funk.PsychFile as File;
import funk.PsychFileSystem as FileSystem;
#elseif js
import js.html.*;
#end
// Mobile Things
#if TOUCH_CONTROLS
import mobile.flixel.*;
import mobile.states.*;
import mobile.objects.*;
import mobile.options.*;
import mobile.backend.*;
import mobile.psychlua.*;
import mobile.substates.*;
import mobile.objects.Hitbox;
import mobile.objects.MobilePad;
import mobile.backend.MobileData;
#else
import mobile.backend.StorageUtil;
import mobile.backend.PsychJNI;
import mobile.options.*;
import mobile.backend.MobileScaleMode;
#end
// Android
#if android
import android.Tools as AndroidTools;
import android.Settings as AndroidSettings;
import android.widget.Toast as AndroidToast;
import android.content.Context as AndroidContext;
import android.Permissions as AndroidPermissions;
import android.os.Build.VERSION as AndroidVersion;
import android.os.Environment as AndroidEnvironment;
import android.os.BatteryManager as AndroidBatteryManager;
import android.os.Build.VERSION_CODES as AndroidVersionCode;
#end