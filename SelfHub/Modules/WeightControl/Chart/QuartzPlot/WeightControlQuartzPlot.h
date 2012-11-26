//
//  WeightControlTestClass.h
//  SelfHub
//
//  Created by Eugine Korobovsky on 17.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WeightControl.h"
#import "WeightControlQuartzPlotGLES.h"

@class WeightControl;
@class WeightControlQuartzPlotGLES;

@interface WeightControlQuartzPlot : UIView {
    WeightControlQuartzPlotGLES *glContentView;
    
    CGFloat lastContentOffset;
    CGFloat lastContentX;
    CGFloat lastPointerX;
    
}

@property (nonatomic, assign) WeightControl *delegateWeight;

@property (nonatomic, retain) WeightControlQuartzPlotGLES *glContentView;


- (id)initWithFrame:(CGRect)frame andDelegate:(WeightControl *)_delegate;

- (void)redrawPlot;
- (void)showLastDays;

@end

