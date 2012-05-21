//
//  WeightControlQuartzPlot.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 10.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeightControlQuartzPlotContent.h"

@interface WeightControlQuartzPlotTiledLayer : CATiledLayer
@end;

@implementation WeightControlQuartzPlotTiledLayer

+ (NSTimeInterval)fadeDuration{
    return 0.2f;
}

@end

@implementation WeightControlQuartzPlotContent
//@synthesize layer;

@synthesize delegateWeight, weightGraphYAxisView, weightGraphXAxisView;

+ (Class)layerClass{
    return [WeightControlQuartzPlotTiledLayer class];
};

- (void)dealloc{
    delegateWeight = nil;
    weightGraphYAxisView = nil;
    weightGraphXAxisView = nil;
    
    [super dealloc];
};

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //[self setContentMode:UIViewContentModeTopLeft];
        [self setAutoresizingMask:UIViewAutoresizingNone];
        self.layer.anchorPoint = CGPointMake(0, 0);
        self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.opaque = YES;
        verticalGridLinesInterval = 50.0f;
        verticalGridLinesWidth = 0.5f;
        
        horizontalGridLinesInterval = 30.0f;
        horizontalGridLinesWidth = 0.2f;
        
        plotXOffset = 2;
        plotYExpandFactor = 0.2f;
        weightLineWidth = 2.0f;
        weightPointRadius = 2;
        
        previousScale = 1.0f;
        
        //self.layer.opacity = 0.2f;
        
        [self setClearsContextBeforeDrawing:NO];
        [((CATiledLayer *)self.layer) setTileSize:CGSizeMake(320*2, self.frame.size.height*2)];
        [(CATiledLayer *)self.layer setOpaque:YES]; 
        //[(CATiledLayer *)self.layer setLevelsOfDetail:10];
        //[(CATiledLayer *)self.layer setLevelsOfDetailBias:3];
        NSLog(@"Tile size: %.0fx%.0f", [((CATiledLayer *)self.layer) tileSize].width, [((CATiledLayer *)self.layer) tileSize].height);
        
    }
    return self;
};

