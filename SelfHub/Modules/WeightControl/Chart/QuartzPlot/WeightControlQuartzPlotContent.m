//
//  WeightControlQuartzPlot.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 10.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeightControlQuartzPlotContent.h"

#define ONE_DAY     (24.0 * 60.0 * 60.0)
#define ONE_WEEK    (7.0 * 24.0 * 60.0 * 60.0)
#define ONE_MONTH    (31.0 * 24.0 * 60.0 * 60.0)
#define ONE_YEAR    (365.0 * 24.0 * 60.0 * 60.0)

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
        NSTimeInterval oneDay = 24 * 60 * 60;
        [self setAutoresizingMask:UIViewAutoresizingNone];
        self.layer.anchorPoint = CGPointMake(0, 0);
        self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.opaque = YES;
        drawingOffset = 100.0;
        verticalGridLinesInterval = 50.0f;
        verticalGridLinesWidth = 0.5f;
        timeDimension = oneDay / verticalGridLinesInterval;
        timeStep = oneDay;
        
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
    NSDate *drawPlotFromDate = [[delegateWeight.weightData objectAtIndex:0] objectForKey:@"date"];
    NSDate *drawPlotToDate = [[delegateWeight.weightData lastObject] objectForKey:@"date"];
    NSArray *minMaxWeight = [self calcYRangeFromDates:drawPlotFromDate toDate:drawPlotToDate];
    yAxisFrom = [[minMaxWeight objectAtIndex:0] floatValue];
    yAxisTo = [[minMaxWeight objectAtIndex:1] floatValue];
    CGContextRef context = ctx;
    
    
    //---------- Drawing vertical grid lines ----------
    NSInteger pointsInOffsetZone = floor(drawingOffset*timeDimension / timeStep);
    float startDrawing = drawingOffset - (pointsInOffsetZone*timeStep)/timeDimension;
    
    CGContextSetLineWidth(context, verticalGridLinesWidth);
    CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    NSUInteger i = 0;
    //div_t dt = div((int)rect.origin.x, (int)verticalGridLinesInterval);
    float startXGrid = floor(rect.origin.x / verticalGridLinesInterval) * verticalGridLinesInterval + startDrawing;
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
    
    
//    NSLog(@"--- start drawing tile's plot (%.0f, %.0f, %.0f, %.0f) ---", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    //NSUInteger daysBetweenDates;
    float curWeight = [[[delegateWeight.weightData objectAtIndex:0] objectForKey:@"weight"] floatValue];
    //float plotXOffsetPx = plotXOffset * verticalGridLinesInterval;
    CGPoint curPoint, prevPoint;
    BOOL patchWasStarted = NO;
    prevPoint = CGPointMake(drawingOffset, [self convertWeightToY:curWeight]);
    if(drawingOffset >= rect.origin.x){
        CGContextMoveToPoint(context, prevPoint.x, prevPoint.y);
        patchWasStarted = YES;
//        NSLog(@"\t + First point is a start of path (%.0f, %.0f)!", prevPoint.x, prevPoint.y);
    }else{
//        NSLog(@"\t- Skipping first point (%.0f, %.0f)!", prevPoint.x, prevPoint.y);
    }
    NSTimeInterval dateInterval;
    for(i=1; i<[delegateWeight.weightData count];i++){
        curDate = [[delegateWeight.weightData objectAtIndex:i] objectForKey:@"date"];
        curWeight = [[[delegateWeight.weightData objectAtIndex:i] objectForKey:@"weight"] floatValue];
        dateInterval = [curDate timeIntervalSinceDate:drawPlotFromDate];
        curPoint = CGPointMake((dateInterval / timeDimension) + drawingOffset, [self convertWeightToY:curWeight]);
        
        if(curPoint.x < rect.origin.x){     //tile's outside points
            prevPoint = curPoint;
//            NSLog(@"\t - point #%d (%.0f, %.0f) - skipped because outside", i, curPoint.x, curPoint.y);
            continue;
        };
        if(curPoint.x >= rect.origin.x && curPoint.x <= rect.origin.x + rect.size.width){    //tile's inside points
            if(patchWasStarted==NO){
                CGContextMoveToPoint(context, prevPoint.x, prevPoint.y);
                patchWasStarted = YES;
//                NSLog(@"\t + point #%d (%.0f, %.0f) - begin path from previous point", i, prevPoint.x, prevPoint.y);
            }else{
                CGContextAddLineToPoint(context, prevPoint.x, prevPoint.y);
//                NSLog(@"\t + point #%d (%.0f, %.0f) - continue path from previous point", i, prevPoint.x, prevPoint.y);
            };
            //
            prevPoint = curPoint;
        };
        if(curPoint.x > rect.origin.x + rect.size.width || i==[delegateWeight.weightData count]-1){   //last point
            if(patchWasStarted==NO){
                CGContextMoveToPoint(context, prevPoint.x, prevPoint.y);
                patchWasStarted = YES;
//                NSLog(@"\t + point #%d (%.0f, %.0f) - begin path from previous point", i, prevPoint.x, prevPoint.y);
            }else{
                CGContextAddLineToPoint(context, prevPoint.x, prevPoint.y);
//                NSLog(@"\t + point #%d (%.0f, %.0f) - continue path from previous point", i, prevPoint.x, prevPoint.y);
            };
            
//            NSLog(@"\t + point #%d (%.0f, %.0f) - continue path with LAST point", i, curPoint.x, curPoint.y);
            CGContextAddLineToPoint(context, curPoint.x, curPoint.y);
            break;
        };
    };
    CGContextDrawPath(context, kCGPathStroke);
    
    //---------- Drawing data-points ----------
    for(i=0; i<[delegateWeight.weightData count]; i++){
        // drawing point
        curDate = [[delegateWeight.weightData objectAtIndex:i] objectForKey:@"date"];
        curWeight = [[[delegateWeight.weightData objectAtIndex:i] objectForKey:@"weight"] floatValue];
        dateInterval = [curDate timeIntervalSinceDate:drawPlotFromDate];
        curPoint = CGPointMake((dateInterval / timeDimension) + drawingOffset, [self convertWeightToY:curWeight]);
        
        if(curPoint.x >= rect.origin.x && curPoint.x <= rect.origin.x + rect.size.width){
            CGContextAddEllipseInRect(context, CGRectMake(curPoint.x-weightPointRadius, curPoint.y-weightPointRadius, 2*weightPointRadius, 2*weightPointRadius));   //data-point
        };
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
    minWeight = floor(minWeight-expandRange);
    maxWeight = ceil(maxWeight+expandRange);
    float yStep = (maxWeight - minWeight )/ 8;
    horizontalGridLinesInterval = self.frame.size.height * (yStep) / (maxWeight - minWeight);
    
    return [NSArray arrayWithObjects:[NSNumber numberWithFloat:minWeight], [NSNumber numberWithFloat:maxWeight], nil];
};

