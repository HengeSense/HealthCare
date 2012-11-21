//
//  MainInformationUnits.h
//  SelfHub
//
//  Created by Mac on 16.11.12.
//
//

#import <UIKit/UIKit.h>
#import "MainInformation.h"
#import "MainInformationPickerSelector.h"

@class MainInformation;

typedef enum {
    MainInformationUnitsPickerTypeWeight = 0,
    MainInformationUnitsPickerTypeSize = 1
} MainInformationUnitPickerType;

@interface MainInformationUnits : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
    MainInformationPickerSelector *myPicker;
}

@property (nonatomic, assign) MainInformation *delegate;
@property (nonatomic, retain) IBOutlet UILabel *unitsLabel;
@property (nonatomic, retain) IBOutlet UILabel *weightLabel;
@property (nonatomic, retain) IBOutlet UILabel *weightValueLabel;
@property (nonatomic, retain) IBOutlet UILabel *sizeLabel;
@property (nonatomic, retain) IBOutlet UILabel *sizeValueLabel;

- (IBAction)changeWeightUnits:(id)selector;
- (IBAction)changeSizeUnits:(id)selector;

- (IBAction)weightUnitWasSelected:(MainInformationPickerSelector *)picker;
- (IBAction)sizeUnitWasSelected:(MainInformationPickerSelector *)picker;

- (NSUInteger)getWeightUnitNum;
- (NSString *)getWeightUnitStr:(NSUInteger)weightUnitIndex;
- (float)getWeightUnitKoef:(NSUInteger)weightUnitIndex;

- (NSUInteger)getSizeUnitNum;
- (NSString *)getSizeUnitStr:(NSUInteger)sizeUnitIndex;
- (float)getSizeUnitKoef:(NSUInteger)sizeUnitIndex;

@end
