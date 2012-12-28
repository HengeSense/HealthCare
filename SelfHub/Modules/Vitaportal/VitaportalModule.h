//
//  ExampleModule.h
//  SelfHub
//
//  Created by Eugine Korobovsky on 24.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// *******************************************************************************************************************
// THERE ARE MAIN STEPS FOR CREATING NEW MODULE
// 1. Create subdirectory in SelfHub/Modules for new module
// 2. Add this directory in project and create new view controller inherited from UIViewController
// 3. New view controller should accept protocol "ModuleProtocol" and implement all required functions
// 4. New view controller should have delegate for main part of application
// 5. New view controller should have navigation bar (through using UINavigationController, either through single native element UINavigationBar)
// 6. Navigation controller should have module name as a title and left-button (DesktopSlideLeftNavBarButton.png) for slide-out main menu
// 7. Exept for navigation bar you can operate with new view controller as you want
// 8. Add new icon to module's directory (recommended 50x50 or 100x100 for retina displays)
// 9. Create export-list for your new module (example.export.plist)
// 10. Include new record in file AllModules.plist for your module
// *******************************************************************************************************************


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
// ModuleHelper.h describes protocol "ModuleProtocol" for each module.
// This protocol includes functions, called by main part of application.
// Every module should implement required functions from "ModuleProtocol".
#import "ModuleHelper.h"

@protocol ModuleProtocol;

// This is example of single-view module. Navigation isn't implemented here.
// If you want to release UINavigationController-based module, you can use
// UINavigationController instead.
@interface VitaportalModule : UIViewController <ModuleProtocol, UITableViewDataSource, UITableViewDelegate> {
    // This dictionary contain module data. It's necessary because interface's elements are not
    // initialized when main part of application call [module loadModuleData] for the first time.
    // It's recommended to read and save data through similar structure
    UIImage *tutorialBackgroundImageV;
    NSMutableDictionary *moduleData;
}

// Delegate of main part of application. You can call functions of "ServerProtocol"
// inside module. For example, you can exchange some data with other modules through
// this delegate.
@property (nonatomic, assign) id <ServerProtocol> delegate;


// Decorative navigation bar, that include module name and menu button
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;


@property (retain, nonatomic) IBOutlet UIView *moduleView;

// View in module's view controller, when you can do what you want (main module's screen)
@property (nonatomic, retain) IBOutlet UIView *hostView;
@property (retain, nonatomic) IBOutlet UITableView *rightSlideBarTable;

@property (retain, nonatomic) IBOutlet UIView *slidingMenu;
@property (retain, nonatomic) IBOutlet UIImageView *slidingImageView;
@property (retain, nonatomic) IBOutlet UIImageView *backImView;
@property (nonatomic, retain) UIButton *tutorialButton;
// Auxiliary function. Return your document's path (when module's data saved)
- (NSString *)getBaseDir;

// DidEndOnExit handler for myTextField
- (IBAction)hideKeyboard:(id)sender;

@end
