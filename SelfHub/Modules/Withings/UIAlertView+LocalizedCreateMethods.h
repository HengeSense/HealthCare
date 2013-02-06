//
//  UIAlertView+LocalizedCreateMethods.h
//  HealthCare
//
//  Created by Igor Barinov on 2/5/13.
//
//

#import <UIKit/UIKit.h>

@interface UIAlertView (LocalizedCreateMethods)

+(void) createAndShowSimpleAlertWithLocalizedTitle:(NSString*)title AndMessage:(NSString*) message;
+(void) createAndShowAlertViewWithTitle:(NSString*)title
                                message:(NSString*)message
                       titleOtherButton:(NSString*)titleOtherButton
                               delegate:(id)delegate
                                 andTag:(int) tag;
@end
