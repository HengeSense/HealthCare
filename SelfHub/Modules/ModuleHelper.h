//
//  ModuleHelper.h
//  SelfHub
//
//  Created by Eugine Korobovsky on 23.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


// Protocol for Desktop View Controller
@protocol ServerProtocol
@required
- (BOOL)isModuleAvailableWithID:(NSString *)moduleID;
- (id)getValueForName:(NSString *)name fromModuleWithID:(NSString *)moduleID;
- (BOOL)setValue:(id)value forName:(NSString *)name forModuleWithID:(NSString *)moduleID;
- (UIViewController *)getViewControllerForModuleWithID:(NSString *)moduleID;
- (void)showSlideMenu;
- (void)hideSlideMenu;
- (void)switchToModuleWithID:(NSString *)moduleID;
- (void)showTutorial:(UIView *)moduleTutorialView;
- (BOOL)isRetina4;
@end

// Protocol, that should be supperted by all of modules
@protocol ModuleProtocol
@required
- (id)initModuleWithDelegate:(id<ServerProtocol>)serverDelegate;
- (NSString *)getModuleName;
- (NSString *)getModuleDescription;
- (NSString *)getModuleMessage;
- (float)getModuleVersion;
- (UIImage *)getModuleIcon;
- (BOOL)isInterfaceIdiomSupportedByModule:(UIUserInterfaceIdiom)idiom;
- (void)loadModuleData;
- (void)saveModuleData;

- (IBAction)pressMainMenuButton;

- (id)getModuleValueForKey:(NSString *)key;
- (void)setModuleValue:(id)object forKey:(NSString *)key;
@optional
- (void)didReceivedMemoryWarning;
- (UIImage *)correctScreenshot:(UIImage *)screenshotImage;
- (void)receiveRemoteNotification:(NSDictionary*) userInfo;

@end

//Common help tasks

@interface ModuleHelper : NSObject {

}

+ (ModuleHelper *)sharedHelper;

- (BOOL)testExchangeListForModuleWithID:(NSString *)moduleID;

@end


// Button that highlights all UILabel's subviews, when it pressed
// Used as simple button, but it helps to localize text resources
@interface ButtonWithLabel : UIButton {
    
}

@end


