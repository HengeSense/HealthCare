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
#define MINIMUM_TIME_DIMENSION 500.0
#define MAXIMUM_TIME_DIMENSION 200000.0

#define SWAP_FLOAT(x, y) { float __tmp = x; x = y; y = __tmp; }

@implementation WeightControlQuartzPlotTiledLayer

@dynamic layerStartWeight;
@dynamic layerFinishWeight;
@dynamic layerHorizontalGridLinesInterval;
@dynamic layerNumOfHorizontalLines;

+ (NSTimeInterval)fadeDuration{
    return 0.1f;
};

+ (BOOL)needsDisplayForKey:(NSString *)key{
    if( [key isEqualToString:@"layerStartWeight"] ||
       [key isEqualToString:@"layerFinishWeight"] ||
       [key isEqualToString:@"layerHorizontalGridLinesInterval"] ||
       [key isEqualToString:@"layerNumOfHorizontalLines"])
    {
        return YES;
    }else{
        return [super needsDisplayForKey:key];
    };
};

- (void)setContentsScale:(CGFloat)contentsScale{
    contentsScale = 1.0;
};


@end

@implementation WeightControlQuartzPlotContent
//@synthesize layer;

@synthesize delegate, delegateWeight, weightGraphYAxisView, weightGraphXAxisView;

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
        //NSLog(@"PlotContent self-frame testing #1: (%.0f, %.0f, %.0f, %.0f)", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        // Initialization code
        //[self setContentMode:UIViewContentModeTopLeft];
        NSTimeInterval oneDay = 24 * 60 * 60;
        [self setAutoresizingMask:UIViewAutoresizingNone];
        self.layer.anchorPoint = CGPointMake(0, 0);
        self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.opaque = YES;
        self.backgroundColor = [UIColor whiteColor];
        //self.clearsContextBeforeDrawing = YES;
        drawingOffset = 100.0;
        verticalGridLinesInterval = 50.0f;
        verticalGridLinesWidth = 0.5f;
        timeDimension = oneDay / verticalGridLinesInterval;
        timeStep = oneDay;
        
        horizontalGridLinesInterval = 30.0f;
        horizontalGridLinesWidth = 0.5f;
        
        plotXOffset = 2;
        plotYExpandFactor = 0.2f;
        weightLineWidth = 2.0f;
        weightPointRadius = 2;
        
        previousScale = 1.0f;
        
        self.contentScaleFactor = 1.0;
        //self.layer.opacity = 0.2f;
        
        [self setClearsContextBeforeDrawing:NO];
        CATiledLayer *currentLayer = (CATiledLayer *)self.layer;
        currentLayer.contentsScale = 1.0;
        [currentLayer setTileSize:CGSizeMake(320*currentLayer.contentsScale, self.frame.size.height*currentLayer.contentsScale)];
        [currentLayer setOpaque:YES];
        currentLayer.backgroundColor = [[UIColor whiteColor] CGColor];
        
        //[(CATiledLayer *)self.layer setLevelsOfDetail:10];
        //[(CATiledLayer *)self.layer setLevelsOfDetailBias:3];
        //NSLog(@"Tile size: %.0fx%.0f", [((CATiledLayer *)self.layer) tileSize].width, [((CATiledLayer *)self.layer) tileSize].height);
        
    }
    return self;
};

