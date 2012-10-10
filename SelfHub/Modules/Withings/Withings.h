//
//  Withings.h
//  SelfHub
//
//  Created by Igor Barinov on 10/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModuleHelper.h"
#import "Htppnetwork.h"
#import <QuartzCore/QuartzCore.h>
#import "DataLoadWithingsViewController.h"
#import "Login.h"

@interface Withings : UIViewController <ModuleProtocol>{
      NSMutableDictionary *moduleData;
      NSArray *viewControllers;
      NSString *auth;
      NSString *authOfImport;
}

@property (nonatomic, assign) id <ServerProtocol> delegate;
@property (nonatomic, retain) NSArray *viewControllers;

@property (nonatomic, retain) NSString *auth;
@property (nonatomic, retain) NSString *authOfImport;

@property (retain, nonatomic) IBOutlet UIView *moduleView;
@property (retain, nonatomic) IBOutlet UINavigationBar *navBar;
@property (retain, nonatomic) IBOutlet UIButton *rightBarBtn;
@property (retain, nonatomic) IBOutlet UIView *hostView;
@property (retain, nonatomic) IBOutlet UIView *slideView;
@property (retain, nonatomic) IBOutlet UIImageView *slideImageView;

//@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;



//- (void)fillAllFieldsLocalized;

@end
