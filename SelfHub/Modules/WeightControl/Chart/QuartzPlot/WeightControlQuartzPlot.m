//
//  WeightControlTestClass.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 17.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeightControlQuartzPlot.h"

#define TEST_OPENGL YES


@implementation WeightControlQuartzPlot

@synthesize delegateWeight, glContentView;

- (id)initWithFrame:(CGRect)frame andDelegate:(WeightControl *)_delegate
{
    self = [super initWithFrame:frame];
    //NSLog(@"WeigntControlQuartzPlot frame: %.0f, %.0f, %.0f, %.0f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    
    if (self) {
        self.delegateWeight = _delegate;
        
        float contentViewWidthInit = 320.0f;
        if([delegateWeight.weightData count] > 0){
            NSTimeInterval firstDateInt = [[[delegateWeight.weightData objectAtIndex:0] objectForKey:@"date"] timeIntervalSince1970];
            NSTimeInterval lastDateInt = [[[delegateWeight.weightData lastObject] objectForKey:@"date"] timeIntervalSince1970];
            contentViewWidthInit = ((lastDateInt-firstDateInt) / (24*60*60)) * 50.0;
            if(contentViewWidthInit<160.0){
                contentViewWidthInit = 320.0;
            }else{
                contentViewWidthInit += 320;
            };
        };
        
        glContentView = [[WeightControlQuartzPlotGLES alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height) andDelegate:delegateWeight];
        [self addSubview:glContentView];
        //NSLog(@"content scale factor: %.1f", glContentView.layer.contentsScale);
    }
    return self;
}

- (void)dealloc{
    delegateWeight = nil;
    [glContentView release];
    
    [super dealloc];
}

- (void)redrawPlot{
    [glContentView updatePlotLowLayerBase];
};

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
