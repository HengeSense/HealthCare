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
@class WeightControlQuartzPlotPointerScrolerView;
@class WeightControlQuartzPlotPointer;


@interface WeightControlQuartzPlotPointerScrolerView : UIView{
    float pointerX;
    float currentPointer_forPanGesture;
};

@property (nonatomic, assign) WeightControlQuartzPlot *delegate;
@property (nonatomic) float pointerX;
@property (nonatomic) float currentPointer_forPanGesture;

- (void)showPointerScrollViewAtXCoord:(float)xCoord;
- (void)showPointerScrollView;
- (void)hidePointerScrollView;

- (void)panGestureSelector:(UIPanGestureRecognizer *)sender;

@end


@interface WeightControlQuartzPlotPointer : UIView {
    CGPoint labelPoint;
    NSTimeInterval curTimeInt;
}

@property (nonatomic, assign) WeightControlQuartzPlot *delegate;
@property (nonatomic) NSTimeInterval curTimeInt;

- (void)showPointerAtPoint:(CGPoint)currentPoint;
- (void)showPointerAtPoint:(CGPoint)touchPoint forContext:(CGImageRef)contentImage;

- (void)showPointerView;
- (void)hidePointerView;
- (NSArray *)getColumnForPoint:(CGPoint)point atImage:(CGImageRef)image;
- (BOOL)isEqualColor:(UIColor *)firstColor toColor:(UIColor *)secondColor;

@end
