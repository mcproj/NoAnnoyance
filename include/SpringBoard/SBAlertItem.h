#import <UIKit/UIKit.h>
#import <SpringBoard/_SBAlertController.h>

@interface SBAlertItem : NSObject

- (void)dismiss;
- (void)dismiss:(NSInteger)reason;
- (void)buttonDismissed;
- (UIAlertView *)alertSheet;
- (_SBAlertController *)alertController;

@end
