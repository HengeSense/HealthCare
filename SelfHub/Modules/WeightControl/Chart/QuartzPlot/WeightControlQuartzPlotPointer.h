//
//  WeightControlQuartzPlotPointer.h
//  SelfHub
//
//  Created by Eugine Korobovsky on 29.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeightControlQuartzPlot.h"

@class WeightControlQuartzPlot;

@interface WeightControlQuartzPlotPointer : UIView {
    CGPoint labelPoint;
}

@property (nonatomic, assign) WeightControlQuartzPlot *delegate;

- (void)showPointerAtPoint:(CGPoint)currentPoint;
- (void)showPointerAtPoint:(CGPoint)touchPoint forContext:(CGImageRef)contentImage;

- (void)showPointerView;
- (void)hidePointerView;
- (NSArray *)getColumnForPoint:(CGPoint)point atImage:(CGImageRef)image;
- (BOOL)isEqualColor:(UIColor *)firstColor toColor:(UIColor *)secondColor;

@end