- (float)convertWeightToY:(float)weight{
    return self.frame.size.height - (self.frame.size.height * (weight - yAxisFrom)) / (yAxisTo - yAxisFrom);
};

- (NSUInteger)daysFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate{
    NSTimeInterval intervalBetweenDates = [toDate timeIntervalSinceDate:fromDate];
    NSTimeInterval oneDay = 60 * 60 * 24;
    
    return intervalBetweenDates / oneDay;
};

- (void)performUpdatePlot{
    [self setNeedsDisplay];
    weightGraphXAxisView.startTimeInterval = [[[delegateWeight.weightData objectAtIndex:0] objectForKey:@"date"] timeIntervalSince1970];
    weightGraphXAxisView.step = timeStep;
    weightGraphXAxisView.verticalGridLinesInterval = verticalGridLinesInterval;
    weightGraphXAxisView.isZooming = NO;
    weightGraphXAxisView.zoomScale = previousScale;
    weightGraphXAxisView.drawingOffset = drawingOffset;
    weightGraphXAxisView.timeDimension = timeDimension;
    [weightGraphXAxisView setNeedsDisplay];
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
    
    //[weightGraphXAxisView setNeedsDisplay];

    transform.d = 1.0f;
    [super setTransform:transform];
    [weightGraphXAxisView setTransform:transform];
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
    if(timeDimension < 500.0){
        scrollView.zoomScale = previousScale;
    }else{
        previousScale = scrollView.zoomScale;
    };
    [self setNeedsDisplayInRect:CGRectMake(scrollView.contentOffset.x - scrollView.frame.size.width, 0, scrollView.frame.size.width*3, scrollView.frame.size.height)];
};

