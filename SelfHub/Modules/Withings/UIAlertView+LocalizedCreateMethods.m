//
//  UIAlertView+LocalizedCreateMethods.m
//  HealthCare
//
//  Created by Igor Barinov on 2/5/13.
//
//

#import "UIAlertView+LocalizedCreateMethods.h"

@implementation UIAlertView (LocalizedCreateMethods)

+ (void) createAndShowSimpleAlertWithLocalizedTitle:(NSString*)title AndMessage:(NSString*) message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(title,@"")
                                                    message:NSLocalizedString(message, @"")
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

+(void) createAndShowAlertViewWithTitle:(NSString *)title message:(NSString *)message titleOtherButton:(NSString *)titleOtherButton delegate:(id)delegate andTag:(int)tag
{
    UIAlertView *alertErrorGetData = [[UIAlertView alloc] initWithTitle:NSLocalizedString(title,@"")
                                                                message:NSLocalizedString(message,@"")
                                                               delegate: delegate
                                                      cancelButtonTitle: NSLocalizedString(@"Cancel",@"")
                                                      otherButtonTitles: NSLocalizedString(titleOtherButton,@""), nil];
    [alertErrorGetData setTag:tag];
    [alertErrorGetData show];
    [alertErrorGetData release];
}

@end