- (void)initializeGraph{
    
};

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    CGRect rect = CGContextGetClipBoundingBox(ctx);
    
    time_t startClock = clock();
    
    // Clear background
    CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(ctx, rect);
    
    //---------- Getting common parameters ----------
    NSTimeInterval oneDay = 60*60*24;
    NSDate *drawPlotFromDate = [[delegateWeight.weightData objectAtIndex:0] objectForKey:@"date"];
    NSDate *drawPlotToDate = [[delegateWeight.weightData lastObject] objectForKey:@"date"];
    NSArray *minMaxWeight = [self calcYRangeFromDates:drawPlotFromDate toDate:drawPlotToDate];
    yAxisFrom = [[minMaxWeight objectAtIndex:0] floatValue];
    yAxisTo = [[minMaxWeight objectAtIndex:1] floatValue];
    CGContextRef context = ctx;
    
    
    //---------- Drawing vertical grid lines ----------
    //NSLog(@"--- drawLayer (%.0f, %.0f, %.0f, %.0f) verticalGridLinesInterval = %.3f ---", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height, verticalGridLinesInterval);
    CGContextSetLineWidth(context, verticalGridLinesWidth);
    CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    NSUInteger i = 0;
    //div_t dt = div((int)rect.origin.x, (int)verticalGridLinesInterval);
    float startXGrid = floor(rect.origin.x / verticalGridLinesInterval) * verticalGridLinesInterval;
    float i_float;
    for(i_float = startXGrid; i_float< rect.origin.x+rect.size.width; i_float+=verticalGridLinesInterval){
        //NSLog(@"\t grid at: %.3f", i_float);
        CGContextMoveToPoint(context, i_float, rect.origin.y);
        CGContextAddLineToPoint(context, i_float, rect.origin.y+rect.size.height-15.0f);
    }
    CGContextStrokePath(context);
    
    
    //---------- Drawing horizontal grid lines ----------
    CGContextSetLineWidth(context, horizontalGridLinesWidth);
    CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    NSUInteger numOfHorizontalLines = (NSUInteger)((float)self.frame.size.height / (float)horizontalGridLinesInterval);
    for(i=0;i<numOfHorizontalLines;i++){
        CGContextMoveToPoint(context, rect.origin.x, i*horizontalGridLinesInterval);
        CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, i*horizontalGridLinesInterval);
    };
    CGContextStrokePath(context);
    
    //---------- Drawing vertical axis with labels ----------
    weightGraphYAxisView.startWeight = yAxisFrom;
    weightGraphYAxisView.finishWeight = yAxisTo;
    weightGraphYAxisView.horizontalGridLinesInterval = horizontalGridLinesInterval;
    weightGraphYAxisView.numOfHorizontalLines = numOfHorizontalLines;
    [weightGraphYAxisView setNeedsDisplay];
    
    
    
    //---------- Drawing weight line ----------
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, weightLineWidth);
    CGContextSetStrokeColorWithColor(context, [[UIColor orangeColor] CGColor]);
    
    NSDate *curDate;                     
    
    NSUInteger daysBetweenDates;
    float curWeight = [[[delegateWeight.weightData objectAtIndex:0] objectForKey:@"weight"] floatValue];
    float plotXOffsetPx = plotXOffset * verticalGridLinesInterval;
    CGPoint curPoint;
    CGContextMoveToPoint(context, plotXOffsetPx, [self convertWeightToY:curWeight]);
    for(i=1; i<[delegateWeight.weightData count];i++){
        curDate = [[delegateWeight.weightData objectAtIndex:i] objectForKey:@"date"];
        curWeight = [[[delegateWeight.weightData objectAtIndex:i] objectForKey:@"weight"] floatValue];
        daysBetweenDates = [self daysFromDate:drawPlotFromDate toDate:curDate];
        
        curPoint = CGPointMake(daysBetweenDates*verticalGridLinesInterval+plotXOffsetPx, [self convertWeightToY:curWeight]);
        CGContextAddLineToPoint(context, curPoint.x, curPoint.y);
    };
    CGContextDrawPath(context, kCGPathStroke);
    
    //---------- Drawing data-points ----------
    // Labels for data points
    CGContextSelectFont(context, "Helvetica", 10, kCGEncodingMacRoman); //specifying horizontal axis's labels
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetFillColorWithColor(context, [[[UIColor blackColor] colorWithAlphaComponent:0.8f] CGColor]);
    CGContextSetTextMatrix(context, CGAffineTransformMake(1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f));
    //NSString *labelStr;
    
    for(i=0; i<[delegateWeight.weightData count]; i++){
        // drawing point
        curDate = [[delegateWeight.weightData objectAtIndex:i] objectForKey:@"date"];
        curWeight = [[[delegateWeight.weightData objectAtIndex:i] objectForKey:@"weight"] floatValue];
        daysBetweenDates = [self daysFromDate:drawPlotFromDate toDate:curDate];
        curPoint = CGPointMake(daysBetweenDates*verticalGridLinesInterval+plotXOffsetPx, [self convertWeightToY:curWeight]);
        CGContextAddEllipseInRect(context, CGRectMake(curPoint.x-weightPointRadius, curPoint.y-weightPointRadius, 2*weightPointRadius, 2*weightPointRadius));   //data-point
        
        
        // drawing label for point
        //labelStr = [NSString stringWithFormat:@"%.1f", curWeight];
        //CGSize labelSize = [labelStr sizeWithFont:[UIFont fontWithName:@"Helvetica" size:10]];
        //CGContextShowTextAtPoint(context, curPoint.x-labelSize.width/2, curPoint.y-5,
        //[labelStr cStringUsingEncoding:NSUTF8StringEncoding], [labelStr length]);
    };
    CGContextSetFillColorWithColor(context, [[UIColor greenColor] CGColor]);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    
    //---------- Drawing normal weight line ----------
    CGFloat normalWeight = [delegateWeight.normalWeight floatValue];
    if(normalWeight != NAN){
        CGContextSetLineWidth(context, 0.8f);
        CGContextSetStrokeColorWithColor(context, [[UIColor orangeColor] CGColor]);
        CGFloat dashForNormLine[] = {5.0F, 5.0f};
        CGContextSetLineDash(context, 0.0f, dashForNormLine, 2);
        CGContextMoveToPoint(context, rect.origin.x, [self convertWeightToY:normalWeight]);
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, [self convertWeightToY:normalWeight]);
        CGContextStrokePath(context);
    };
    
    
    //---------- Drawing aim weight line ----------
    CGFloat aimWeight = [delegateWeight.aimWeight floatValue];
    if(aimWeight != NAN){
        CGContextSetLineWidth(context, 0.8f);
        CGContextSetStrokeColorWithColor(context, [[UIColor greenColor] CGColor]);
        CGFloat dashForNormLine[] = {5.0F, 5.0f};
        CGContextSetLineDash(context, rect.origin.x, dashForNormLine, 2);
        CGContextMoveToPoint(context, 32.0f, [self convertWeightToY:aimWeight]);
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, [self convertWeightToY:aimWeight]);
        CGContextStrokePath(context);
    };
    
    time_t endClock = clock();
    
    //NSLog(@"drawLayer: (%.0f, %.0f, %.0f, %.0f) - %.3f sec", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height, (float)(endClock-startClock)/CLOCKS_PER_SEC);
    
};

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    time_t startClock = clock();
    
    
    //---------- Getting common parameters ----------
    NSTimeInterval oneDay = 60*60*24;
    NSDate *drawPlotFromDate = [[delegateWeight.weightData objectAtIndex:0] objectForKey:@"date"];
    NSDate *drawPlotToDate = [[delegateWeight.weightData lastObject] objectForKey:@"date"];
    NSArray *minMaxWeight = [self calcYRangeFromDates:drawPlotFromDate toDate:drawPlotToDate];
    yAxisFrom = [[minMaxWeight objectAtIndex:0] floatValue];
    yAxisTo = [[minMaxWeight objectAtIndex:1] floatValue];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //---------- Drawing vertical grid lines ----------
    CGContextSetLineWidth(context, verticalGridLinesWidth);
    CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    NSUInteger i = 0;
    div_t dt = div((int)rect.origin.x, (int)verticalGridLinesInterval);
    float i_float;
    for(i_float = (float)dt.quot; i_float< rect.origin.x+rect.size.width; i_float+=verticalGridLinesInterval){
        CGContextMoveToPoint(context, i_float, rect.origin.y);
        CGContextAddLineToPoint(context, i_float, rect.origin.y+rect.size.height-15.0f);
        i++;
    }
    CGContextStrokePath(context);
    
    weightGraphXAxisView.startTimeInterval = [[[delegateWeight.weightData objectAtIndex:0] objectForKey:@"date"] timeIntervalSince1970] - oneDay * plotXOffset;
    weightGraphXAxisView.numOfLabels = i;
    weightGraphXAxisView.step = oneDay;
    weightGraphXAxisView.verticalGridLinesInterval = verticalGridLinesInterval;
    [weightGraphXAxisView setNeedsDisplay];
    
    
    //---------- Drawing horizontal grid lines ----------
    CGContextSetLineWidth(context, horizontalGridLinesWidth);
    CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    NSUInteger numOfHorizontalLines = (NSUInteger)((float)self.frame.size.height / (float)horizontalGridLinesInterval);
    for(i=0;i<numOfHorizontalLines;i++){
        CGContextMoveToPoint(context, rect.origin.x, i*horizontalGridLinesInterval);
        CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, i*horizontalGridLinesInterval);
    };
    CGContextStrokePath(context);
    
    //---------- Drawing vertical axis with labels ----------
    weightGraphYAxisView.startWeight = yAxisFrom;
    weightGraphYAxisView.finishWeight = yAxisTo;
    weightGraphYAxisView.horizontalGridLinesInterval = horizontalGridLinesInterval;
    weightGraphYAxisView.numOfHorizontalLines = numOfHorizontalLines;
    [weightGraphYAxisView setNeedsDisplay];
    
    
    
    //---------- Drawing weight line ----------
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, weightLineWidth);
    CGContextSetStrokeColorWithColor(context, [[UIColor orangeColor] CGColor]);
    
    NSDate *curDate;                     
    
    NSUInteger daysBetweenDates;
    float curWeight = [[[delegateWeight.weightData objectAtIndex:0] objectForKey:@"weight"] floatValue];
    float plotXOffsetPx = plotXOffset * verticalGridLinesInterval;
    CGPoint curPoint;
    CGContextMoveToPoint(context, plotXOffsetPx, [self convertWeightToY:curWeight]);
    for(i=1; i<[delegateWeight.weightData count];i++){
        curDate = [[delegateWeight.weightData objectAtIndex:i] objectForKey:@"date"];
        curWeight = [[[delegateWeight.weightData objectAtIndex:i] objectForKey:@"weight"] floatValue];
        daysBetweenDates = [self daysFromDate:drawPlotFromDate toDate:curDate];
        
        curPoint = CGPointMake(daysBetweenDates*verticalGridLinesInterval+plotXOffsetPx, [self convertWeightToY:curWeight]);
        CGContextAddLineToPoint(context, curPoint.x, curPoint.y);
    };
    CGContextDrawPath(context, kCGPathStroke);
    
    //---------- Drawing data-points ----------
    // Labels for data points
    CGContextSelectFont(context, "Helvetica", 10, kCGEncodingMacRoman); //specifying horizontal axis's labels
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetFillColorWithColor(context, [[[UIColor blackColor] colorWithAlphaComponent:0.8f] CGColor]);
    CGContextSetTextMatrix(context, CGAffineTransformMake(1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f));
    //NSString *labelStr;
    
    for(i=0; i<[delegateWeight.weightData count]; i++){
        // drawing point
        curDate = [[delegateWeight.weightData objectAtIndex:i] objectForKey:@"date"];
        curWeight = [[[delegateWeight.weightData objectAtIndex:i] objectForKey:@"weight"] floatValue];
        daysBetweenDates = [self daysFromDate:drawPlotFromDate toDate:curDate];
        curPoint = CGPointMake(daysBetweenDates*verticalGridLinesInterval+plotXOffsetPx, [self convertWeightToY:curWeight]);
        CGContextAddEllipseInRect(context, CGRectMake(curPoint.x-weightPointRadius, curPoint.y-weightPointRadius, 2*weightPointRadius, 2*weightPointRadius));   //data-point
        
        
        // drawing label for point
        //labelStr = [NSString stringWithFormat:@"%.1f", curWeight];
        //CGSize labelSize = [labelStr sizeWithFont:[UIFont fontWithName:@"Helvetica" size:10]];
        //CGContextShowTextAtPoint(context, curPoint.x-labelSize.width/2, curPoint.y-5,
        //                         [labelStr cStringUsingEncoding:NSUTF8StringEncoding], [labelStr length]);
    };
    CGContextSetFillColorWithColor(context, [[UIColor greenColor] CGColor]);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    
    //---------- Drawing normal weight line ----------
    CGFloat normalWeight = [delegateWeight.normalWeight floatValue];
    if(normalWeight != NAN){
        CGContextSetLineWidth(context, 0.8f);
        CGContextSetStrokeColorWithColor(context, [[UIColor orangeColor] CGColor]);
        CGFloat dashForNormLine[] = {5.0F, 5.0f};
        CGContextSetLineDash(context, 0.0f, dashForNormLine, 2);
        CGContextMoveToPoint(context, rect.origin.x, [self convertWeightToY:normalWeight]);
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, [self convertWeightToY:normalWeight]);
        CGContextStrokePath(context);
    };
    
    
    //---------- Drawing aim weight line ----------
    CGFloat aimWeight = [delegateWeight.aimWeight floatValue];
    if(aimWeight != NAN){
        CGContextSetLineWidth(context, 0.8f);
        CGContextSetStrokeColorWithColor(context, [[UIColor greenColor] CGColor]);
        CGFloat dashForNormLine[] = {5.0F, 5.0f};
        CGContextSetLineDash(context, rect.origin.x, dashForNormLine, 2);
        CGContextMoveToPoint(context, 32.0f, [self convertWeightToY:aimWeight]);
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, [self convertWeightToY:aimWeight]);
        CGContextStrokePath(context);
    };
    
    time_t endClock = clock();
    
    //NSLog(@"drawRect: (%.0f, %.0f, %.0f, %.0f) - %.3f sec", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height, (float)(endClock-startClock)/CLOCKS_PER_SEC);
};
 */