- (void)updateXYRangesValues{
    NSTimeInterval drawPlotFromInt;
    NSTimeInterval drawPlotToInt;
    CGPoint mySz = delegate.scrollView.contentOffset;
    if([delegateWeight.weightData count]==0){
        drawPlotFromInt = [[NSDate date] timeIntervalSince1970];
        drawPlotToInt = [[NSDate date] timeIntervalSince1970];
    }else{
        NSTimeInterval firstPointInt = [[[delegateWeight.weightData objectAtIndex:0] objectForKey:@"date"] timeIntervalSince1970];
        drawPlotFromInt = firstPointInt + (mySz.x-(mySz.x>drawingOffset ? drawingOffset : 0.0)) * timeDimension;
        drawPlotToInt = drawPlotFromInt + delegate.frame.size.width * timeDimension;
    };
    
    NSArray *minMaxWeight = [self calcYRangeFromTimeInterval:drawPlotFromInt toTimeInterval:drawPlotToInt]; // [self calcYRangeFromDates:drawPlotFromDate toDate:drawPlotToDate];
    float newYAxisFrom = [[minMaxWeight objectAtIndex:0] floatValue];
    float newYAxisTo = [[minMaxWeight objectAtIndex:1] floatValue];
    float linesInt = [[minMaxWeight objectAtIndex:2] floatValue];
    float numHorizLines = [[minMaxWeight objectAtIndex:3] unsignedIntegerValue];
    
    /*float expandRange = (newYAxisTo - newYAxisFrom) * 0.3;
    if(newYAxisFrom<yAxisFrom){
        newYAxisFrom -= expandRange;
    };
    if(newYAxisTo>yAxisTo){
        newYAxisTo += expandRange;
    };*/
    
    
    // Redraw visible plot if Y-axis range was significant changed
    if(fabs(newYAxisFrom-yAxisFrom)>0.3 || fabs(newYAxisTo-yAxisTo)>0.3){
        yAxisFrom = newYAxisFrom;
        yAxisTo = newYAxisTo;
        horizontalGridLinesInterval = linesInt;
        numOfHorizontalLines = numHorizLines;
        //[self setNeedsDisplayInRect:CGRectMake(delegate.scrollView.contentOffset.x, 0, delegate.scrollView.contentOffset.x+self.frame.size.width, self.frame.size.height)];
        
        
        //---------- Drawing vertical axis with labels ----------
        VerticalAxisLayer *myVerticalLayer = (VerticalAxisLayer *)weightGraphYAxisView.layer;
        WeightControlQuartzPlotTiledLayer *myContentLayer = (WeightControlQuartzPlotTiledLayer *)self.layer;
        
        NSTimeInterval duration =0.3;
        CABasicAnimation *animation1, *animation2, *animation3, *animation4;
        animation1 = [CABasicAnimation animationWithKeyPath:@"layerStartWeight"];
        animation1.duration = duration;
        animation1.repeatCount = 0;
        animation1.autoreverses = NO;
        animation1.fromValue = [NSNumber numberWithFloat:myVerticalLayer.layerStartWeight];
        animation1.toValue = [NSNumber numberWithFloat:yAxisFrom];
        
        animation2 = [CABasicAnimation animationWithKeyPath:@"layerFinishWeight"];
        animation2.duration = duration;
        animation2.repeatCount = 0;
        animation2.autoreverses = NO;
        animation2.fromValue = [NSNumber numberWithFloat:myVerticalLayer.layerFinishWeight];
        animation2.toValue = [NSNumber numberWithFloat:yAxisTo];
        
        animation3 = [CABasicAnimation animationWithKeyPath:@"layerHorizontalGridLinesInterval"];
        animation3.duration = duration;
        animation3.repeatCount = 0;
        animation3.autoreverses = NO;
        animation3.fromValue = [NSNumber numberWithFloat:myVerticalLayer.layerHorizontalGridLinesInterval];
        animation3.toValue = [NSNumber numberWithFloat:horizontalGridLinesInterval];
        
        animation4 = [CABasicAnimation animationWithKeyPath:@"layerNumOfHorizontalLines"];
        animation4.duration = duration;
        animation4.repeatCount = 0;
        animation4.autoreverses = NO;
        animation4.fromValue = [NSNumber numberWithUnsignedInteger:myVerticalLayer.layerNumOfHorizontalLines];
        animation4.toValue = [NSNumber numberWithUnsignedInteger:numOfHorizontalLines];
        
        CAAnimationGroup *animationGroup = [[CAAnimationGroup alloc] init];
        animationGroup.animations = [NSArray arrayWithObjects:animation1, animation2, animation3, animation4, nil];
        animationGroup.duration = duration;
        animationGroup.repeatCount = 0;
        animationGroup.autoreverses = NO;
        //[myVerticalLayer removeAllAnimations];
        [myVerticalLayer addAnimation:animationGroup forKey:nil];
        //[myContentLayer removeAllAnimations];
        [myContentLayer addAnimation:animationGroup forKey:nil];
        [animationGroup release];
        
        
        weightGraphYAxisView.startWeight = yAxisFrom;
        weightGraphYAxisView.finishWeight = yAxisTo;
        weightGraphYAxisView.horizontalGridLinesInterval = horizontalGridLinesInterval;
        weightGraphYAxisView.numOfHorizontalLines = numOfHorizontalLines;
        
        myVerticalLayer.layerStartWeight = yAxisFrom;
        myVerticalLayer.layerFinishWeight = yAxisTo;
        myVerticalLayer.layerHorizontalGridLinesInterval = horizontalGridLinesInterval;
        myVerticalLayer.layerNumOfHorizontalLines = numOfHorizontalLines;
        
        myContentLayer.layerStartWeight = yAxisFrom;
        myContentLayer.layerFinishWeight = yAxisTo;
        myContentLayer.layerHorizontalGridLinesInterval = horizontalGridLinesInterval;
        myContentLayer.layerNumOfHorizontalLines = numOfHorizontalLines;
        
        
        NSLog(@"New Y-axis range: (%.1f...%.1f)", yAxisFrom, yAxisTo);
    };
    
};


- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
//- (void)drawRect:(CGRect)rect{
    time_t startClock = clock();
    //NSLog(@"PlotContent self-frame testing #2: (%.0f, %.0f, %.0f, %.0f)", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    //NSLog(@"PlotContent offset testing: (%.0fx%.0f)", mySz.x, mySz.y);
    
    // Get layer parameters
    WeightControlQuartzPlotTiledLayer *myLayer = (WeightControlQuartzPlotTiledLayer *)layer;
    float yAxisFrom_layerdata = myLayer.layerStartWeight;
    float yAxisTo_layerdata = myLayer.layerFinishWeight;
    float horizontalGridLinesInterval_layerdata = myLayer.layerHorizontalGridLinesInterval;
    NSUInteger numOfHorizontalLines_layerdata = myLayer.layerNumOfHorizontalLines;
    
    
    CGRect rect = CGContextGetClipBoundingBox(ctx);
    CGContextRef context = ctx;
    
    //CGContextRef context = UIGraphicsGetCurrentContext();

    
    // Clear background
    CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(ctx, rect);
    
    //---------- Getting common parameters ----------
    NSDate *drawPlotFromDate;
    if([delegateWeight.weightData count]==0){
        drawPlotFromDate = [NSDate date];
    }else{
        drawPlotFromDate = [[delegateWeight.weightData objectAtIndex:0] objectForKey:@"date"];
    };
    NSUInteger i = 0;
    
    
    //---------- Drawing vertical grid lines ----------
    NSInteger pointsInOffsetZone = floor(drawingOffset * timeDimension / timeStep);
    float startDrawing = drawingOffset - (pointsInOffsetZone*timeStep)/timeDimension;
    
    CGContextSetLineWidth(context, verticalGridLinesWidth);
    CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    float correctForBeginMonthYear = 0.0;
    NSDate *firstDate;
    if(timeStep==ONE_MONTH){
        if([delegateWeight.weightData count]==0){
            firstDate = [NSDate date];
        }else{
            firstDate = [[delegateWeight.weightData objectAtIndex:0] objectForKey:@"date"];
        };
        correctForBeginMonthYear = ([firstDate timeIntervalSince1970] - [weightGraphXAxisView firstDayOfMonth:[firstDate timeIntervalSince1970]]) / timeDimension;
    }
    if(timeStep==ONE_YEAR){
        if([delegateWeight.weightData count]==0){
            firstDate = [NSDate date];
        }else{
            firstDate = [[delegateWeight.weightData objectAtIndex:0] objectForKey:@"date"];
        };
        correctForBeginMonthYear = ([firstDate timeIntervalSince1970] - [weightGraphXAxisView firstDayOfYear:[firstDate timeIntervalSince1970]]) / timeDimension;
    }
    float startXGrid = floor(rect.origin.x / verticalGridLinesInterval) * verticalGridLinesInterval + startDrawing - correctForBeginMonthYear;
    float i_float;
    for(i_float = startXGrid; i_float< rect.origin.x+rect.size.width; i_float+=verticalGridLinesInterval){
        CGContextMoveToPoint(context, i_float, rect.origin.y);
        CGContextAddLineToPoint(context, i_float, rect.origin.y+rect.size.height-15.0f);
    }
    CGContextStrokePath(context);
    
    
    //---------- Drawing horizontal grid lines ----------
    CGContextSetLineWidth(context, horizontalGridLinesWidth);
    CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    float curYCoord;
    for(i=0;i<numOfHorizontalLines_layerdata;i++){
        curYCoord = self.frame.size.height - i*horizontalGridLinesInterval_layerdata;
        
        CGContextMoveToPoint(context, rect.origin.x, curYCoord);
        CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, curYCoord);
    };
    CGContextStrokePath(context);
    
    
    
    //---------- Drawing normal weight line ----------
    CGFloat normalWeight = [delegateWeight.normalWeight floatValue];
    if(normalWeight != NAN){
        CGContextSetLineWidth(context, 0.8f);
        CGContextSetStrokeColorWithColor(context, [[UIColor orangeColor] CGColor]);
        CGFloat dashForNormLine[] = {5.0F, 5.0f};
        CGContextSetLineDash(context, 0.0f, dashForNormLine, 2);
        CGContextMoveToPoint(context, rect.origin.x, [self convertWeightToY:normalWeight forYFrom:yAxisFrom_layerdata andYTo:yAxisTo_layerdata]);
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, [self convertWeightToY:normalWeight forYFrom:yAxisFrom_layerdata andYTo:yAxisTo_layerdata]);
        CGContextStrokePath(context);
    };
    
    
    //---------- Drawing aim weight line ----------
    CGFloat aimWeight = [delegateWeight.aimWeight floatValue];
    if(aimWeight != NAN){
        CGContextSetLineWidth(context, 0.8f);
        CGContextSetStrokeColorWithColor(context, [[UIColor greenColor] CGColor]);
        CGFloat dashForNormLine[] = {5.0F, 5.0f};
        CGContextSetLineDash(context, rect.origin.x, dashForNormLine, 2);
        CGContextMoveToPoint(context, 32.0f, [self convertWeightToY:aimWeight forYFrom:yAxisFrom_layerdata andYTo:yAxisTo_layerdata]);
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, [self convertWeightToY:aimWeight forYFrom:yAxisFrom_layerdata andYTo:yAxisTo_layerdata]);
        CGContextStrokePath(context);
    };
    
    if([delegateWeight.weightData count]==0) return;    //Dont't try to draw plot if we haven't any weight points
    
    
    
    
    //---------- Drawing trend and weight lines ----------
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, weightLineWidth);
    CGContextSetLineDash(context, 0, NULL, 0);
    CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
    
    NSDate *curDate;                     
    
    float curWeight = [[[delegateWeight.weightData objectAtIndex:0] objectForKey:@"weight"] floatValue];
    float curTrend;
    CGPoint curPoint, prevPoint;
    BOOL patchWasStarted = NO;
    prevPoint = CGPointMake(drawingOffset, [self convertWeightToY:curWeight]);
    if(drawingOffset >= rect.origin.x){
        CGContextMoveToPoint(context, prevPoint.x, prevPoint.y);
        patchWasStarted = YES;
    }else{
        
    }
    NSTimeInterval dateInterval;
    //---------- Drawing trend line ----------
    for(i=1; i<[delegateWeight.weightData count];i++){
        curDate = [[delegateWeight.weightData objectAtIndex:i] objectForKey:@"date"];
        curTrend = [[[delegateWeight.weightData objectAtIndex:i] objectForKey:@"trend"] floatValue];
        dateInterval = [curDate timeIntervalSinceDate:drawPlotFromDate];
        curPoint = CGPointMake((dateInterval / timeDimension) + drawingOffset, [self convertWeightToY:curTrend forYFrom:yAxisFrom_layerdata andYTo:yAxisTo_layerdata]);
        
        if(curPoint.x < rect.origin.x){     //tile's outside points
            prevPoint = curPoint;
            
            continue;
        };
        if(curPoint.x >= rect.origin.x && curPoint.x <= rect.origin.x + rect.size.width){    //tile's inside points
            if(patchWasStarted==NO){
                CGContextMoveToPoint(context, prevPoint.x, prevPoint.y);
                patchWasStarted = YES;
            }else{
                CGContextAddLineToPoint(context, prevPoint.x, prevPoint.y);
            };
            prevPoint = curPoint;
        };
        if(curPoint.x > rect.origin.x + rect.size.width || i==[delegateWeight.weightData count]-1){   //last point
            if(patchWasStarted==NO){
                CGContextMoveToPoint(context, prevPoint.x, prevPoint.y);
                patchWasStarted = YES;
            }else{
                CGContextAddLineToPoint(context, prevPoint.x, prevPoint.y);
            };
            
            CGContextAddLineToPoint(context, curPoint.x, curPoint.y);
            break;
        };
    };
    CGContextDrawPath(context, kCGPathStroke);
    
    
    
    
    //---------- Drawing data-points ----------
    CGContextSetLineWidth(context, weightLineWidth/2.0);
    CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    for(i=0; i<[delegateWeight.weightData count]; i++){
        // drawing point
        curDate = [[delegateWeight.weightData objectAtIndex:i] objectForKey:@"date"];
        curTrend = [[[delegateWeight.weightData objectAtIndex:i] objectForKey:@"trend"] floatValue];
        curWeight = [[[delegateWeight.weightData objectAtIndex:i] objectForKey:@"weight"] floatValue];
        dateInterval = [curDate timeIntervalSinceDate:drawPlotFromDate];
        curPoint = CGPointMake((dateInterval / timeDimension) + drawingOffset, [self convertWeightToY:curWeight forYFrom:yAxisFrom_layerdata andYTo:yAxisTo_layerdata]);
        
        if(curPoint.x >= rect.origin.x && curPoint.x <= rect.origin.x + rect.size.width){
            prevPoint = CGPointMake((dateInterval / timeDimension) + drawingOffset, [self convertWeightToY:curTrend forYFrom:yAxisFrom_layerdata andYTo:yAxisTo_layerdata]);
            
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, prevPoint.x, prevPoint.y);
            CGContextAddLineToPoint(context, curPoint.x, curPoint.y);
            CGContextDrawPath(context, kCGPathStroke);
            
            CGContextBeginPath(context);
            CGContextAddEllipseInRect(context, CGRectMake(curPoint.x-weightPointRadius, curPoint.y-weightPointRadius, 2*weightPointRadius, 2*weightPointRadius));   //data-point
            CGContextSetFillColorWithColor(context, (curWeight<curTrend ? [[UIColor greenColor] CGColor] : [[UIColor redColor] CGColor]));
            CGContextDrawPath(context, kCGPathFillStroke);
        };
    };
    
    
    //---------- Drawing trend forecast line ----------
    if([delegateWeight.weightData count]>1){
        curDate = [[delegateWeight.weightData lastObject] objectForKey:@"date"];
        curTrend = [[[delegateWeight.weightData lastObject] objectForKey:@"trend"] floatValue];
        dateInterval = [curDate timeIntervalSinceDate:drawPlotFromDate];
        curPoint = CGPointMake((dateInterval / timeDimension) + drawingOffset, [self convertWeightToY:curTrend forYFrom:yAxisFrom_layerdata andYTo:yAxisTo_layerdata]);
        if(rect.origin.x+rect.size.width > curPoint.x){
            NSTimeInterval timeToAim = [delegateWeight getTimeIntervalToAim];
            if(!isnan(timeToAim)){
                dateInterval += timeToAim;
                float aim = [delegateWeight.aimWeight floatValue];
                CGPoint forecatPoint = CGPointMake((dateInterval / timeDimension) + drawingOffset, [self convertWeightToY:aim forYFrom:yAxisFrom_layerdata andYTo:yAxisTo_layerdata]);
                
                CGContextSetLineWidth(context, weightLineWidth);
                CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
                CGContextBeginPath(context);
                CGFloat dashForTrendForecastLine[] = {5.0f, 5.0f};
                CGContextSetLineDash(context, rect.origin.x, dashForTrendForecastLine, 2);
                CGContextMoveToPoint(context, curPoint.x, curPoint.y);
                CGContextAddLineToPoint(context, forecatPoint.x, forecatPoint.y);
                CGContextStrokePath(context);
            };
        };
        
    };
     

    time_t endClock = clock();
    NSLog(@"PLOT drawLayer: (%.0f, %.0f, %.0f, %.0f) - %.3f sec (scaleFactor = %.1f)", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height, (float)(endClock-startClock)/CLOCKS_PER_SEC, layer.contentsScale);
    
};


