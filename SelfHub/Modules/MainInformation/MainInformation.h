//
//  MainInformation.h
//  SelfHub
//
//  Created by Eugine Korobovsky on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModuleHelper.h"
#import <QuartzCore/CALayer.h>

@protocol ModuleProtocol;


@interface MainInformation : UIViewController <ModuleProtocol,  UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate>{
    int currentlySelectedViewController;
};

@property (nonatomic, assign) id <ServerProtocol> delegate;

@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet UIView *hostView;
@property (nonatomic, retain) IBOutlet UIView *moduleView;
@property (nonatomic, retain) IBOutlet UIView *slidingMenu;
@property (nonatomic, retain) IBOutlet UIImageView *slidingImageView;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView *dateSelector;
@property (nonatomic, retain) IBOutlet UIDatePicker *birthday;
@property (nonatomic, retain) NSDate *realBirthday;
@property (nonatomic, retain) NSMutableDictionary *moduleData;

- (void)fillAllFieldsLocalized;
- (NSString *)getBaseDir;
- (NSDate *)getDateFromString_ddMMyy:(NSString *)dateStr;
- (NSString *)getYearsWord:(NSUInteger)years padej:(BOOL)isRod;
- (NSUInteger)getAgeByBirthday:(NSDate *)brthdy;

//Данные вкладки
@property (nonatomic, retain) IBOutlet UIImageView *photo;

@property (nonatomic, retain) IBOutlet UITextField *surname;
@property (nonatomic, retain) IBOutlet UITextField *name;
@property (nonatomic, retain) IBOutlet UITextField *patronymic;

@property (nonatomic, retain) IBOutlet UISegmentedControl *sex;
@property (nonatomic, retain) IBOutlet UILabel *ageLabel;
@property (nonatomic, retain) IBOutlet UILabel *birthdayLabel;
@property (nonatomic, retain) IBOutlet UIButton *birthdaySelectButton;
@property (nonatomic, retain) IBOutlet UILabel *birthdayBarLabel;
@property (nonatomic, retain) IBOutlet UIButton *birthdaySelectionOkButton;
@property (nonatomic, retain) IBOutlet UIButton *birthdaySelectionCancelButton;

@property (nonatomic, retain) IBOutlet UILabel *lengthLabel;
@property (nonatomic, retain) IBOutlet UITextField *lengthTextField;
@property (nonatomic, retain) IBOutlet UIStepper *lengthStepper;
@property (nonatomic, retain) IBOutlet UILabel *lengthUnitLabel;

@property (nonatomic, retain) IBOutlet UILabel *weightLabel;
@property (nonatomic, retain) IBOutlet UITextField *weightTextField;
@property (nonatomic, retain) IBOutlet UIStepper *weightStepper;
@property (nonatomic, retain) IBOutlet UILabel *weightUnitLabel;

@property (nonatomic, retain) IBOutlet UILabel *spirometryLabel;
@property (nonatomic, retain) IBOutlet UITextField *spirometryTextField;
@property (nonatomic, retain) IBOutlet UILabel *spirometryUnitLabel;

@property (nonatomic, retain) IBOutlet UILabel *sizesLabel;

@property (nonatomic, retain) IBOutlet UILabel *thighLabel;
@property (nonatomic, retain) IBOutlet UITextField *thighTextField;
@property (nonatomic, retain) IBOutlet UIStepper *thighStepper;
@property (nonatomic, retain) IBOutlet UILabel *thighUnitLabel;

@property (nonatomic, retain) IBOutlet UILabel *waistLabel;
@property (nonatomic, retain) IBOutlet UITextField *waistTextField;
@property (nonatomic, retain) IBOutlet UIStepper *waistStepper;
@property (nonatomic, retain) IBOutlet UILabel *waistUnitLabel;

@property (nonatomic, retain) IBOutlet UILabel *chestLabel;
@property (nonatomic, retain) IBOutlet UITextField *chestTextField;
@property (nonatomic, retain) IBOutlet UIStepper *chestStepper;
@property (nonatomic, retain) IBOutlet UILabel *chestUnitLabel;


- (IBAction)showSlidingMenu:(id)sender;
- (IBAction)hideSlidingMenu:(id)sender;
- (IBAction)selectScreenFromMenu:(id)sender;
- (void)moveScreenshot:(UIPanGestureRecognizer *)gesture;
- (void)tapScreenshot:(UITapGestureRecognizer *)gesture;

        

- (IBAction)pressSelectPhoto:(id)sender;

- (IBAction)pressSelectBirthday:(id)sender;
- (IBAction)pressFinishSelectBirthday:(id)sender;

- (IBAction)valueLengthStepped:(id)sender;
- (IBAction)valueLengthFinishChanged:(id)sender;

- (IBAction)valueWeightStepped:(id)sender;
- (IBAction)valueWeightFinishChanged:(id)sender;

- (IBAction)valueThighStepped:(id)sender;
- (IBAction)valueThighFinishChanged:(id)sender;

- (IBAction)valueWaistStepped:(id)sender;
- (IBAction)valueWaistFinishChanged:(id)sender;

- (IBAction)valueChestStepped:(id)sender;
- (IBAction)valueChestFinishChanged:(id)sender;

- (IBAction)correctScrollBeforeEditing:(id)sender;
- (IBAction)hideKeyboard:(id)sender;



// Units view
@property (nonatomic, retain) IBOutlet UIView  *unitsView;
@property (nonatomic, retain) IBOutlet UILabel *unitsMainLabel;
@property (nonatomic, retain) IBOutlet UILabel *weightUnitSelectionLabel;
@property (nonatomic, retain) IBOutlet UILabel *weightUnitSelectionValueLabel;
@property (nonatomic, retain) IBOutlet UILabel *sizeUnitSelectionLabel;
@property (nonatomic, retain) IBOutlet UILabel *sizeUnitSelectionValueLabel;


- (IBAction)pressChangeWeightUnits:(id)sender;
- (IBAction)pressChangeSizeUnits:(id)sender;
- (void)recalcAllFieldsToCurrentlySelectedUnits;



- (void)convertSavedDataToViewFields;
- (void)convertViewFieldsToSavedData;






@end