- (NSArray *)calcYRangeFromDates:(NSDate *)fromDate toDate:(NSDate *)toDate{
    NSUInteger i;
    float minWeight = 10000.0f, maxWeight = 0.0f;
    NSTimeInterval fromInterval = [fromDate timeIntervalSince1970];
    NSTimeInterval toInterval = [toDate timeIntervalSince1970];
    NSNumber *curWeight;
    for(i = 0; i<[delegateWeight.weightData count]; i++){
        if([[[delegateWeight.weightData objectAtIndex:i] objectForKey:@"date"] timeIntervalSince1970] >= fromInterval){
            curWeight = [[delegateWeight.weightData objectAtIndex:i] objectForKey:@"weight"];
            if([curWeight floatValue] < minWeight) minWeight = [curWeight floatValue];
            if([curWeight floatValue] > maxWeight) maxWeight = [curWeight floatValue];
        };
        
        if([[[delegateWeight.weightData objectAtIndex:i] objectForKey:@"date"] timeIntervalSince1970] > toInterval){
            break;
        };
    };
    
    if([delegateWeight.normalWeight floatValue] != NAN){
        if([delegateWeight.normalWeight floatValue] < minWeight) minWeight = [delegateWeight.normalWeight floatValue];
        if([delegateWeight.normalWeight floatValue] > maxWeight) maxWeight = [delegateWeight.normalWeight floatValue];
    };
    if([delegateWeight.aimWeight floatValue] != NAN){
        if([delegateWeight.aimWeight floatValue] < minWeight) minWeight = [delegateWeight.aimWeight floatValue];
        if([delegateWeight.aimWeight floatValue] > maxWeight) maxWeight = [delegateWeight.aimWeight floatValue];
    };
    
    float expandRange = (maxWeight - minWeight) * (plotYExpandFactor / 2);
    return [NSArray arrayWithObjects:[NSNumber numberWithFloat:minWeight-expandRange], [NSNumber numberWithFloat:maxWeight+expandRange], nil];
};

