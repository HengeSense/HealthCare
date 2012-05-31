//
//  WeightControlTestClass.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 17.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeightControlQuartzPlot.h"


@implementation WeightControlQuartzPlot

@synthesize delegateWeight, scrollView, contentView, xAxis, yAxis;

- (id)initWithFrame:(CGRect)frame andDelegate:(WeightControl *)_delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegateWeight = _delegate;
        scrollView = [[WeightControlPlotScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        yAxis = [[WeightControlVerticalAxisView alloc] initWithFrame:CGRectMake(0.0, 0.0, 33.0, frame.size.height)];
        [yAxis setBackgroundColor:[UIColor whiteColor]];
        xAxis = [[WeightControlHorizontalAxisView alloc] initWithFrame:CGRectMake(0.0, frame.size.height-15.0, 5000.0, 15.0)];
        xAxis.isZooming = NO;
        [xAxis setBackgroundColor:[UIColor whiteColor]];
        contentView = [[WeightControlQuartzPlotContent alloc] initWithFrame:CGRectMake(0.0, 0.0, 5000.0, frame.size.height)];
        contentView.delegate = self;
        [contentView setBackgroundColor:[UIColor whiteColor]];
        contentView.delegateWeight = _delegate;
        contentView.weightGraphYAxisView = yAxis;
        contentView.weightGraphXAxisView = xAxis;
        
        scrollView.delegate = contentView;
        scrollView.minimumZoomScale = 0.02f;
        scrollView.maximumZoomScale = 20.0f;
        scrollView.contentSize = contentView.frame.size;
        scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        [scrollView setScrollEnabled:YES];
        [scrollView addSubview:contentView];
        
        pointerView = [[WeightControlQuartzPlotPointer alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
        pointerView.delegate = self;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        tapGesture.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapGesture];
        
        [self addSubview:scrollView];
        [self addSubview:xAxis];
        [self addSubview:yAxis];
        [self addSubview:pointerView];
        
        lastContentOffset = 0.0;
        lastPointerX = 0.0;
        
    }
    return self;
}

- (void)dealloc{
    delegateWeight = nil;
    [scrollView release];
    [contentView release];
    [xAxis release];
    [yAxis release];
    
    [super dealloc];
}

- (void)redrawPlot{
    [contentView performUpdatePlot];
};

- (void)testPixel{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, self.contentScaleFactor);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView *testImg = [[UIImageView alloc] initWithImage:image];
    //testImg.contentScaleFactor = 8.0;
    //[self.superview.superview addSubview:testImg];
    [testImg release];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender{
    if(pointerView.alpha<0.1){
        [self showPointerForContentViewPoint:[sender locationInView:contentView] atPosition:[sender locationInView:pointerView].x];
    }else{
        [self hidePointer];
    };
};

- (void)showPointerForContentViewPoint:(CGPoint)contentViewPoint atPosition:(CGFloat)xPointer{
    NSTimeInterval tappedTimeInt = [contentView getTimeIntervalSince1970ForX:contentViewPoint.x];
    NSTimeInterval testedTimeInt;
    NSDictionary *oneRecord;
    float w1, w2, tappedWeight = 0.0;
    int i;
    for(i=0;i<[delegateWeight.weightData count];i++){
        oneRecord = [delegateWeight.weightData objectAtIndex:i];
        testedTimeInt = [[oneRecord objectForKey:@"date"] timeIntervalSince1970];
        NSDictionary *nextRecord = [delegateWeight.weightData objectAtIndex:i+1];
        NSTimeInterval nextTimeInt = [[nextRecord objectForKey:@"date"] timeIntervalSince1970];
        if(tappedTimeInt>=testedTimeInt && tappedTimeInt<=nextTimeInt){
            if(i<[delegateWeight.weightData count]-1){
                w1 = [[oneRecord objectForKey:@"weight"] floatValue];
                w2 = [[nextRecord objectForKey:@"weight"] floatValue];
                tappedWeight = w1 + (((tappedTimeInt - testedTimeInt) * (w2 - w1)) / (nextTimeInt - testedTimeInt));
                break;
            };
        };
    };
    //contentViewPoint.x = xPointer;
    
    lastContentPoint = contentViewPoint;
    lastPointerX = xPointer;
    lastContentOffset = [scrollView contentOffset].x;
    
    //contentViewPoint.y = [contentView convertWeightToY:tappedWeight];
    //NSLog(@"Show pointer for: %.0fx%.0f (weight = %.1f kg)", contentViewPoint.x, contentViewPoint.y, tappedWeight);
    
    [pointerView showPointerAtPoint:CGPointMake(xPointer, [contentView convertWeightToY:tappedWeight])];
};

- (void)updatePointerDuringScrolling{
    if(pointerView.alpha < 0.1) return;
    
    float offsetPointer = [scrollView contentOffset].x - lastContentOffset;
    //NSLog(@"lastContentPoint = %.0f", offsetPointer);
    
    lastContentPoint.x += offsetPointer;
    //lastContentOffset = newContentOffset;
    [self showPointerForContentViewPoint:lastContentPoint atPosition:lastPointerX];
};

- (void)hidePointer{
    [pointerView hidePointerView];
}

- (float)getWeightByY:(float)yCoord{
    return [contentView convertYToWeight:yCoord];
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
