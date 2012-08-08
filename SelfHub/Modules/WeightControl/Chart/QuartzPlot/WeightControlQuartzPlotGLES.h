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


@interface WeightControlQuartzPlotGLES : UIView {
    EAGLContext *plotContext;
    
    void *myRender;
    
    int drawingsCounter;
    float timestamp;
    
    bool tmpVal;
}

- (void) drawView: (CADisplayLink*) displayLink;

- (void)_testHorizontalLinesAnimating;


@end