- (NSArray *)calcYRangeFromTimeInterval:(NSTimeInterval)fromInterval toTimeInterval:(NSTimeInterval)toInterval{
    if([delegateWeight.weightData count]==0){
        return [NSArray arrayWithObjects:[NSNumber numberWithFloat:30.0], [NSNumber numberWithFloat:100.0], nil];
    };
    
    NSUInteger i;
    float minWeight = 10000.0f, maxWeight = 0.0f;
    //BOOL firstPointInInterval = YES;
    float minValue, maxValue;
    for(i = 0; i<[delegateWeight.weightData count]; i++){
        if([[[delegateWeight.weightData objectAtIndex:i] objectForKey:@"date"] timeIntervalSince1970] >= fromInterval){
            minValue = [[[delegateWeight.weightData objectAtIndex:i] objectForKey:@"weight"] floatValue];
            maxValue = [[[delegateWeight.weightData objectAtIndex:i] objectForKey:@"trend"] floatValue];
            /*if(firstPointInInterval || [[[delegateWeight.weightData objectAtIndex:i] objectForKey:@"date"] timeIntervalSince1970] > toInterval){
                float w1, w2;
                NSTimeInterval w1w2Int, w1xInt;
                if([delegateWeight.weightData count]!=0){
                    //Calcing proportional weight
                    w1 = minValue;
                    w2 = [[[delegateWeight.weightData objectAtIndex:i-1] objectForKey:@"weight"] floatValue];
                    w1w2Int = [[[delegateWeight.weightData objectAtIndex:i] objectForKey:@"date"] timeIntervalSinceDate:[[delegateWeight.weightData objectAtIndex:i-1] objectForKey:@"date"]];
                    w1xInt = fromInterval - [[[delegateWeight.weightData objectAtIndex:i-1] objectForKey:@"date"] timeIntervalSince1970];
                    if(fabs(w1w2Int)>0.00001) minValue = (w1*w1w2Int + w2*w1xInt - w1*w1xInt) / w1w2Int;
                    //Calcing proportional trend
                    w1 = maxValue;
                    w2 = [[[delegateWeight.weightData objectAtIndex:i-1] objectForKey:@"trend"] floatValue];
                    w1w2Int = [[[delegateWeight.weightData objectAtIndex:i] objectForKey:@"date"] timeIntervalSinceDate:[[delegateWeight.weightData objectAtIndex:i-1] objectForKey:@"date"]];
                    w1xInt = fromInterval - [[[delegateWeight.weightData objectAtIndex:i-1] objectForKey:@"date"] timeIntervalSince1970];
                    if(fabs(w1w2Int)>0.00001) maxValue = (w1*w1w2Int + w2*w1xInt - w1*w1xInt) / w1w2Int;
                };
                firstPointInInterval = NO;
            };
            
            if([[[delegateWeight.weightData objectAtIndex:i] objectForKey:@"date"] timeIntervalSince1970] > toInterval){
                float w1, w2;
                NSTimeInterval w1w2Int, w1xInt;
                if([delegateWeight.weightData count]!=0){
                    //Calcing proportional weight
                    w1 = minValue;
                    w2 = [[[delegateWeight.weightData objectAtIndex:i-1] objectForKey:@"weight"] floatValue];
                    w1w2Int = [[[delegateWeight.weightData objectAtIndex:i] objectForKey:@"date"] timeIntervalSinceDate:[[delegateWeight.weightData objectAtIndex:i-1] objectForKey:@"date"]];
                    w1xInt = fromInterval - [[[delegateWeight.weightData objectAtIndex:i-1] objectForKey:@"date"] timeIntervalSince1970];
                    if(fabs(w1w2Int)>0.00001) minValue = (w1*w1w2Int + w2*w1xInt - w1*w1xInt) / w1w2Int;
                    //Calcing proportional trend
                    w1 = maxValue;
                    w2 = [[[delegateWeight.weightData objectAtIndex:i-1] objectForKey:@"trend"] floatValue];
                    w1w2Int = [[[delegateWeight.weightData objectAtIndex:i] objectForKey:@"date"] timeIntervalSinceDate:[[delegateWeight.weightData objectAtIndex:i-1] objectForKey:@"date"]];
                    w1xInt = fromInterval - [[[delegateWeight.weightData objectAtIndex:i-1] objectForKey:@"date"] timeIntervalSince1970];
                    if(fabs(w1w2Int)>0.00001) maxValue = (w1*w1w2Int + w2*w1xInt - w1*w1xInt) / w1w2Int;
                };
            }*/
            
            if(maxValue<minValue) SWAP_FLOAT(minValue, maxValue);
            
            if(minValue < minWeight) minWeight = minValue;
            if(maxValue > maxWeight) maxWeight = maxValue;
            
            //NSLog(@"%d: MinMaxCurValues=(%.1f, %.1f), MinMaxTotalValues=(%.1f, %.1f)", i, minValue, maxValue, minWeight, maxWeight);
        };
        
        if([[[delegateWeight.weightData objectAtIndex:i] objectForKey:@"date"] timeIntervalSince1970] > toInterval){
            break;
        };
    };
    
    if(!isnan([delegateWeight.normalWeight floatValue])){
        if([delegateWeight.normalWeight floatValue] < minWeight) minWeight = [delegateWeight.normalWeight floatValue];
        if([delegateWeight.normalWeight floatValue] > maxWeight) maxWeight = [delegateWeight.normalWeight floatValue];
    };
    if(!isnan([delegateWeight.aimWeight floatValue])){
        if([delegateWeight.aimWeight floatValue] < minWeight) minWeight = [delegateWeight.aimWeight floatValue];
        if([delegateWeight.aimWeight floatValue] > maxWeight) maxWeight = [delegateWeight.aimWeight floatValue];
    };
    
    float expandRange = (maxWeight - minWeight) * (plotYExpandFactor / 2);
    minWeight = minWeight-expandRange; //floor(minWeight-expandRange);
    maxWeight = maxWeight+expandRange; //ceil(maxWeight+expandRange);
    float yStep = 0.5;
    if(maxWeight-minWeight>20.0) yStep = 1.0;
    //float weightCorrect = floor((weightGraphXAxisView.frame.size.height * yStep) / ((self.frame.size.height * (yStep)) / (maxWeight - minWeight)));
    //minWeight -= weightCorrect;
    float horizLinesInt = (self.frame.size.height * (yStep)) / (maxWeight - minWeight);
    NSUInteger numHorizLines = (NSUInteger)((float)self.frame.size.height / (float)horizLinesInt);
    
    //NSLog(@"Calcing Y-axis range: [%.1f...%.1f], expandRange = %.1f", minWeight, maxWeight, expandRange);
    return [NSArray arrayWithObjects:[NSNumber numberWithFloat:minWeight], [NSNumber numberWithFloat:maxWeight], [NSNumber numberWithFloat:horizLinesInt], [NSNumber numberWithUnsignedInteger:numHorizLines], nil];
};

