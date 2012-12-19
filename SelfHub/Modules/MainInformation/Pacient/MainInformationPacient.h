//
//  MainInformationPacient.h
//  SelfHub
//
//  Created by Mac on 16.11.12.
//
//

#import <UIKit/UIKit.h>
#import "MainInformation.h"
#import "MainInformationPickerSelector.h"
#import "MainInformationUnits.h"
#import "MainInformationStepper.h"

@class MainInformation;

typedef enum {
	MainInformationPacientPickerTypeSex = 0,
    MainInformationPacientPickerTypeHeight = 1,
    MainInformationPacientPickerTypeWeight = 2
} MainInformationPacientPickerType;

@interface MainInformationPacient : UIViewController <UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate> {
    
    MainInformationPickerSelector *myPicker;
    
    float curSelectedWeightKg;
    float curSelectedHeightCm;
};

@property (nonatomic, assign) MainInformation   *delegate;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageView;


// Private info (photo, sex, age, names)
@property (nonatomic, retain) IBOutlet UILabel *block1Label;
@property (nonatomic, retain) IBOutlet UIImageView *photo;
@property (nonatomic, retain) IBOutlet UILabel *sexLabel;
@property (nonatomic, retain) IBOutlet UILabel *sexValueLabel;
@property (nonatomic, retain) IBOutlet UILabel *ageLabel;
@property (nonatomic, retain) IBOutlet UILabel *ageValueLabel;
@property (nonatomic, retain) IBOutlet UITextField *surname;
@property (nonatomic, retain) IBOutlet UITextField *name;
@property (nonatomic, retain) IBOutlet UITextField *patronymic;

// Height & Weight
@property (nonatomic, retain) IBOutlet UILabel *block2Label;
@property (nonatomic, retain) IBOutlet UILabel *heightLabel;
@property (nonatomic, retain) IBOutlet UILabel *heightValueLabel;
@property (nonatomic, retain) IBOutlet MainInformationStepper *heightStepper;
@property (nonatomic, retain) IBOutlet UILabel *weightLabel;
@property (nonatomic, retain) IBOutlet UILabel *weightValueLabel;
@property (nonatomic, retain) IBOutlet MainInformationStepper *weightStepper;

// Additional info
@property (nonatomic, retain) IBOutlet UILabel *block3Label;
@property (nonatomic, retain) IBOutlet UITextView *additionalInfo;

- (IBAction)pressSelectPhoto:(id)sender;
- (IBAction)pressSelectSex:(id)sender;
- (IBAction)pressSelectBirthday:(id)sender;
- (IBAction)pressSelectHeight:(id)sender;
- (IBAction)pressSelectWeight:(id)sender;

- (IBAction)sexWasSelected:(MainInformationPickerSelector *)picker;
- (IBAction)birthdayWasSelected:(MainInformationPickerSelector *)picker;
- (IBAction)heightWasSelected:(MainInformationPickerSelector *)picker;
- (IBAction)weightWasSelected:(MainInformationPickerSelector *)picker;

- (IBAction)valueHeightStepped:(id)sender;
- (IBAction)valueWeightStepped:(id)sender;

- (IBAction)textFieldDidBeginEditing:(id)sender;
- (IBAction)hideKeyboard:(id)sender;
- (IBAction)saveStrings:(id)sender;

- (float)roundFloat:(float)num forStep:(float)step;

@end
