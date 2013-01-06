//
//  MainInformationPickerSelector.h
//  SelfHub
//
//  Created by Eugine Korobovsky on 16.11.12.
//
//

#import <UIKit/UIKit.h>

@interface MainInformationPickerSelector : UIViewController {
    BOOL isSelectorWorkedNow;
};

@property (nonatomic, retain) IBOutlet UIPickerView *myPicker;
@property (nonatomic, retain) IBOutlet UIDatePicker *myDatePicker;

@property (nonatomic, retain) IBOutlet UIImageView *barImageView;
@property (nonatomic, retain) IBOutlet UILabel *pickerTitle;
@property (nonatomic, retain) IBOutlet UIButton *okButton;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;

@property (nonatomic, readonly) BOOL isDatePicker;
@property (nonatomic) BOOL isRejectViewAfterOutOfBoundsTouch;

@property (nonatomic, assign) id delegate;
@property (nonatomic) SEL okSelector;
@property (nonatomic) SEL cancelSelector;


- (id)initDatePickerWithDelegate:(id)pickerDelegate andOkSelector:(SEL)okSel andCancelSelector:(SEL)cancelSel;
- (id)initSimplePickerWithDelegate:(id)pickerDelegate andOkSelector:(SEL)okSel andCancelSelector:(SEL)cancelSel;

- (void)setSimplePickerDelegate:(id<UIPickerViewDataSource, UIPickerViewDelegate>)pickerDelegate;
- (void)setDateForDatePicker:(NSDate *)_date;
- (NSDate *)getDateFromDatePicker;

- (void)showPickerInView:(UIView *)superViewForPicker;
- (void)hidePicker;
- (BOOL)isSelectorInWork;

- (IBAction)pressOkButton:(id)sender;
- (IBAction)pressCancelButton:(id)sender;
- (IBAction)pressPickerOutObBounds:(id)sender;

- (void)loadLocalizedStrings;


@end
