//
//  WeightControlQuartzPlotGLES.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 03.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeightControlQuartzPlotGLES.h"
#import <QuartzCore/QuartzCore.h>
#import "WeightControlPlotRenderEngine.h"

#define RENDERER_TYPECAST(x) ((WeightControlPlotRenderEngine *)x)

@implementation WeightControlQuartzPlotGLES


+ (Class)layerClass {
    return [CAEAGLLayer class];
};

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CAEAGLLayer* eaglLayer = (CAEAGLLayer*) super.layer;
        eaglLayer.opaque = YES;
        eaglLayer.contentsScale = 2.0;
        plotContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        if (!plotContext || ![EAGLContext setCurrentContext:plotContext]) {
            [self release];
            return nil;
        };
        
        myRender = CreateRendererForGLES1();
        [plotContext renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable: eaglLayer];
        RENDERER_TYPECAST(myRender)->Initialize(frame.size.width*eaglLayer.contentsScale, frame.size.height*eaglLayer.contentsScale);
        RENDERER_TYPECAST(myRender)->SetYAxisParams(70.0, 100.0, 1.5, false);
        
        drawingsCounter = 0;
        CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView:)];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        [self drawView:nil];
        
        timestamp = CACurrentMediaTime();
        
        tmpVal = false;
        
        //[self _testHorizontalLinesAnimating];
        

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) drawView:(CADisplayLink*) displayLink{
    drawingsCounter++;
    if(drawingsCounter==60){
        //NSLog(@"OpenGL ES 1.1 plot's FPS: %.3f", 1.0 / displayLink.duration);
        drawingsCounter = 0;
    };
    
    if (displayLink != nil) {
        float elapsedSeconds = displayLink.timestamp - timestamp;
        timestamp = displayLink.timestamp;
        RENDERER_TYPECAST(myRender)->UpdateAnimation(elapsedSeconds);
    }
    
    RENDERER_TYPECAST(myRender)->Render();
    
    [plotContext presentRenderbuffer:GL_RENDERBUFFER_OES];
};

- (void)_testHorizontalLinesAnimating{
    if(!tmpVal){
        RENDERER_TYPECAST(myRender)->SetYAxisParams(70.0, 80.0, 0.5, true);
    }else{
        RENDERER_TYPECAST(myRender)->SetYAxisParams(70.0, 100.0, 0.5, true);
    };
    tmpVal = !tmpVal;
}

@end
