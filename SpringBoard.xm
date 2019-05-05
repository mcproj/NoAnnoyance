#import <NoAnnoyance.h>

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

%group SB

%hook SBAlertItemsController

static inline void discardAlertItem(SBAlertItemsController *controller, SBAlertItem *alert) {
    if ([alert isKindOfClass:[%c(SBUserNotificationAlert) class]]) {
        SBUserNotificationAlert *unAlert = (SBUserNotificationAlert *)alert;
        if ([[unAlert alertHeader] isEqualToString:[NoAnnoyance sharedInstance].strings[@"SpringBoard.TrustThisComputer"]]) {
            int response = ([NoAnnoyance sharedInstance].settings.SpringBoard.TrustThisComputer == 2);
            [unAlert _setActivated:NO];
            if ([unAlert respondsToSelector:@selector(_sendResponseAndCleanUp:)]) { // for iOS 9.3.3 or above
                [unAlert _sendResponseAndCleanUp:response];
            } else {
                [unAlert _sendResponse:response];
                [unAlert _cleanup];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SBUserNotificationDoneNotification" object:unAlert];
        } else {
            [controller deactivateAlertItem:unAlert];
            [unAlert cancel];
        }
    } else {
        [controller deactivateAlertItem:alert];
    }
}

- (void)activateAlertItem:(SBAlertItem *)alert {
    PNLog(@"%@", alert);

    // NoSimCardInstalled: iOS 3 ~ 11
    if ([alert isKindOfClass:[%c(SBSIMLockAlertItem) class]] && [NoAnnoyance sharedInstance].settings.SpringBoard.NoSimCardInstalled) {
        discardAlertItem(self, alert);
        return;
    }

    // CellularDataIsTurnedOff: iOS 3 ~ 7
    if ([alert isKindOfClass:[%c(SBEdgeActivationAlertItem) class]] && [NoAnnoyance sharedInstance].settings.SpringBoard.CellularDataIsTurnedOff) {
        discardAlertItem(self, alert);
        return;
    }

    // TurnOffAirplaneMode: iOS 3 ~ 10
    if ([alert isKindOfClass:[%c(SBLaunchAlertItem) class]]) {
        int _type = MSHookIvar<int>(alert, "_type");
        BOOL _isDataAlert = MSHookIvar<BOOL>(alert, "_isDataAlert");

        if (_type == 1) {
            if (_isDataAlert && [NoAnnoyance sharedInstance].settings.SpringBoard.TurnOffAirplaneMode) {
                discardAlertItem(self, alert);
                return;
            }
        }
    }
    
    // TurnOffAirplaneMode: iOS 11 ~ 12
    if ([alert isKindOfClass:[%c(SBApplicationLaunchNotifyAirplaneModeAlertItem) class]] && [NoAnnoyance sharedInstance].settings.SpringBoard.TurnOffAirplaneMode) {
        discardAlertItem(self, alert);
        return;
    }

    // LowBatteryDevice: iOS 3 ~ 12
    if ([alert isKindOfClass:[%c(SBLowPowerAlertItem) class]] && [NoAnnoyance sharedInstance].settings.SpringBoard.LowBatteryDevice) {
        discardAlertItem(self, alert);
        return;
    }

    // LowBatteryAccessory: iOS 9.3.3 ~ 12
    if ([alert isKindOfClass:[%c(SBBluetoothAccessoryLowPowerAlertItem) class]] && [NoAnnoyance sharedInstance].settings.SpringBoard.LowBatteryAccessory) {
        discardAlertItem(self, alert);
        return;
    }

    // SoftwareUpdate: iOS 3 ~ 10
    if ([alert isKindOfClass:[%c(SBSoftwareUpdateAvailableAlertItem) class]] && [NoAnnoyance sharedInstance].settings.SpringBoard.SoftwareUpdate) {
        discardAlertItem(self, alert);
        return;
    }

    // LowDiskSpace: iOS 3 ~ 10
    if ([alert isKindOfClass:[%c(SBDiskSpaceAlertItem) class]] && [NoAnnoyance sharedInstance].settings.SpringBoard.LowDiskSpace) {
        discardAlertItem(self, alert);
        return;
    }

    // Others: iOS 3 ~ 12
    if ([alert isKindOfClass:[%c(SBUserNotificationAlert) class]]) {
        PNLog(@"SBUserNotificationAlert %@, %@", [(SBUserNotificationAlert *)alert alertMessage], [(SBUserNotificationAlert *)alert alertHeader]);
        PNLog(@"%@", [NoAnnoyance sharedInstance].strings);
        SBUserNotificationAlert *unAlert = (SBUserNotificationAlert *)alert;
        if (([[unAlert alertHeader] isEqualToString:[NoAnnoyance sharedInstance].strings[@"SpringBoard.NoSimCardInstalled"]] && [NoAnnoyance sharedInstance].settings.SpringBoard.NoSimCardInstalled) ||
            ([[unAlert alertHeader] isEqualToString:[NoAnnoyance sharedInstance].strings[@"SpringBoard.CellularDataIsTurnedOff"]] && [NoAnnoyance sharedInstance].settings.SpringBoard.CellularDataIsTurnedOff) ||
            ([[unAlert alertHeader] isEqualToString:[NoAnnoyance sharedInstance].strings[@"SpringBoard.CellularDataIsTurnedOffFor"]] && [NoAnnoyance sharedInstance].settings.SpringBoard.CellularDataIsTurnedOffFor) ||
            ([[unAlert alertHeader] isEqualToString:[NoAnnoyance sharedInstance].strings[@"SpringBoard.WifiIsTurnedOffFor"]] && [NoAnnoyance sharedInstance].settings.SpringBoard.WifiIsTurnedOffFor) ||
            ([[unAlert alertMessage] isEqualToString:[NoAnnoyance sharedInstance].strings[@"SpringBoard.ImproveLocationAccuracy"]] && [NoAnnoyance sharedInstance].settings.SpringBoard.ImproveLocationAccuracy) ||
            ([[unAlert alertHeader] isEqualToString:[NoAnnoyance sharedInstance].strings[@"SpringBoard.AccessoryUnreliable"]] && [NoAnnoyance sharedInstance].settings.SpringBoard.AccessoryUnreliable) ||
            ([[unAlert alertHeader] isEqualToString:[NoAnnoyance sharedInstance].strings[@"SpringBoard.SoftwareUpdate"]] && [NoAnnoyance sharedInstance].settings.SpringBoard.SoftwareUpdate) ||
            ([[unAlert alertHeader] isEqualToString:[NoAnnoyance sharedInstance].strings[@"SpringBoard.TrustThisComputer"]] && [NoAnnoyance sharedInstance].settings.SpringBoard.TrustThisComputer)) {

            discardAlertItem(self, alert);
            return;
        }

    }

    // Other Notifications
    %orig;
}

%end

%end

static void loadSpringBoardStrings() {
    // load NO_SIM_CARD_INSTALLED string from its bundle
    NSBundle *coreTelephonyBundle = [[NSBundle alloc] initWithPath:@"/System/Library/Frameworks/CoreTelephony.framework"];
    if (coreTelephonyBundle) {
        [NoAnnoyance sharedInstance].strings[@"SpringBoard.NoSimCardInstalled"] = [coreTelephonyBundle localizedStringForKey:@"NO_SIM_CARD_INSTALLED" value:@"" table:@"CBMessage"];
    }

    // load SOFTWARE_UPDATE string from its bundle
    NSBundle *softwareUpdateServicesBundle = [[NSBundle alloc] initWithPath:@"/System/Library/PrivateFrameworks/SoftwareUpdateServices.framework"];
    if (softwareUpdateServicesBundle) {
        [NoAnnoyance sharedInstance].strings[@"SpringBoard.SoftwareUpdate"] = [softwareUpdateServicesBundle localizedStringForKey:@"SOFTWARE_UPDATE" value:@"" table:@"SoftwareUpdateServices"];
    }

    // load IMPROVE_LOCATION_ACCURACY_WIFI string from its bundle
    NSBundle *coreLocationBundle = [[NSBundle alloc] initWithPath:@"/System/Library/Frameworks/CoreLocation.framework"];
    if (coreLocationBundle) {
        [NoAnnoyance sharedInstance].strings[@"SpringBoard.ImproveLocationAccuracy"] = [coreLocationBundle localizedStringForKey:@"IMPROVE_LOCATION_ACCURACY_WIFI" value:@"" table:@"locationd"];
    }

    // load YOU_CAN_TURN_ON_CELLULAR_DATA_FOR_THIS_APP_IN_settings string from its bundle
    NSError *error = nil;
    NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/System/Library/Carrier Bundles" error:&error];
    NSBundle *carrierBundle = nil;
    if (!error) {
        for (NSString *file in directoryContents) {
            NSString *path = [@"/System/Library/Carrier Bundles" stringByAppendingPathComponent:file];
            BOOL isDirectory = NO;
            if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
                carrierBundle = [[NSBundle alloc] initWithPath:[NSString stringWithFormat:@"%@/Default.bundle", path]];
                break;
            }
        }
        if (carrierBundle) {
            [NoAnnoyance sharedInstance].strings[@"SpringBoard.CellularDataIsTurnedOffFor"] = [carrierBundle localizedStringForKey:@"YOU_CAN_TURN_ON_CELLULAR_DATA_FOR_THIS_APP_IN_SETTINGS" value:@"" table:@"DataUsage"];
            [NoAnnoyance sharedInstance].strings[@"SpringBoard.WifiIsTurnedOffFor"] = [carrierBundle localizedStringForKey:@"YOU_CAN_TURN_ON_WIFI_DATA_FOR_THIS_APP_IN_SETTINGS" value:@"" table:@"DataUsage"];
            [NoAnnoyance sharedInstance].strings[@"SpringBoard.CellularDataIsTurnedOff"] = [carrierBundle localizedStringForKey:@"EDGE_OFF_FAILURE_TITLE" value:@"" table:@"AlertDialog"];
        }
    }

    // load ACCESSORY_UNRELIABLE string from its bundle
    NSBundle * IAPBundle = [NSBundle bundleWithIdentifier:@"com.apple.IAP"];
    if (IAPBundle) {
        NSString * sDeviceClass = (__bridge NSString *)MGCopyAnswer(kMGDeviceClass);
        NSMutableString * keyName = [NSMutableString stringWithString:@"ACCESSORY_UNRELIABLE"];

        if ([sDeviceClass isEqualToString:@"iPhone"]) {
            [keyName appendString:@"_IPHONE"];
        } else if ([sDeviceClass isEqualToString:@"iPad"]) {
            [keyName appendString:@"_IPAD"];
        } else {
            [keyName appendString:@"_IPOD"];
        }

        [NoAnnoyance sharedInstance].strings[@"SpringBoard.AccessoryUnreliable"] = [IAPBundle localizedStringForKey:keyName value:@"" table:@"Framework"];
    }

    // load TRUST_DIALOG_HEADER string from its bundle
    NSBundle * LockdownLocalizationBundle = [[NSBundle alloc] initWithPath:@"/System/Library/Lockdown/Localization.bundle"];
    if (LockdownLocalizationBundle) {
        [NoAnnoyance sharedInstance].strings[@"SpringBoard.TrustThisComputer"] = [LockdownLocalizationBundle localizedStringForKey:@"TRUST_DIALOG_HEADER" value:@"" table:@"Pairing"];
    }
}

%ctor {
    @autoreleasepool {
        NSString * bundleId = [[NSBundle mainBundle] bundleIdentifier];
        if ([bundleId caseInsensitiveCompare:@"com.apple.springboard"] == NSOrderedSame) {
            %init(SB);
            loadSpringBoardStrings();
        }
    }
}
