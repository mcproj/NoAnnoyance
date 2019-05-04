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

static void reloadSettingsNotification(CFNotificationCenterRef notificationCenterRef, void * arg1, CFStringRef arg2, const void * arg3, CFDictionaryRef dictionary) {
    [[NoAnnoyance sharedInstance] loadSettings];
}

%group GameCenter

%hook GKNotificationBannerWindow

// iOS 5 ~ 8
- (void)_showBanner:(id)banner showDimmingView:(BOOL)showDimmingView {
    PNLog(@"%d", [NoAnnoyance sharedInstance].settings.GameCenter.Banner);

    if (![NoAnnoyance canHook] || ![NoAnnoyance sharedInstance].settings.GameCenter.Banner) {
        %orig;
        return;
    }
}

// iOS 9 ~ 12
- (void)_showBanner:(id)banner {
    PNLog(@"%d", [NoAnnoyance sharedInstance].settings.GameCenter.Banner);

    if (![NoAnnoyance canHook] || ![NoAnnoyance sharedInstance].settings.GameCenter.Banner) {
        %orig;
        return;
    }
}

%end

%end

%ctor {
    @autoreleasepool {
        NSString * bundleId = [[NSBundle mainBundle] bundleIdentifier];
        PNLog(@"Running in %@", bundleId);

        %init(GameCenter);

        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadSettingsNotification, CFSTR("com.subdiox.noannoyance/settingsupdated"), NULL, CFNotificationSuspensionBehaviorCoalesce);
        [[NoAnnoyance sharedInstance] loadSettings];
    }
}
