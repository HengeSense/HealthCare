//
//  WeightControlChartAddRecordView.h
//  SelfHub
//
//  Created by Mac on 21.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeightControlAddRecordRulerScroll.h"

@class WeightControlAddRecordRulerScroll;

@protocol WeightControlAddRecordProtocol;

@interface WeightControlAddRecordView : UIView <UIScrollViewDelegate>{
    BOOL isDateMode;
    float curWeight;
}

@property (nonatomic, assign) UIViewController<WeightControlAddRecordProtocol> *viewControllerDelegate;
@property (nonatomic) float curWeight;

@property (nonatomic, retain) IBOutlet UIView *addRecordView;
@property (nonatomic, retain) IBOutlet UIView *confirmDateView;
@property (nonatomic, retain) IBOutlet UILabel *currentDate;
@property (nonatomic, retain) IBOutlet UILabel *currentWeight;
@property (nonatomic, retain) IBOutlet WeightControlAddRecordRulerScroll *rulerScrollView;
@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;

- (IBAction)pressChangeDate:(id)sender;
- (IBAction)pressConfirmDate:(id)sender;
- (IBAction)pressCancelDate:(id)sender;
- (IBAction)pressAddRecord:(id)sender;
- (IBAction)pressCancelRecord:(id)sender;

- (void)swithToDateView;
- (void)swithToWeigtView;

- (void)showView;
- (void)hideView;


@end


@protocol WeightControlAddRecordProtocol <NSObject>
@optional
- (void)pressAddRecord:(NSDictionary *)newRecord;
- (void)pressCancelRecord;
@end