- (float)convertWeightToY:(float)weight{
    return self.frame.size.height - (self.frame.size.height * (weight - yAxisFrom)) / (yAxisTo - yAxisFrom);
};

- (float)convertWeightToY:(float)weight forYFrom:(float)curYFrom andYTo:(float)curYTo{
    return self.frame.size.height - (self.frame.size.height * (weight - curYFrom)) / (curYTo - curYFrom);
}

- (float)convertYToWeight:(float)yCoord{
    return ((self.frame.size.height - yCoord) * (yAxisTo - yAxisFrom) + self.frame.size.height*yAxisFrom) / self.frame.size.height;
};

- (NSTimeInterval)getTimeIntervalSince1970ForX:(float)xCoord{
    NSDate *firstDate;
    if([delegateWeight.weightData count]==0){
        firstDate = [NSDate date];
    }else{
        firstDate = [[delegateWeight.weightData objectAtIndex:0] objectForKey:@"date"];
    };
    NSTimeInterval firstPxTimeInterval = [firstDate timeIntervalSince1970] - drawingOffset * timeDimension;
    
    return firstPxTimeInterval + xCoord * timeDimension;
};

- (float)getXCoordForTimeIntervalSince1970:(NSTimeInterval)timeInt{
    NSDate *firstDate;
    if([delegateWeight.weightData count]==0){
        firstDate = [NSDate date];
    }else{
        firstDate = [[delegateWeight.weightData objectAtIndex:0] objectForKey:@"date"];
    };
    
    NSTimeInterval firstPxTimeInterval = [firstDate timeIntervalSince1970] - drawingOffset * timeDimension;
    
    if(timeInt < firstPxTimeInterval) return 0.0;
    
    return (timeInt - firstPxTimeInterval) / timeDimension;
};