- (float)convertWeightToY:(float)weight{
    return self.frame.size.height - (self.frame.size.height * (weight - yAxisFrom)) / (yAxisTo - yAxisFrom);
};

- (NSUInteger)daysFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate{
    NSTimeInterval intervalBetweenDates = [toDate timeIntervalSinceDate:fromDate];
    NSTimeInterval oneDay = 60 * 60 * 24;
    
    return intervalBetweenDates / oneDay;
};


#pragma mark - Some intercepted events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //NSLog(@"touchesBegan:withEvent:");
    [super touchesBegan:touches withEvent:event];
};

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    //NSLog(@"touchesMoved:withEvent:");
    [super touchesMoved:touches withEvent:event];
};

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    //NSLog(@"touchesEnded:withEvent:");
    [super touchesEnded:touches withEvent:event];
};

//Perform updating X-axis during zooming
- (void)setTransform:(CGAffineTransform)transform{
    //NSLog(@"scrollView.setTransform: a = %.2f, b = %.2f, c = %.2f, d = %.2f, tx = %.2f, ty = %.2f", transform.a, transform.b, transform.c, transform.d, transform.tx, transform.ty);
    
    [weightGraphXAxisView setTransform:transform];
    //[weightGraphXAxisView setNeedsDisplay];
    
    transform.d = 1.0f;
    [super setTransform:transform];
};

