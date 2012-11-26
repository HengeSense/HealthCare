//
//  WeightControlChartAddRecordView.m
//  SelfHub
//
//  Created by Mac on 21.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeightControlAddRecordView.h"

#define kAddRecordDateFormat @"dd MMMM YYYY"

@implementation WeightControlAddRecordView

@synthesize viewControllerDelegate, popupBackgroundView, curWeight, addRecordView, currentDate, currentWeight, rulerScrollView, datePicker, cancelButton, okButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.alpha = 0.0;
        isDateMode = NO;
        initHeight = 264.0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder{
    self = [super initWithCoder:decoder];
    
    if(self){
        //Init code
        self.alpha = 0.0;
        isDateMode = NO;
        initHeight = 264.0;
    }
    
    return self;
};


- (void)dealloc{
    viewControllerDelegate = nil;
    [popupBackgroundView release];
    [addRecordView release];
    [currentDate release];
    [currentWeight release];
    [rulerScrollView release];
    [datePicker release];
    [cancelButton release];
    [okButton release];
    
    [super dealloc];
};

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)pressChangeDate:(id)sender{
    [self swithToDateView];
};

- (IBAction)pressConfirmDate:(id)sender{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter.dateFormat = @"dd MMMM YYYY";
    currentDate.text = [dateFormatter stringFromDate:datePicker.date];
    
    [self swithToWeigtView];
};

- (IBAction)pressCancelDate:(id)sender{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter.dateFormat = kAddRecordDateFormat;
    datePicker.date = [dateFormatter dateFromString:currentDate.text];
    
    [self swithToWeigtView];
};

- (IBAction)pressAddRecord:(id)sender{
    if(isDateMode){
        return [self pressConfirmDate:sender];
    };
    
    NSArray *objArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:curWeight], [[datePicker.date retain] autorelease], nil];
    NSArray *keysArray = [NSArray arrayWithObjects:@"weight", @"date", nil];
    
    [viewControllerDelegate pressAddRecord:[NSDictionary dictionaryWithObjects:objArray forKeys:keysArray]];
    
    [self hideView];
};

- (IBAction)pressCancelRecord:(id)sender{
    if(isDateMode){
        return [self pressCancelDate:sender];
    };
    
    [viewControllerDelegate pressCancelRecord];
    
    [self hideView];
};

- (void)swithToDateView{
    if(datePicker.alpha > 0.1) return;
    //NSLog(@"Add Record View bounds: %.0fx%.0f", self.bounds.size.width, self.bounds.size.height);
    [UIView animateWithDuration:0.2 animations:^(void){
        datePicker.alpha = 1.0;
        addRecordView.frame = CGRectMake(addRecordView.frame.origin.x, addRecordView.frame.origin.y, addRecordView.frame.size.width, initHeight+35.0);
        self.popupBackgroundView.frame = CGRectMake(0, 0, addRecordView.frame.size.width, addRecordView.frame.size.height);
        self.cancelButton.center = CGPointMake(cancelButton.center.x, 216.0+50.0);
        self.okButton.center = CGPointMake(okButton.center.x, 216.0+50.0);
    }];
    
    isDateMode = YES;
};

- (void)swithToWeigtView{
    if(datePicker.alpha < 0.1) return;
    //NSLog(@"Add Record View bounds: %.0fx%.0f", self.bounds.size.width, self.bounds.size.height);
    [UIView animateWithDuration:0.2 animations:^(void){
        datePicker.alpha = 0.0;
        addRecordView.frame = CGRectMake(addRecordView.frame.origin.x, addRecordView.frame.origin.y, addRecordView.frame.size.width, initHeight);
        self.popupBackgroundView.frame = CGRectMake(0, 0, addRecordView.frame.size.width, addRecordView.frame.size.height);
        self.cancelButton.center = CGPointMake(cancelButton.center.x, 216.0);
        self.okButton.center = CGPointMake(okButton.center.x, 216.0);
    }];
    
    isDateMode = NO;
};

- (void)showView{
    //NSLog(@"Add Record View bounds: %.0fx%.0f", self.bounds.size.width, self.bounds.size.height);
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter.dateFormat = kAddRecordDateFormat;
    currentDate.text = [dateFormatter stringFromDate:datePicker.date];
    [rulerScrollView showWeight:curWeight];
    currentWeight.text = isnan(curWeight) ? @ "not set" : [NSString stringWithFormat:@"%.1f", curWeight];
    
    if(popupBackgroundView.image==nil){
        popupBackgroundView.image = [[UIImage imageNamed:@"weightControlAddRecord_popupBackground.png"] stretchableImageWithLeftCapWidth:25 topCapHeight:25];
    };
    
    [UIView animateWithDuration:0.2 animations:^(void){
        self.alpha = 1.0;
    }];
};

- (void)hideView{
    //NSLog(@"Add Record View bounds: %.0fx%.0f", self.bounds.size.width, self.bounds.size.height);
    [UIView animateWithDuration:0.2 animations:^(void){
        self.alpha = 0.0;
    }];
};

#pragma mark - UIScrollViewDelegate's functions

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //NSLog(@"scrolling...");
    curWeight = [rulerScrollView getWeight];
    currentWeight.text = [NSString stringWithFormat:@"%.1f kg", curWeight];
    
};

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    //float startTargetOffsetX = targetContentOffset->x;
    float dist = [rulerScrollView getPointsBetween100g];
    div_t dt = div(((int)targetContentOffset->x), dist);
    
    if(dt.rem <= (dist/2)){
        targetContentOffset->x = dt.quot * dist;
    }else{
        targetContentOffset->x = (dt.quot+1) * dist;
    };
    if(rulerScrollView.isNanAim) rulerScrollView.isNanAim = NO;
}


@end
