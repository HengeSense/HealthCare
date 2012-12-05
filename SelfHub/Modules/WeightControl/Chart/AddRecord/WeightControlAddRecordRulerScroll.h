//
//  WeightControlAddRecordRulerScroll.h
//  SelfHub
//
//  Created by Mac on 21.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeightControlAddRecordRulerScroll : UIScrollView{
    
}


@property (nonatomic) BOOL isNanAim;

@property (nonatomic) float minWeightKg;
@property (nonatomic) float maxWeightKg;
@property (nonatomic) float stepWeightKg;
@property (nonatomic) float weightFactor;

- (void)showWeight:(float)weight;
- (float)getWeight;
- (float)getWeightForOffset:(float)needOffset;

- (float)getPointsBetween100g;

@end