//- (void)displayLayer:(CALayer *)layer{
    //NSLog(@"displayLayer: %.0f, %.0f, %.0f, %.0f", layer.frame.origin.x, layer.frame.origin.y, layer.frame.size.width, layer.frame.size.height);
    //UIGraphicsBeginImageContextWithOptions(self.layer.bounds.size, self.layer.opaque, self.layer.contentsScale);
    //CGContextRef ctx = UIGraphicsGetCurrentContext();
    //[self drawLayer:layer inContext:ctx];
    //UIGraphicsEndImageContext();
//};

/*- (void)setTransformWithoutScaling:(CGAffineTransform)newTransform{
    //[super setTransform:newTransform];
    
    //newTransform.d = 1.0f;
    //[super setTransform:transform];
    //[super setTransform:CGAffineTransformScale(newTransform, 1.0f/previousScale, 1.0f/previousScale)];

};*/

#pragma mark UIScrollViewDelegate's functions

// return a view that will be scaled. if delegate returns nil, nothing happens
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self;
};

// called before the scroll view begins zooming its content
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_2){
    //NSLog(@"Zooming begin");
    weightGraphXAxisView.isZooming = YES;
    weightGraphXAxisView.zoomScale = scrollView.zoomScale;
    [weightGraphXAxisView setNeedsDisplay];
};

