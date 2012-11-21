//
//  MainInformation.h
//  SelfHub
//
//  Created by Eugine Korobovsky on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModuleHelper.h"
#import "MainInformationPacient.h"
#import "MainInformationUnits.h"
#import <QuartzCore/CALayer.h>

#define MIN_WEIGHT_KG 30.0
#define MAX_WEIGHT_KG 300.0

#define MIN_HEIGHT_CM 100.0
#define MAX_HEIGHT_CM 250.0

@protocol ModuleProtocol;

@class MainInformationPacient;
@class MainInformationUnits;


@interface MainInformation : UIViewController <ModuleProtocol>{
    int currentlySelectedViewController;
};

@property (nonatomic, assign) id <ServerProtocol> delegate;
@property (nonatomic, retain) NSMutableArray *modulePagesArray;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet UIView *hostView;
@property (nonatomic, retain) IBOutlet UIView *moduleView;
@property (nonatomic, retain) IBOutlet UIView *slidingMenu;
@property (nonatomic, retain) IBOutlet UIImageView *slidingImageView;

@property (nonatomic, retain) NSMutableDictionary *moduleData;

- (NSString *)getBaseDir;
- (NSDate *)getDateFromString_ddMMyy:(NSString *)dateStr;
- (NSString *)getYearsWord:(NSUInteger)years padej:(BOOL)isRod;
- (NSUInteger)getAgeByBirthday:(NSDate *)brthdy;


- (IBAction)showSlidingMenu:(id)sender;
- (IBAction)hideSlidingMenu:(id)sender;
- (IBAction)selectScreenFromMenu:(id)sender;
- (void)moveScreenshot:(UIPanGestureRecognizer *)gesture;
- (void)tapScreenshot:(UITapGestureRecognizer *)gesture;

- (void)recalcAllFieldsToCurrentlySelectedUnits;

- (NSString *)getWeightUnit;
- (float)getWeightFactor;         // 1 unit = factor * base_unit
- (NSString *)getSizeUnit;
- (float)getSizeFactor;




//- (void)convertSavedDataToViewFields;
//- (void)convertViewFieldsToSavedData;






@end