- (NSUInteger)daysFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate{
    NSTimeInterval intervalBetweenDates = [toDate timeIntervalSinceDate:fromDate];
    NSTimeInterval oneDay = 60 * 60 * 24;
    
    return intervalBetweenDates / oneDay;
};

- (void)performUpdatePlot{
    [delegate.scrollView setContentSize:CGSizeMake([self calcOccupiedAreaWidth]+320.0, self.frame.size.height)];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, [self calcOccupiedAreaWidth]+320.0, self.frame.size.height);
    weightGraphXAxisView.frame = CGRectMake(weightGraphXAxisView.frame.origin.x, weightGraphXAxisView.frame.origin.y, [self calcOccupiedAreaWidth]+320.0, weightGraphXAxisView.frame.size.height);
    
    [self setNeedsDisplay];
    if([delegateWeight.weightData count]==0){
        weightGraphXAxisView.startTimeInterval = [[NSDate date] timeIntervalSince1970];
    }else{
        weightGraphXAxisView.startTimeInterval = [[[delegateWeight.weightData objectAtIndex:0] objectForKey:@"date"] timeIntervalSince1970];
    }
        
    weightGraphXAxisView.step = timeStep;
    weightGraphXAxisView.verticalGridLinesInterval = verticalGridLinesInterval;
    weightGraphXAxisView.isZooming = NO;
    weightGraphXAxisView.zoomScale = previousScale;
    weightGraphXAxisView.drawingOffset = drawingOffset;
    weightGraphXAxisView.timeDimension = timeDimension;
    [weightGraphXAxisView setNeedsDisplay];
    
    //---------- Drawing vertical axis with labels ----------
    weightGraphYAxisView.startWeight = yAxisFrom;
    weightGraphYAxisView.finishWeight = yAxisTo;
    weightGraphYAxisView.horizontalGridLinesInterval = horizontalGridLinesInterval;
    weightGraphYAxisView.numOfHorizontalLines = numOfHorizontalLines;
    [weightGraphYAxisView setNeedsDisplay];
};

