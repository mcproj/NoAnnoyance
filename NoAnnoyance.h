#import <substrate.h>
#import <Logging.h>

#define settings_FILE @"/var/mobile/Library/Preferences/com.subdiox.noannoyance.plist"

struct NoAnnoyanceSettings {
    BOOL GloballyEnabledInFullScreen;
    BOOL GloballyEnabled;

    struct {
        BOOL NoSimCardInstalled;
        BOOL CellularDataIsTurnedOff;
        BOOL CellularDataIsTurnedOffFor;
        BOOL WifiIsTurnedOffFor;
        BOOL TurnOffAirplaneMode;
        BOOL ImproveLocationAccuracy;
        BOOL AccessoryUnreliable;
        BOOL LowBatteryDevice;
        BOOL LowBatteryAccessory;
        BOOL SoftwareUpdate;
        BOOL LowDiskSpace;
        NSUInteger TrustThisComputer;
    } SpringBoard;

    struct {
        BOOL Banner;
    } GameCenter;
};

@interface NoAnnoyance : NSObject

@property (nonatomic, readonly) NSMutableDictionary * strings;
@property (nonatomic, readonly) NSMutableArray * enabledApps;
@property (nonatomic, readonly) NSMutableArray * enabledAppsInFullscreen;

+ (instancetype)sharedInstance;
+ (BOOL)canHook;
- (void)loadSettings;
- (struct NoAnnoyanceSettings)settings;

@end
