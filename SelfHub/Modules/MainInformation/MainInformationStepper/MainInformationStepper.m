//
//  MainInformationStepper.m
//  HealthCare
//
//  Created by Eugine Korobovsky on 15.12.12.
//
//

#import "MainInformationStepper.h"

@implementation MainInformationStepper

@synthesize minimumValue, maximumValue, stepValue, value;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        //[self removeAllSegments];
        UIImage *firstSegmentImage = [UIImage imageNamed:@"profileModule_stepper_left_norm.png"];
        UIImage *secondSegmentImage = [UIImage imageNamed:@"profileModule_stepper_right_norm.png"];
        UIImage *firstSegmentImage_press = [UIImage imageNamed:@"profileModule_stepper_left_press.png"];
        UIImage *secondSegmentImage_press = [UIImage imageNamed:@"profileModule_stepper_right_press.png"];
        
        UIButton *decrementButton = [[UIButton alloc] init];
        decrementButton.frame = CGRectMake(0.0, 0.0, firstSegmentImage.size.width, firstSegmentImage.size.height);
        [decrementButton setImage:firstSegmentImage forState:UIControlStateNormal];
        [decrementButton setImage:firstSegmentImage_press forState:UIControlStateHighlighted];
        [decrementButton addTarget:self action:@selector(onTouchDecrementButton:) forControlEvents:UIControlEventTouchDown];
        [decrementButton addTarget:self action:@selector(onUntouchDecrementButton:) forControlEvents:UIControlEventTouchCancel|UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
        
        
        UIButton *incrementButton = [[UIButton alloc] init];
        incrementButton.frame = CGRectMake(firstSegmentImage.size.width, 0.0, secondSegmentImage.size.width, secondSegmentImage.size.height);
        [incrementButton setImage:secondSegmentImage forState:UIControlStateNormal];
        [incrementButton setImage:secondSegmentImage_press forState:UIControlStateHighlighted];
        [incrementButton addTarget:self action:@selector(onTouchIncrementButton:) forControlEvents:UIControlEventTouchDown];
        [incrementButton addTarget:self action:@selector(onUntouchIncrementButton:) forControlEvents:UIControlEventTouchCancel|UIControlEventTouchUpInside|UIControlEventTouchUpOutside];

        
        CGRect myFrame = self.frame;
        myFrame.size.width = firstSegmentImage.size.width + secondSegmentImage.size.width;
        myFrame.size.height = firstSegmentImage.size.height;
        self.frame = myFrame;
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:decrementButton];
        [self addSubview:incrementButton];
        
        [decrementButton release];
        [incrementButton release];
        
        minimumValue = 0.0;
        maximumValue = 100.0;
        stepValue = 1.0;
        value = 50.0;
        
        isRepeatMode = NO;
        
    }
    return self;
};

- (void)addTargetForValueChangedEnvent:(id)obj withSelector:(SEL)selector{
    delegate = obj;
    valueChangeSelector = selector;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)decrementValue{
    value -= stepValue;
    if(value<minimumValue) value = minimumValue;
    if(value>maximumValue) value = maximumValue;
    
    if([delegate canPerformAction:valueChangeSelector withSender:nil]){
        [delegate performSelector:valueChangeSelector withObject:self];
    };
};

- (void)incrementValue{
    value += stepValue;
    if(value<minimumValue) value = minimumValue;
    if(value>maximumValue) value = maximumValue;
    
    if([delegate canPerformAction:valueChangeSelector withSender:nil]){
        [delegate performSelector:valueChangeSelector withObject:self];
    };
};


- (IBAction)onTouchDecrementButton:(id)sender{
    startClock = [[NSDate date] timeIntervalSince1970];
    isRepeatMode = YES;
    secsBetweenRepeat = 1.0;
    repeatTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(timerFuncDecrement:) userInfo:nil repeats:YES];
    [repeatTimer fire];
};

- (IBAction)onUntouchDecrementButton:(id)sender{
    isRepeatMode = NO;
};


- (IBAction)onTouchIncrementButton:(id)sender{
    startClock = [[NSDate date] timeIntervalSince1970];
    isRepeatMode = YES;
    secsBetweenRepeat = 1.0;
    repeatTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(timerFuncIncrement:) userInfo:nil repeats:YES];
    [repeatTimer fire];
};
- (IBAction)onUntouchIncrementButton:(id)sender{
    isRepeatMode = NO;
};



- (void)timerFuncDecrement:(NSTimer *)theTimer{
    if(isRepeatMode==NO){
        [self decrementValue];
        [theTimer invalidate];
        return;
    };
    
    NSTimeInterval curClock = [[NSDate date] timeIntervalSince1970];
    float secs = curClock - startClock;
    
    if(secs>=secsBetweenRepeat){
        startClock = curClock;
        [self decrementValue];
        secsBetweenRepeat = secsBetweenRepeat / 2.0;
        if(secsBetweenRepeat<0.1) secsBetweenRepeat = 0.1;
    };
};

- (void)timerFuncIncrement:(NSTimer *)theTimer{
    if(isRepeatMode==NO){
        [self incrementValue];
        [theTimer invalidate];
        return;
    };
    
    NSTimeInterval curClock = [[NSDate date] timeIntervalSince1970];
    float secs = curClock - startClock;
    
    if(secs>=secsBetweenRepeat){
        startClock = curClock;
        [self incrementValue];
        secsBetweenRepeat = secsBetweenRepeat / 2.0;
        if(secsBetweenRepeat<0.1) secsBetweenRepeat = 0.1;
    };
};

@end
