//
//  WeightControlAddRecordRulerScroll.h
//  SelfHub
//
//  Created by Mac on 21.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeightControlAddRecordRulerScroll : UIScrollView


- (void)showWeight:(float)weight;
- (float)getWeight;

- (float)getPointsBetween100g;

@end
