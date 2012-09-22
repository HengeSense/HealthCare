//
//  WeightControlQuartzPlotZoomer.m
//  SelfHub
//
//  Created by Mac on 04.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeightControlQuartzPlotZoomer.h"

@implementation WeightControlQuartzPlotZoomer

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    float centerX = frame.size.width / 2;
    float centerY = frame.size.height / 2;
    
    CGRect zoomerFrame = CGRectMake(centerX - 51.0, centerY + 130.0, 101.0, 40.0);
    self = [super initWithFrame:zoomerFrame];
    if (self) {
        // Initialization code
        //btnIn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 40.0)];
        //btnOut = [[UIButton alloc] initWithFrame:CGRectMake(51.0, 0.0, 50.0, 40.0)];
        btnIn = [UIButton buttonWithType:UIButtonTypeCustom];
        btnOut = [UIButton buttonWithType:UIButtonTypeCustom];
        btnIn.frame = CGRectMake(0.0, 0.0, 50.0, 40.0);
        btnOut.frame = CGRectMake(51.0, 0.0, 50.0, 40.0);
        
        [btnIn setImage:[UIImage imageNamed:@"weightControlQuartzPlotZoomIn_off.png"] forState:UIControlStateNormal];
        [btnIn setImage:[UIImage imageNamed:@"weightControlQuartzPlotZoomIn_on.png"] forState:UIControlStateHighlighted];
        [btnIn setImage:[UIImage imageNamed:@"weightControlQuartzPlotZoomIn_unav.png"] forState:UIControlStateDisabled];
        [btnOut setImage:[UIImage imageNamed:@"weightControlQuartzPlotZoomOut_off.png"] forState:UIControlStateNormal];
        [btnOut setImage:[UIImage imageNamed:@"weightControlQuartzPlotZoomOut_on.png"] forState:UIControlStateHighlighted];
        [btnOut setImage:[UIImage imageNamed:@"weightControlQuartzPlotZoomOut_unav.png"] forState:UIControlStateDisabled];
        
        [btnIn addTarget:self action:@selector(pressIn:) forControlEvents:UIControlEventTouchDown];
        [btnOut addTarget:self action:@selector(pressOut:) forControlEvents:UIControlEventTouchDown];
        btnIn.userInteractionEnabled = YES;
        btnOut.userInteractionEnabled = YES;
        self.userInteractionEnabled = YES;
        
        [self addSubview:btnIn];
        [self addSubview:btnOut];
        
        btnIn.exclusiveTouch = YES;
        btnOut.exclusiveTouch = YES;
        
        self.alpha = 0.0;
        
        hideZoomTimer = nil;
    };
    return self;
}

- (void)dealloc{
    //[btnIn release];
    //[btnOut release];
    
    [super dealloc];
};

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/



- (void)showZoomView{
    [UIView animateWithDuration:0.2 animations:^(void){
        self.alpha = 0.6;
    }];
    
    [self setHideTimerForATime:5.0];
};

- (void)hideZoomView{
    [UIView animateWithDuration:0.2 animations:^(void){
        self.alpha = 0.0;
    }];
};

- (void)setHideTimerForATime:(NSTimeInterval)timerInterval{
    if(hideZoomTimer){
        [hideZoomTimer invalidate];
        hideZoomTimer = nil;
    };
    
    hideZoomTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(hideZoomerTimerRoutine:) userInfo:nil repeats:NO];
    //[hideZoomTimer fire];
    
};

- (void)hideZoomerTimerRoutine:(NSTimer *)theTimer{
    [theTimer invalidate];
    hideZoomTimer = nil;
    
    [self hideZoomView];
};

- (IBAction)pressIn:(id)sender{
    [delegate zoomIn];
    
    [self setHideTimerForATime:5.0];
};
- (IBAction)pressOut:(id)sender{
    [delegate zoomOut];
    
    [self setHideTimerForATime:5.0];
};

- (void)setInEnabled:(BOOL)enabled{
    [btnIn setEnabled:enabled];
};
- (void)setOutEnabled:(BOOL)enabled{
    [btnOut setEnabled:enabled];
};


@end
