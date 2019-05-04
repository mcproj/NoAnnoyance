#import <NoAnnoyance.h>
#import <CoreFoundation/CoreFoundation.h>
#import <SpringBoard/SBAlertItem.h>
#import <SpringBoard/SBAlertItemsController.h>
#import <SpringBoard/SBUserNotificationAlert.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBWorkspace.h>
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBSceneManager.h>
#import <SpringBoard/SBSceneManagerController.h>
#import <SpringBoard/FBSDisplay.h>
#import <SpringBoard/FBDisplayManager.h>
#import <SpringBoard/FBScene.h>
#import <SpringBoard/FBProcess.h>
#import <MobileGestalt/MobileGestalt.h>
#import <UIKit/UIKit.h>

@implementation NoAnnoyance {
    struct NoAnnoyanceSettings _settings;
}

+ (id)sharedInstance {
    static dispatch_once_t token = 0;
    __strong static id _sharedObject = nil;

    dispatch_once(&token, ^{
        _sharedObject = [[self alloc] init];
    });

    return _sharedObject;
}

- (id)init {
    if ((self = [super init])) {
        _strings = [[NSMutableDictionary alloc] init];

        _settings.GloballyEnabledInFullScreen = NO;
        _settings.GloballyEnabled = YES;

        _settings.SpringBoard.CellularDataIsTurnedOff = YES;
        _settings.SpringBoard.CellularDataIsTurnedOffFor = YES;
        _settings.SpringBoard.WifiIsTurnedOffFor = YES;
        _settings.SpringBoard.TurnOffAirplaneMode = YES;
        _settings.SpringBoard.ImproveLocationAccuracy = YES;
        _settings.SpringBoard.AccessoryUnreliable = NO;
        _settings.SpringBoard.LowBatteryDevice = YES;
        _settings.SpringBoard.LowBatteryAccessory = YES;
        _settings.SpringBoard.LowDiskSpace = YES;
        _settings.SpringBoard.AppUpdatedDot = NO;
        _settings.SpringBoard.TrustThisComputer = 0;

        _settings.GameCenter.Banner = YES;

        [self loadSettings];
    }

    return self;
}

+ (BOOL)canHook {
    return [[NoAnnoyance sharedInstance] canHook];
}

- (BOOL)canHook {
    SBSceneManager *sceneManager = [[%c(SBSceneManagerController) sharedInstance] sceneManagerForDisplay:[%c(FBDisplayManager) mainDisplay]];
    NSSet *scenes = [sceneManager externalForegroundApplicationScenes];
    FBScene *topScene = [scenes anyObject];
    NSString *topApplication = [[topScene clientProcess] bundleIdentifier];

    if (!topApplication)
        topApplication = [[NSBundle mainBundle] bundleIdentifier];

    if (!topApplication) {
        PNLog(@"canHook: %d", self.settings.GloballyEnabled);
        return self.settings.GloballyEnabled;
    }

    BOOL hook = self.settings.GloballyEnabled;
    BOOL hookInFS = self.settings.GloballyEnabledInFullScreen;

    // Check bundle againts our lists
    if (!hook) {
        hook = [self.enabledApps containsObject:[topApplication lowercaseString]];
    }

    SBApplication * runningApp = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:topApplication];

    if (runningApp && ![runningApp statusBarHiddenForCurrentOrientation]) {
        PNLog(@"canHook: %d", hook);
        return hook;
    } else if ([UIApplication sharedApplication] && ![[UIApplication sharedApplication] isStatusBarHidden]) {
        PNLog(@"canHook: %d", hook);
        return hook;
    }

    // Check bundle againts our lists
    if (!hookInFS) {
        hookInFS = [self.enabledAppsInFullscreen containsObject:[topApplication lowercaseString]];
    }

    PNLog(@"canHook: %d", hookInFS);

    return hookInFS;
}

