//
//  WeightControlQuartzPlotGLES.h
//  SelfHub
//
//  Created by Eugine Korobovsky on 03.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "WeightControl.h"

@class WeightControl;


@interface WeightControlQuartzPlotGLES : UIView {
    EAGLContext *plotContext;
    
    void *myRender;
    
    int drawingsCounter;
    float timestamp;
    
    float startScale, curScale;
    float startPanOffset, curPanOffset;
    
    bool tmpVal;
}

@property (nonatomic, assign) WeightControl *delegateWeight;


- (id)initWithFrame:(CGRect)frame andDelegate:(WeightControl *)_delegate;

- (void)updatePlotLowLayerBase;

- (void) drawView: (CADisplayLink*) displayLink;
- (void)_testHorizontalLinesAnimating;

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)handlePinchGestureRecognizer:(UIPinchGestureRecognizer *)gestureRecognizer;


@end
