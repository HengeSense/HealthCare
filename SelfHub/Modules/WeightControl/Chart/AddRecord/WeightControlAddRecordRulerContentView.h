//
//  WeightControlAddRecordRulerView.h
//  SelfHub
//
//  Created by Mac on 21.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeightControlAddRecordRulerContentView : UIView{
    UIFont *labelFont;
}

@property (nonatomic) float points_between_100g;

@property (nonatomic) float minWeightKg;
@property (nonatomic) float maxWeightKg;
@property (nonatomic) float stepWeightKg;
@property (nonatomic) float weightFactor;


- (id)initWithFrame:(CGRect)frame and100gInterval:(float)interval;

@end