- (void)loadSettings {
    if (!_enabledApps)
        _enabledApps = [[NSMutableArray alloc] init];
    if (!_enabledAppsInFullscreen)
        _enabledAppsInFullscreen = [[NSMutableArray alloc] init];
    [_enabledApps removeAllObjects];
    [_enabledAppsInFullscreen removeAllObjects];
    NSDictionary *_settingsPlist = [NSDictionary dictionaryWithContentsOfFile:settings_FILE];
    [_settingsPlist enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL * stop) {
        if (![key hasPrefix:@"EnabledApps-"] && ![key hasPrefix:@"EnabledAppsInFullscreen-"])
            return;
        if ([key hasPrefix:@"EnabledApps-"]) {
            if ([obj boolValue]) {
                [self.enabledApps addObject:[[key substringFromIndex:[@"EnabledApps-" length]] lowercaseString]];
            }
        }
        if ([key hasPrefix:@"EnabledAppsInFullscreen-"]) {
            if ([obj boolValue]) {
                [self.enabledAppsInFullscreen addObject:[[key substringFromIndex:[@"EnabledAppsInFullscreen-" length]] lowercaseString]];
            }
        }
    }];

    if ([_settingsPlist objectForKey:@"CELLULAR_DATA_IS_TURNED_OFF"])
        _settings.SpringBoard.CellularDataIsTurnedOff = [[_settingsPlist objectForKey:@"CELLULAR_DATA_IS_TURNED_OFF"] boolValue];
    if ([_settingsPlist objectForKey:@"CELLULAR_DATA_IS_TURNED_OFF_FOR"])
        _settings.SpringBoard.CellularDataIsTurnedOffFor = [[_settingsPlist objectForKey:@"CELLULAR_DATA_IS_TURNED_OFF_FOR"] boolValue];
    if ([_settingsPlist objectForKey:@"WIFI_IS_TURNED_OFF_FOR"])
        _settings.SpringBoard.WifiIsTurnedOffFor = [[_settingsPlist objectForKey:@"WIFI_IS_TURNED_OFF_FOR"] boolValue];
    if ([_settingsPlist objectForKey:@"TURN_OFF_AIRPLANE_MODE"])
        _settings.SpringBoard.TurnOffAirplaneMode = [[_settingsPlist objectForKey:@"TURN_OFF_AIRPLANE_MODE"] boolValue];
    if ([_settingsPlist objectForKey:@"IMPROVE_LOCATION_ACCURACY"])
        _settings.SpringBoard.ImproveLocationAccuracy = [[_settingsPlist objectForKey:@"IMPROVE_LOCATION_ACCURACY"] boolValue];
    if ([_settingsPlist objectForKey:@"ACCESSORY_UNRELIABLE"])
        _settings.SpringBoard.AccessoryUnreliable = [[_settingsPlist objectForKey:@"ACCESSORY_UNRELIABLE"] boolValue];
    if ([_settingsPlist objectForKey:@"LOW_BATTERY_DEVICE"])
        _settings.SpringBoard.LowBatteryDevice = [[_settingsPlist objectForKey:@"LOW_BATTERY_DEVICE"] boolValue];
    if ([_settingsPlist objectForKey:@"LOW_DISK_SPACE"])
        _settings.SpringBoard.LowDiskSpace = [[_settingsPlist objectForKey:@"LOW_DISK_SPACE"] boolValue];
    if ([_settingsPlist objectForKey:@"APP_UPDATED_DOT"])
        _settings.SpringBoard.AppUpdatedDot = [[_settingsPlist objectForKey:@"APP_UPDATED_DOT"] boolValue];
    if ([_settingsPlist objectForKey:@"TRUST_THIS_COMPUTER"])
        _settings.SpringBoard.TrustThisComputer = [[_settingsPlist objectForKey:@"TRUST_THIS_COMPUTER"] integerValue];
    if ([_settingsPlist objectForKey:@"GC_BANNER"])
        _settings.GameCenter.Banner = [[_settingsPlist objectForKey:@"GC_BANNER"] boolValue];
    if ([_settingsPlist objectForKey:@"GloballyEnabledInFullScreen"])
        _settings.GloballyEnabledInFullScreen = [[_settingsPlist objectForKey:@"GloballyEnabledInFullScreen"] boolValue];
    if ([_settingsPlist objectForKey:@"GloballyEnabled"])
        _settings.GloballyEnabled = [[_settingsPlist objectForKey:@"GloballyEnabled"] boolValue];
}

- (struct NoAnnoyanceSettings)settings {
    return _settings;
}

@end