- (void)zoomContentByFactor:(float)factor{
    //NSLog(@"Zooming by %.1f", factor);
    [delegate.scrollView setZoomScale:factor animated:YES];
    [delegate showZoomer];
};

- (float)calcOccupiedAreaWidth{
    if([delegateWeight.weightData count]==0){
        return 0.0;
    };
    
    NSTimeInterval firstDateInt = [[[delegateWeight.weightData objectAtIndex:0] objectForKey:@"date"] timeIntervalSince1970];
    NSTimeInterval lastDateInt = [[[delegateWeight.weightData lastObject] objectForKey:@"date"] timeIntervalSince1970];
    NSTimeInterval forecastInt = [delegateWeight getTimeIntervalToAim];
    if(isnan(forecastInt)) forecastInt = 0.0;
    
    return (lastDateInt - firstDateInt + forecastInt) / timeDimension;
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
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
    //NSLog(@"Zooming begin");
    //NSLog(@"Content offset: %.2f", scrollView.contentOffset.x);
    
    //delegate.scrollView.scrollEnabled = NO;
    weightGraphXAxisView.isZooming = YES;
    weightGraphXAxisView.zoomScale = scrollView.zoomScale;
    [weightGraphXAxisView setNeedsDisplay];
    
    [delegate hidePointer];
    [delegate hideZoomer];
};


