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

@interface Withings : UIViewController <ModuleProtocol>{
      NSMutableDictionary *moduleData;
      NSArray *viewControllers;
}

@property (nonatomic, assign) id <ServerProtocol> delegate;
- (void)fillAllFieldsLocalized;
@property (retain, nonatomic) IBOutlet UIView *moduleView;
@property (retain, nonatomic) IBOutlet UINavigationBar *navBar;
@property (retain, nonatomic) IBOutlet UIButton *rightBarBtn;
@property (retain, nonatomic) IBOutlet UIView *hostView;
@property (retain, nonatomic) IBOutlet UIView *slideView;
@property (retain, nonatomic) IBOutlet UIImageView *slideImageView;

//@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, retain) NSArray *viewControllers;

@end
