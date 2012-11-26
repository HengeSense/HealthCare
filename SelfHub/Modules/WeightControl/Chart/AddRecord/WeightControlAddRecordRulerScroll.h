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

- (void)showWeight:(float)weight;
- (float)getWeight;
- (float)getWeightForOffset:(float)needOffset;

- (float)getPointsBetween100g;

@end
