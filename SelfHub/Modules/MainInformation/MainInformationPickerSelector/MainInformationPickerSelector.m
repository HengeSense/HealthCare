//
//  MainInformationPickerSelector.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 16.11.12.
//
//

#import "MainInformationPickerSelector.h"

@interface MainInformationPickerSelector ()

@end

@implementation MainInformationPickerSelector

@synthesize myPicker, myDatePicker;
@synthesize barImageView, pickerTitle, okButton, cancelButton;
@synthesize isDatePicker, isRejectViewAfterOutOfBoundsTouch;
@synthesize delegate, okSelector, cancelSelector;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isRejectViewAfterOutOfBoundsTouch = YES;
        isSelectorWorkedNow = NO;
    };
    return self;
};


- (id)initDatePickerWithDelegate:(id)pickerDelegate andOkSelector:(SEL)okSel andCancelSelector:(SEL)cancelSel{
    self = [self initWithNibName:@"MainInformationPickerSelector" bundle:nil];
    if(self){
        isDatePicker = YES;
        delegate = pickerDelegate;
        okSelector = okSel;
        cancelSelector = cancelSel;
    };
    
    return self;
};
- (id)initSimplePickerWithDelegate:(id)pickerDelegate andOkSelector:(SEL)okSel andCancelSelector:(SEL)cancelSel{
    self = [self initWithNibName:@"MainInformationPickerSelector" bundle:nil];
    if(self){
        isDatePicker = NO;
        delegate = pickerDelegate;
        okSelector = okSel;
        cancelSelector = cancelSel;
    };
    
    return self;
};


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
};

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
};

- (void)dealloc{
    [myPicker release];
    [myDatePicker release];
    [barImageView release];
    [pickerTitle release];
    [okButton release];
    [cancelButton release];
    
    [super dealloc];
};

- (void)setSimplePickerDelegate:(id<UIPickerViewDataSource, UIPickerViewDelegate>)pickerDelegate{
    if(!isDatePicker){
        myPicker.dataSource = pickerDelegate;
        myPicker.delegate = pickerDelegate;
    };
};

- (void)setDateForDatePicker:(NSDate *)_date{
    if(isDatePicker){
        myDatePicker.date = _date;
    };
};

- (NSDate *)getDateFromDatePicker{
    if(isDatePicker){
        return myDatePicker.date;
    };
    
    return nil;
};

- (void)showPickerInView:(UIView *)superViewForPicker{
    [self loadLocalizedStrings];
    isSelectorWorkedNow = YES;
    [myPicker setHidden:(isDatePicker ? YES : NO)];
    [myDatePicker setHidden:(isDatePicker ? NO : YES)];
    
    self.view.frame = CGRectMake(0.0, superViewForPicker.bounds.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [superViewForPicker addSubview:self.view];
    CGPoint center = CGPointMake(superViewForPicker.bounds.size.width/2.0, superViewForPicker.bounds.size.height + self.view.frame.size.height/2.0);
    self.view.center = center;
    center.y -= self.view.bounds.size.height;
    [UIView animateWithDuration:0.4f animations:^{
        self.view.center = center;
    }];
};

- (void)hidePicker{
    UIView *superViewForPicker = self.view.superview;
    if(superViewForPicker==nil){
        return;
    };
    
    //self.view.frame = CGRectMake(0.0, superViewForPicker.bounds.size.height, self.view.frame.size.width, self.view.frame.size.height);
    CGPoint center = self.view.center;
    center.y += self.view.bounds.size.height;
    [UIView animateWithDuration:0.4f animations:^(void){
        self.view.center = center;
    }completion:^(BOOL finished){
        [self.view removeFromSuperview];
    }];
};

- (IBAction)pressOkButton:(id)sender{
    [self hidePicker];
    isSelectorWorkedNow = NO;
    if(okSelector && [delegate canPerformAction:okSelector withSender:self]){
        [delegate performSelector:okSelector withObject:self];
    };
};

- (IBAction)pressCancelButton:(id)sender{
    [self hidePicker];
    isSelectorWorkedNow = NO;
    if(cancelSelector && [delegate canPerformAction:cancelSelector withSender:self]){
        [delegate performSelector:cancelSelector withObject:self];
    };
};

- (IBAction)pressPickerOutObBounds:(id)sender{
    if(isRejectViewAfterOutOfBoundsTouch){
        [self pressCancelButton:sender];
    };
};

- (BOOL)isSelectorInWork{
    return isSelectorWorkedNow;
};

- (void)loadLocalizedStrings{
    [okButton setTitle:NSLocalizedString(@"Done", @"") forState:UIControlStateNormal];
    [okButton setTitle:NSLocalizedString(@"Done", @"") forState:UIControlStateHighlighted];
    [okButton setTitle:NSLocalizedString(@"Done", @"") forState:UIControlStateDisabled];
    [cancelButton setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateNormal];
    [cancelButton setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateHighlighted];
    [cancelButton setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateDisabled];
};


@end