// any zoom scale changes
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    //NSLog(@"Scrolling: content-offset: %.0f", scrollView.contentOffset.x);
};

// scale between minimum and maximum. called after any 'bounce' animations
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale{
    [self setTransform:CGAffineTransformIdentity];
    weightGraphXAxisView.frame = CGRectMake(weightGraphXAxisView.frame.origin.x, weightGraphXAxisView.frame.origin.y, self.frame.size.width, weightGraphXAxisView.frame.size.height);
    
    //scrollView.contentOffset = CGPointMake(currentOffset.x, currentOffset.y);
    //[self setNeedsDisplayInRect:CGRectMake(scrollView.contentOffset.x - scrollView.frame.size.width, 0, scrollView.frame.size.width*3, scrollView.frame.size.height)];
    
    // Updating grid lines dimension
    previousScale = scale;
    verticalGridLinesInterval *= scale;
    timeDimension = timeStep / verticalGridLinesInterval;
    NSTimeInterval timeStep_new = timeStep;
    NSLog(@"scrollViewDidEndZooming: timeDimension = %.2f, prevScale = %.2f", timeDimension, previousScale);
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
    
    
    [scrollView setContentSize:CGSizeMake([self calcOccupiedAreaWidth]+320.0, self.frame.size.height)];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, [self calcOccupiedAreaWidth]+320.0, self.frame.size.height);
    weightGraphXAxisView.frame = CGRectMake(weightGraphXAxisView.frame.origin.x, weightGraphXAxisView.frame.origin.y, [self calcOccupiedAreaWidth]+320.0, weightGraphXAxisView.frame.size.height);
    
    weightGraphXAxisView.startTimeInterval = [[[delegateWeight.weightData objectAtIndex:0] objectForKey:@"date"] timeIntervalSince1970];
    weightGraphXAxisView.step = timeStep;
    weightGraphXAxisView.verticalGridLinesInterval = verticalGridLinesInterval;
    weightGraphXAxisView.isZooming = NO;
    weightGraphXAxisView.zoomScale = scale;
    weightGraphXAxisView.drawingOffset = drawingOffset;
    weightGraphXAxisView.timeDimension = timeDimension;
    [weightGraphXAxisView setNeedsDisplay];
    
    
    
    [self setNeedsDisplay];
    
    if(timeDimension<MINIMUM_TIME_DIMENSION){
        scrollView.minimumZoomScale = 0.25;
        scrollView.maximumZoomScale = 1.0;
    }else if(timeDimension>MAXIMUM_TIME_DIMENSION){
        scrollView.minimumZoomScale = 1.0;
        scrollView.maximumZoomScale = 4.0;
    }else{
        scrollView.minimumZoomScale = 0.25;
        scrollView.maximumZoomScale = 4.0;
    };
};

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //NSLog(@"Scrolling offset: %.0fx%.0f", scrollView.contentOffset.x, scrollView.contentOffset.y);
    //[weightGraphXAxisView setNeedsDisplay];
    //weightGraphXAxisView.center = CGPointMake(-scrollView.contentOffset.x + weightGraphXAxisView.frame.size.width/2, weightGraphXAxisView.center.y);
    [self updateXYRangesValues];
    [delegate updatePointerDuringScrolling];
}; 



@end
