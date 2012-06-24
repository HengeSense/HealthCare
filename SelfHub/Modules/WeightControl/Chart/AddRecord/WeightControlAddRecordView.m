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

@synthesize viewControllerDelegate, curWeight, addRecordView, confirmDateView, currentDate, currentWeight, rulerScrollView, datePicker;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder{
    self = [super initWithCoder:decoder];
    
    if(self){
        //Init code
        self.alpha = 0.0;
        isDateMode = NO;
    }
    
    return self;
};

- (void)dealloc{
    viewControllerDelegate = nil;
    [addRecordView release];
    [confirmDateView release];
    [currentDate release];
    [currentWeight release];
    [rulerScrollView release];
    [datePicker release];
    
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
    NSArray *objArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:curWeight], [datePicker.date retain], nil];
    NSArray *keysArray = [NSArray arrayWithObjects:@"weight", @"date", nil];
    
    [viewControllerDelegate pressAddRecord:[NSDictionary dictionaryWithObjects:objArray forKeys:keysArray]];
    
    [self hideView];
};

- (IBAction)pressCancelRecord:(id)sender{
    [viewControllerDelegate pressCancelRecord];
    
    [self hideView];
};

- (void)swithToDateView{
    if(datePicker.alpha > 0.1) return;
    
    CGPoint centerPoint = confirmDateView.center;
    centerPoint.y += confirmDateView.frame.size.height;
    
    [UIView animateWithDuration:0.2 animations:^(void){
        datePicker.alpha = 1.0;
        confirmDateView.alpha = 1.0;
        confirmDateView.center = centerPoint;
    }];
};

- (void)swithToWeigtView{
    if(datePicker.alpha < 0.1) return;
    
    CGPoint centerPoint = confirmDateView.center;
    centerPoint.y -= confirmDateView.frame.size.height;
    
    [UIView animateWithDuration:0.2 animations:^(void){
        datePicker.alpha = 0.0;
        confirmDateView.alpha = 0.0;
        confirmDateView.center = centerPoint;
    }];
};

- (void)showView{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter.dateFormat = kAddRecordDateFormat;
    currentDate.text = [dateFormatter stringFromDate:datePicker.date];
    currentWeight.text = [NSString stringWithFormat:@"%.1f", curWeight];
    [rulerScrollView showWeight:curWeight];
    
    [UIView animateWithDuration:0.2 animations:^(void){
        self.alpha = 1.0;
    }];
};

- (void)hideView{
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
    float startTargetOffsetX = targetContentOffset->x;
    float dist = [rulerScrollView getPointsBetween100g];
    div_t dt = div(((int)targetContentOffset->x + scrollView.frame.size.width/2), dist);
    
    if(dt.rem <= (dist/2)){
        targetContentOffset->x = dt.quot * dist - scrollView.frame.size.width/2;
    }else{
        targetContentOffset->x = (dt.quot+1) * dist - scrollView.frame.size.width/2;
    };
    //[scrollView setContentOffset:*targetContentOffset animated:YES];
    NSLog(@"TargetContentOffset: %.0f -> %.0f", startTargetOffsetX, targetContentOffset->x);
}


@end
