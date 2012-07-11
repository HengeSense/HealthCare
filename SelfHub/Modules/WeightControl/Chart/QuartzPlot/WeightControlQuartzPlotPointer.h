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


// Arrows for pointer dragging
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


// Pointer
@interface WeightControlQuartzPlotPointer : UIView {
    CGPoint weightLabelPoint;
    CGPoint trendLabelPoint;
    NSTimeInterval curTimeInt;
}

@property (nonatomic, assign) WeightControlQuartzPlot *delegate;
@property (nonatomic) NSTimeInterval curTimeInt;

- (void)showPointerAtWeightPoint:(CGPoint)weightPoint andTrendPoint:(CGPoint)trendPoint;
//- (void)showPointerAtPoint:(CGPoint)touchPoint forContext:(CGImageRef)contentImage;

- (void)showPointerView;
- (void)hidePointerView;
- (NSArray *)getColumnForPoint:(CGPoint)point atImage:(CGImageRef)image;
- (BOOL)isEqualColor:(UIColor *)firstColor toColor:(UIColor *)secondColor;

@end