// scale between minimum and maximum. called after any 'bounce' animations
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale{
    //NSLog(@"Zoom: %.3f. Content-offset: %.0fx%.0f, frame = (%.0f, %.0f, %.0f, %.0f)", scale, scrollView.contentOffset.x, scrollView.contentOffset.y, self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    //CGAffineTransform transform = CGAffineTransformIdentity;
    //NSLog(@"Identity transform: a = %.2f, b = %.2f, c = %.2f, d = %.2f, tx = %.2f, ty = %.2f", transform.a, transform.b, transform.c, transform.d, transform.tx, transform.ty);
    CGPoint currentOffset = scrollView.contentOffset;
    currentOffset.x *= scale;
    [self setTransform:CGAffineTransformIdentity];
    self.frame = CGRectMake(0, 0, self.frame.size.width*scale, self.frame.size.height);
    weightGraphXAxisView.frame = CGRectMake(weightGraphXAxisView.frame.origin.x, weightGraphXAxisView.frame.origin.y, self.frame.size.width, weightGraphXAxisView.frame.size.height);
    //scrollView.contentOffset = CGPointMake(currentOffset.x, currentOffset.y);
    //[self setNeedsDisplayInRect:CGRectMake(scrollView.contentOffset.x - scrollView.frame.size.width, 0, scrollView.frame.size.width*3, scrollView.frame.size.height)];
    
    // Updating grid lines dimension
    
    previousScale = scale;
    verticalGridLinesInterval *= scale;
    timeDimension = timeStep / verticalGridLinesInterval;
    NSTimeInterval timeStep_new = timeStep;
    NSLog(@"scrollViewDidEndZooming: timeDimension = %.2f", timeDimension);
    if(timeDimension < 5000.0){                                         // 1 day between vertical grid lines
        timeStep_new = ONE_DAY;
    }else if(timeDimension >= 5000.0 && timeDimension < 10000.0){       // 1 week between vertical grid lines
        timeStep_new = ONE_WEEK;    
    }else if(timeDimension >= 10000.0 && timeDimension < 100000.0){     // 1 month between vertical grid lines
        timeStep_new = ONE_MONTH;
    }else if(timeDimension >= 100000.0){                                // 1 year between vertical grid lines
        timeStep_new = ONE_YEAR;
    };
    verticalGridLinesInterval = (timeStep_new * verticalGridLinesInterval) / timeStep;
    timeStep = timeStep_new;
    
    
    weightGraphXAxisView.startTimeInterval = [[[delegateWeight.weightData objectAtIndex:0] objectForKey:@"date"] timeIntervalSince1970];
    weightGraphXAxisView.step = timeStep;
    weightGraphXAxisView.verticalGridLinesInterval = verticalGridLinesInterval;
    weightGraphXAxisView.isZooming = NO;
    weightGraphXAxisView.zoomScale = scale;
    weightGraphXAxisView.drawingOffset = drawingOffset;
    weightGraphXAxisView.timeDimension = timeDimension;
    [weightGraphXAxisView setNeedsDisplay];
    self.layer.opacity = 1.0f;
    [UIView animateWithDuration:0.25 animations:^(void){
        self.alpha = 0.0; 
    }completion:^(BOOL finished){
        [self setNeedsDisplay];
        //scrollView.contentSize = CGSizeMake(scrollView.contentSize.width * scale, scrollView.contentSize.height);
        scrollView.contentSize = self.frame.size;
        //weightGraphXAxisView.frame = CGRectMake(weightGraphXAxisView.frame.size.height, 0, self.frame.size.width, weightGraphXAxisView.frame.size.height);
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