// any zoom scale changes
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    //NSLog(@"Zooming processed: scrollView.zoomScale = %.3f, scrollView.contentScaleFactol = %.3f content.contentScaleFactol = %.3f", scrollView.zoomScale, scrollView.contentScaleFactor, self.contentScaleFactor);
    previousScale = scrollView.zoomScale;
    [self setNeedsDisplayInRect:CGRectMake(scrollView.contentOffset.x - scrollView.frame.size.width, 0, scrollView.frame.size.width*3, scrollView.frame.size.height)];
};

// scale between minimum and maximum. called after any 'bounce' animations
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale{
    NSLog(@"Zoom: %.3f. Content-offset: %.0fx%.0f, frame = (%.0f, %.0f, %.0f, %.0f)", scale, scrollView.contentOffset.x, scrollView.contentOffset.y, self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    //CGAffineTransform transform = CGAffineTransformIdentity;
    //NSLog(@"Identity transform: a = %.2f, b = %.2f, c = %.2f, d = %.2f, tx = %.2f, ty = %.2f", transform.a, transform.b, transform.c, transform.d, transform.tx, transform.ty);
    CGPoint currentOffset = scrollView.contentOffset;
    currentOffset.x *= scale;
    [self setTransform:CGAffineTransformIdentity];
    self.frame = CGRectMake(0, 0, self.frame.size.width*scale, self.frame.size.height);
    //scrollView.contentOffset = CGPointMake(currentOffset.x, currentOffset.y);
    previousScale = scale;
    verticalGridLinesInterval *= scale;
    //[self setNeedsDisplayInRect:CGRectMake(scrollView.contentOffset.x - scrollView.frame.size.width, 0, scrollView.frame.size.width*3, scrollView.frame.size.height)];
    
    NSTimeInterval oneDay = 24 * 60 * 60;
    weightGraphXAxisView.startTimeInterval = [[[delegateWeight.weightData objectAtIndex:0] objectForKey:@"date"] timeIntervalSince1970] - oneDay * plotXOffset;
    weightGraphXAxisView.step = oneDay;
    weightGraphXAxisView.verticalGridLinesInterval = verticalGridLinesInterval;
    weightGraphXAxisView.isZooming = NO;
    weightGraphXAxisView.zoomScale = scale;
    [weightGraphXAxisView setNeedsDisplay];
    self.layer.opacity = 1.0f;
    [UIView animateWithDuration:0.25 animations:^(void){
        self.alpha = 0.0; 
    }completion:^(BOOL finished){
        [self setNeedsDisplay];
        scrollView.contentSize = CGSizeMake(scrollView.contentSize.width * scale, scrollView.contentSize.height);
        [UIView animateWithDuration:0.25 animations:^(void){
            self.alpha = 1.0;
        }];
    }];
};

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //NSLog(@"Scrolling offset: %.0fx%.0f", scrollView.contentOffset.x, scrollView.contentOffset.y);
    //[weightGraphXAxisView setNeedsDisplay];
    //weightGraphXAxisView.center = CGPointMake(-scrollView.contentOffset.x + weightGraphXAxisView.frame.size.width/2, weightGraphXAxisView.center.y);
}; 



@end
