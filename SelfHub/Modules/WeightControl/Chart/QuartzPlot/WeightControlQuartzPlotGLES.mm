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

#define ONE_DAY     (24.0 * 60.0 * 60.0)
#define ONE_WEEK    (7.0 * 24.0 * 60.0 * 60.0)
#define ONE_MONTH    (31.0 * 24.0 * 60.0 * 60.0)
#define ONE_YEAR    (365.0 * 24.0 * 60.0 * 60.0)

@implementation WeightControlQuartzPlotGLES

@synthesize delegateWeight;


+ (Class)layerClass {
    return [CAEAGLLayer class];
};

- (id)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame andDelegate:nil];
};

- (id)initWithFrame:(CGRect)frame andDelegate:(WeightControl *)_delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        delegateWeight = _delegate;
        if(delegateWeight==nil){
            NSLog(@"WeightControlQuartzPlotGLES: initialize with nil-value delegate!");
        }
        
        fpsStr = nil;
        
        CAEAGLLayer* eaglLayer = (CAEAGLLayer*) super.layer;
        eaglLayer.opaque = YES;
        BOOL isRetina = NO;
        if([[UIScreen mainScreen] scale]==2.0) isRetina = YES;
        eaglLayer.contentsScale = isRetina ? 2.0 : 1.0;
        contentScale = eaglLayer.contentsScale;
        plotContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        if (!plotContext || ![EAGLContext setCurrentContext:plotContext]) {
            [self release];
            return nil;
        };
        
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setMonth:06];
        [dateComponents setDay:25];
        [dateComponents setYear:2012];
        [dateComponents setHour:0];
        [dateComponents setMinute:0];
        [dateComponents setSecond:0];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *firstDate = [gregorian dateFromComponents:dateComponents];
        [dateComponents release];
        [gregorian release];
        NSDate *lastDate = [NSDate date];

        
        
        myRender = CreateRendererForGLES1();
        [plotContext renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable: eaglLayer];
        RENDERER_TYPECAST(myRender)->Initialize(frame.size.width*eaglLayer.contentsScale, frame.size.height*eaglLayer.contentsScale);
        RENDERER_TYPECAST(myRender)->SetYAxisParams(70.0, 100.0, 1.5);
        
        float forecastTimeInt = [delegateWeight getTimeIntervalToAim];
        if(isnan(forecastTimeInt)) forecastTimeInt = 0.0;
        RENDERER_TYPECAST(myRender)->SetXAxisParams([firstDate timeIntervalSince1970], [lastDate timeIntervalSince1970] + forecastTimeInt);
        RENDERER_TYPECAST(myRender)->SetScaleX(1.0);
        RENDERER_TYPECAST(myRender)->SetOffsetTimeInterval(0.0);
        
        [self updatePlotLowLayerBase];
        
        //RENDERER_TYPECAST(myRender)->SetScaleY(0.95, false);
        
        
        
        
        pauseRedraw = NO;
        drawingsCounter = 0;
        CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView:)];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        [self drawView:nil];
        
        timestamp = CACurrentMediaTime();
        
        tmpVal = false;
        
        // Adding gesture recognizers for user interaction support
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGestureRecognizer:)];
        [self addGestureRecognizer:panGesture];
        [self addGestureRecognizer:pinchGesture];
        [panGesture release];
        [pinchGesture release];
        

    }
    return self;
}

- (NSTimeInterval)firstDayOfMonth:(NSTimeInterval)dateMonth{
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate dateWithTimeIntervalSince1970:dateMonth]];
    dateComponents.day = 1;
    //dateComponents.hour = 0;
    //dateComponents.minute = 0;
	
    NSDate *tmpDate = [gregorian dateFromComponents:dateComponents];
    //NSLog(@"tmpDate = %@", [tmpDate description]);
    NSTimeInterval ret = [tmpDate timeIntervalSince1970];
    [gregorian release];
    
    return ret;
};

- (NSTimeInterval)firstDayOfYear:(NSTimeInterval)dateYear{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)  fromDate:[NSDate dateWithTimeIntervalSince1970:dateYear]];
    dateComponents.month = 1;
    dateComponents.day = 1;
    dateComponents.hour = 0;
    dateComponents.minute = 0;

    NSTimeInterval ret = [[gregorian dateFromComponents:dateComponents] timeIntervalSince1970];
    [gregorian release];
    
    return ret;
};

- (NSDate *)dateFromComponents:(NSDateComponents *)dateComp{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [gregorian dateFromComponents:dateComp];
};

- (NSUInteger)dayOfMonthForDate:(NSDate *)testDate{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)  fromDate:testDate];
    [gregorian release];
    
    return dateComponents.day;
};


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setRedrawOpenGLPaused:(BOOL)_isPaused{
    pauseRedraw = _isPaused;
};

- (BOOL)isOpenGLPaused{
    return pauseRedraw;
};

- (void) drawView:(CADisplayLink*) displayLink{
    if(pauseRedraw) return;
    
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
    
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    
    // Y-Axis labels
    float firstGridPt, firstGridWeight, gridLinesStep, weightLinesStep;
    unsigned short linesNum;
    RENDERER_TYPECAST(myRender)->GetYAxisDrawParams(firstGridPt, firstGridWeight, gridLinesStep, weightLinesStep, linesNum);
    int i;
    NSString *weightStr = nil;
    Texture2D *weightLabel = nil;
    float fontSize;
    float weightAlpha = 1.0;
    //NSLog(@"firstGrigPt = %.1f", firstGridPt);
    float blurBottomLimit = self.frame.size.height * contentScale * 0.08;
    float curWeight;
    for(i=0;i<linesNum;i++){
        curWeight = firstGridWeight + i*weightLinesStep;
        weightStr = [[NSString alloc] initWithFormat:(fabs(curWeight - ceil(curWeight))>0.0001 ? @"%.1f" : @"%.0f"), curWeight];
        fontSize = ([weightStr length]>4 ? 11 : 12) * contentScale;
        weightLabel = [[Texture2D alloc] initWithString:weightStr dimensions:CGSizeMake(50*contentScale, 32) alignment:UITextAlignmentLeft fontName:@"Helvetica-Bold" fontSize:fontSize];
        if((firstGridPt + i*gridLinesStep)<=0){
            weightAlpha = RENDERER_TYPECAST(myRender)->FadeValue((firstGridPt + i*gridLinesStep), -(self.frame.size.height*contentScale/2.0 - blurBottomLimit), blurBottomLimit, 0.0, 1.0);
        }else{
            weightAlpha = RENDERER_TYPECAST(myRender)->FadeValue((firstGridPt + i*gridLinesStep), +(self.frame.size.height*contentScale/2.0 - blurBottomLimit*1.3), blurBottomLimit, 1.0, 0.0);
        };
        glColor4f(0.0, 0.0, 0.0, weightAlpha);
        [weightLabel drawAtPoint:CGPointMake(-(self.frame.size.width / 2.0-28) * contentScale, firstGridPt + i*gridLinesStep + 5*contentScale)];
        [weightLabel release];
        [weightStr release];
        
    };
    
    
    // X-Axis labels
    float firstGridXPt, firstGridXTimeInterval, gridXLinesStep, timeIntLinesStep;//, firstLabelCorrect = 0.0;
    unsigned short linesXNum;
    RENDERER_TYPECAST(myRender)->GetXAxisDrawParams(firstGridXPt, firstGridXTimeInterval, gridXLinesStep, timeIntLinesStep, linesXNum);
    //NSLog(@"X-Axis draw parameters: firstGrid: %.1f pt (ti = %.0f), gridStep: %.1f pt (ti = %.0f), numOfLines = %d", firstGridXPt, firstGridXTimeInterval, gridXLinesStep, timeIntLinesStep, linesXNum);
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    //NSDateFormatter *exclusiveDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    NSTimeInterval curTimeInterval;
    NSDate *curDate;
    NSString *curLabelXstr = nil;
    Texture2D *dateLabel;
    if(timeIntLinesStep==ONE_DAY){
        dateFormatter.dateFormat = @"dd";
        //exclusiveDateFormatter.dateFormat = @"dd MMM";
    }else if (timeIntLinesStep==ONE_WEEK){
        dateFormatter.dateFormat = @"dd";
    }else if (timeIntLinesStep>ONE_WEEK && timeIntLinesStep<2*ONE_MONTH){
        dateFormatter.dateFormat = @"MMM";
        float newFirstGridXTimeInterval = [self firstDayOfMonth:firstGridXTimeInterval];
        float correctFirstGridX = (gridXLinesStep * (firstGridXTimeInterval - newFirstGridXTimeInterval)) / timeIntLinesStep;
        firstGridXPt -= correctFirstGridX;
        linesXNum++;
        //NSLog(@"Correct first grid by %.0f px: (firstGridX = %.0f)", correctFirstGridX, firstGridXPt);
        if(firstGridXPt < -(self.frame.size.width/2)*contentScale){
            firstGridXPt += gridXLinesStep;
            firstGridXTimeInterval += timeIntLinesStep;
        };
    }else{
        dateFormatter.dateFormat = @"YYYY";
        float newFirstGridXTimeInterval = [self firstDayOfYear:firstGridXTimeInterval];
        float correctFirstGridX = (gridXLinesStep * (firstGridXTimeInterval - newFirstGridXTimeInterval)) / timeIntLinesStep;
        firstGridXPt -= correctFirstGridX;
        linesXNum++;
        if(firstGridXPt < -(self.frame.size.width/2)*contentScale){
            firstGridXPt += gridXLinesStep;
            firstGridXTimeInterval += timeIntLinesStep;
        };
    };
    NSString *logStr = @"";
    for(i=0; i<linesXNum; i++){
        curTimeInterval = firstGridXTimeInterval + i * timeIntLinesStep;
        if(timeIntLinesStep>ONE_WEEK && timeIntLinesStep<2*ONE_MONTH){
            curTimeInterval = [self firstDayOfMonth:curTimeInterval];
        }else if(timeIntLinesStep > 6*ONE_MONTH){
            curTimeInterval = [self firstDayOfYear:curTimeInterval];
        }
        
        curDate = [NSDate dateWithTimeIntervalSince1970:curTimeInterval];
        
        curLabelXstr = [dateFormatter stringFromDate:curDate];
        
        fontSize = 12 * contentScale;
        //float tmpDiff = -(self.frame.size.width / 2.0)*contentScale + blurBottomLimit - (firstGridXPt + i*gridXLinesStep);
        //weightAlpha = 1.0 - (tmpDiff<=0 ? 0.0 : (tmpDiff/blurBottomLimit));
        if((firstGridXPt + i*gridXLinesStep)<=0){
            weightAlpha = RENDERER_TYPECAST(myRender)->FadeValue((firstGridXPt + i*gridXLinesStep), (-self.frame.size.width / 2.0 + 10)*contentScale, 20*contentScale, 0.0, 1.0);
        }else{
            weightAlpha = RENDERER_TYPECAST(myRender)->FadeValue((firstGridXPt + i*gridXLinesStep), (self.frame.size.width / 2.0 - 30)*contentScale, 20*contentScale, 1.0, 0.0);
        };
        if(weightAlpha>0.01){
            glColor4f(0.0, 0.0, 0.0, weightAlpha);
            dateLabel = [[Texture2D alloc] initWithString:curLabelXstr dimensions:CGSizeMake(50*contentScale, 32) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:fontSize];
            //logStr = [logStr stringByAppendingFormat:@"%@ (x = %.0f, alpha = %.1f) | ", curLabelXstr, firstGridXPt + i*gridXLinesStep, weightAlpha];
            [dateLabel drawAtPoint:CGPointMake(firstGridXPt + i*gridXLinesStep, -(self.frame.size.height / 2.0)*contentScale + blurBottomLimit*0.3)];
            [dateLabel release];
            dateLabel = [[Texture2D alloc] initWithString:curLabelXstr dimensions:CGSizeMake(50*contentScale, 32) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:fontSize];
        }
    };
    NSLog(@"%@", logStr);
    
    NSTimeInterval startViewPortTi = RENDERER_TYPECAST(myRender)->GetXAxisVisibleRectStart();
    NSTimeInterval endViewPortTi = RENDERER_TYPECAST(myRender)->GetXAxisVisibleRectEnd();
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponentsStart = [gregorian components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)  fromDate:[NSDate dateWithTimeIntervalSince1970:startViewPortTi]];
    NSDateComponents *dateComponentsEnd = [gregorian components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)  fromDate:[NSDate dateWithTimeIntervalSince1970:endViewPortTi]];
    [gregorian release];
    
    // labeling top x-axis
    float tiPerPx = RENDERER_TYPECAST(myRender)->getTimeIntervalPerPixel();
    float topXaxis_alpha = RENDERER_TYPECAST(myRender)->FadeValue(tiPerPx, 38000, 4000, 0.8, 0.0);
    if(topXaxis_alpha>0.01){
        BOOL isYearsAxis = NO;
        float leftMonthWidth, rightMonthWidth, interLabelWidth;
        if(dateComponentsStart.month!=dateComponentsEnd.month || dateComponentsStart.year!=dateComponentsEnd.year){
            NSTimeInterval interTi1, interTi2, interTi3;
            if(((dateComponentsEnd.month-dateComponentsStart.month)==1 ||
                (dateComponentsEnd.month-dateComponentsStart.month)==2 ||
                (dateComponentsEnd.month<=2 && dateComponentsStart.month>=11)) && (timeIntLinesStep<ONE_MONTH)){
                dateFormatter.dateFormat = @"MMMM";
                interTi1 = [self firstDayOfMonth:endViewPortTi];
                interTi3 = interTi2 = interTi1;
                isYearsAxis = NO;
            }else{
                dateFormatter.dateFormat = @"YYYY";
                interTi1 = [self firstDayOfYear:endViewPortTi];
                interTi3 = interTi2 = interTi1;
                isYearsAxis = YES;
            };
            
            float x_division_pos1 = ((interTi1 - startViewPortTi) * self.frame.size.width * contentScale) / (endViewPortTi - startViewPortTi);
            float x_division_pos2, x_division_pos3;
            x_division_pos3 = x_division_pos2 = x_division_pos1;
            NSString *rightMonth = [dateFormatter stringFromDate:[self dateFromComponents:dateComponentsEnd]];
            if(isYearsAxis){
                dateComponentsEnd.year--;
            }else{
                dateComponentsEnd.month--;
            };
            NSString *leftMonth  = [dateFormatter stringFromDate:[self dateFromComponents:dateComponentsEnd]];
            
            leftMonthWidth = [leftMonth sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0]].width;
            rightMonthWidth = [rightMonth sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0]].width;
            interLabelWidth = (leftMonthWidth/2.0+rightMonthWidth/2.0)*contentScale;
            
            
            Texture2D *leftMonthLabel = [[Texture2D alloc] initWithString:leftMonth dimensions:CGSizeMake(leftMonthWidth*contentScale, 32) alignment:NSTextAlignmentCenter fontName:@"Helvetica" fontSize:12.0*contentScale];
            glColor4f(0.0, 0.0, 0.0, topXaxis_alpha);
            if(x_division_pos1-interLabelWidth < (self.frame.size.width * contentScale * 0.5)){
                float tmpXleftCoord = -self.frame.size.width*contentScale/2.0 + x_division_pos1 - interLabelWidth;
                [leftMonthLabel drawAtPoint:CGPointMake(tmpXleftCoord,  -(self.frame.size.height / 2.0)*contentScale + blurBottomLimit*0.9)];
            }else{
                [leftMonthLabel drawAtPoint:CGPointMake(0.0,  -(self.frame.size.height / 2.0)*contentScale + blurBottomLimit*0.9)];
            };
            [leftMonthLabel release];
            
            Texture2D *rightMonthLabel = [[Texture2D alloc] initWithString:rightMonth dimensions:CGSizeMake(rightMonthWidth*contentScale*2, 32) alignment:NSTextAlignmentCenter fontName:@"Helvetica" fontSize:12.0*contentScale];
            glColor4f(0.0, 0.0, 0.0, topXaxis_alpha);
            if(x_division_pos1+interLabelWidth >= (self.frame.size.width * contentScale * 0.5)){
                float correction = - x_division_pos1 + (self.frame.size.width * contentScale * 0.5);
                if(correction<0) correction = 0;
                float tmpXrightCoord = -self.frame.size.width*contentScale/2.0 + x_division_pos1 + correction;
                [rightMonthLabel drawAtPoint:CGPointMake(tmpXrightCoord,  -(self.frame.size.height / 2.0)*contentScale + blurBottomLimit*0.9)];
            }else{
                [rightMonthLabel drawAtPoint:CGPointMake(0.0,  -(self.frame.size.height / 2.0)*contentScale + blurBottomLimit*0.9)];
            };
            [rightMonthLabel release];
        }else{
            dateFormatter.dateFormat = @"MMMM";
            if(timeIntLinesStep>ONE_WEEK && timeIntLinesStep<2*ONE_MONTH){
                dateFormatter.dateFormat = @"YYYY";
            };
            
            NSString *centerMonth = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:endViewPortTi]];
            
            Texture2D *centerMonthLabel = [[Texture2D alloc] initWithString:centerMonth dimensions:CGSizeMake(self.frame.size.width*contentScale, 32) alignment:NSTextAlignmentCenter fontName:@"Helvetica" fontSize:12.0*contentScale];
            glColor4f(0.0, 0.0, 0.0, topXaxis_alpha);
            [centerMonthLabel drawAtPoint:CGPointMake(0.0,  -(self.frame.size.height / 2.0)*contentScale + blurBottomLimit*0.9)];
            [centerMonthLabel release];
        }
    };
    
    // Marking aim and norm lines
    float aimY = RENDERER_TYPECAST(myRender)->GetYForWeight(RENDERER_TYPECAST(myRender)->GetAimWeight());
    //NSLog(@"aim weight: %.1f, y = %.1f", RENDERER_TYPECAST(myRender)->GetAimWeight(), aimY);
    Texture2D *aimLabel = [[Texture2D alloc] initWithString:@"aim" dimensions:CGSizeMake(self.frame.size.width*contentScale, 32) alignment:NSTextAlignmentRight fontName:@"Helvetica" fontSize:12.0*contentScale];
    glColor4f(0.0, 1.0, 0.0, 0.8);
    [aimLabel drawAtPoint:CGPointMake(0.0, aimY)];
    [aimLabel release];
    
    float normY = RENDERER_TYPECAST(myRender)->GetYForWeight(RENDERER_TYPECAST(myRender)->GetNormalWeight())-4;
    Texture2D *normLabel = [[Texture2D alloc] initWithString:@"norm" dimensions:CGSizeMake(self.frame.size.width*contentScale, 32) alignment:NSTextAlignmentRight fontName:@"Helvetica" fontSize:12.0*contentScale];
    glColor4f(0.0, 0.0, 1.0, 0.8);
    [normLabel drawAtPoint:CGPointMake(0.0, normY)];
    [normLabel release];
    
    
    //FPS
    //glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    if(fpsStr==nil || drawingsCounter%30==0){
        if(fpsStr) [fpsStr release];
        fpsStr = [[NSString alloc] initWithFormat:@"%.0f fps", (float)(CLOCKS_PER_SEC / ((clock() - lastClock)))];
    };
    Texture2D *fpsLabel = [[Texture2D alloc] initWithString:fpsStr dimensions:CGSizeMake(self.frame.size.width*contentScale, 32) alignment:NSTextAlignmentRight fontName:@"Helvetica" fontSize:8.0*contentScale];
    glColor4f(0, 0, 0, 1);
    [fpsLabel drawAtPoint:CGPointMake(0.0, -(self.frame.size.height/2.0-30)*contentScale)];
    [fpsLabel release];
    
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glDisable(GL_BLEND);
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
    
    
    [plotContext presentRenderbuffer:GL_RENDERBUFFER_OES];
    
    
    if(drawingsCounter==60){
        drawingsCounter = 0;
    };
    lastClock = clock();
};

#pragma mark - Synchronization between layer-base and main application base

- (void)updatePlotLowLayerBase{
    //time_t startClock = clock();
    std::list<WeightControlDataRecord> syncBase;
    WeightControlDataRecord oneLowLayerRecord;
    syncBase.clear();
    float minY = 10000.0, maxY = 0.0, tmpWeight;
    for(NSDictionary *oneRecord in delegateWeight.weightData){
        oneLowLayerRecord.timeInterval = [[oneRecord objectForKey:@"date"] timeIntervalSince1970];
        oneLowLayerRecord.weight = [[oneRecord objectForKey:@"weight"] floatValue];
        oneLowLayerRecord.trend = [[oneRecord objectForKey:@"trend"] floatValue];
        tmpWeight = MIN(oneLowLayerRecord.weight, oneLowLayerRecord.trend);
        if(tmpWeight<minY) minY = tmpWeight;
        tmpWeight = MAX(oneLowLayerRecord.weight, oneLowLayerRecord.trend);
        if(tmpWeight>maxY) maxY = tmpWeight;
        
        syncBase.push_back(oneLowLayerRecord);
    };
    
    RENDERER_TYPECAST(myRender)->SetDataBase(syncBase);
    
    float normWeight = [delegateWeight.normalWeight floatValue];
    float aimWeight = [delegateWeight.aimWeight floatValue];
    RENDERER_TYPECAST(myRender)->SetNormalWeight(normWeight);
    RENDERER_TYPECAST(myRender)->SetAimWeight(aimWeight);
    if([delegateWeight.weightData count]>0){
        NSDictionary *firstObj, *lastObj;
        firstObj = [delegateWeight.weightData objectAtIndex:0];
        lastObj = [delegateWeight.weightData lastObject];
        float forecastTimeInt = [delegateWeight getTimeIntervalToAim];
        if(isnan(forecastTimeInt)) forecastTimeInt = 0.0;
        
        RENDERER_TYPECAST(myRender)->SetXAxisParams([[firstObj objectForKey:@"date"] timeIntervalSince1970], [[lastObj objectForKey:@"date"] timeIntervalSince1970]+forecastTimeInt);
        RENDERER_TYPECAST(myRender)->SetForecastTimeInterval(forecastTimeInt);
    }else{
        RENDERER_TYPECAST(myRender)->SetXAxisParams([[NSDate date] timeIntervalSince1970], [[NSDate date] timeIntervalSince1970]);
        RENDERER_TYPECAST(myRender)->SetForecastTimeInterval(0);
    };
    
    RENDERER_TYPECAST(myRender)->UpdateYAxisParams();
    
    //time_t endClock = clock();
    //NSLog(@"update low-layer base: %.7f sec", (double)(endClock-startClock)/CLOCKS_PER_SEC);

};

#pragma martk - Handling gestures

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer{
    CGFloat offsetX = ((CGPoint)[gestureRecognizer translationInView:self]).x;
    CGFloat velocityXScroll = ((CGPoint)[gestureRecognizer velocityInView:self]).x;
    //NSLog(@"handlePanGestureRecognizer: translate = %.0f, velocity = %.0f", offsetX, velocityXScroll);
    if(gestureRecognizer.state==UIGestureRecognizerStateBegan){
        startPanOffset = RENDERER_TYPECAST(myRender)->getCurOffsetX() / RENDERER_TYPECAST(myRender)->getTimeIntervalPerPixel();
        curPanOffset = 0.0;
    };
    
    if(gestureRecognizer.state==UIGestureRecognizerStateChanged){
        //NSLog(@"current x-offset (in px) = %.2f",startPanOffset - offsetX);
        float trashOffset = startPanOffset - offsetX;
        float maxOffset = RENDERER_TYPECAST(myRender)->getMaxOffsetPx();
        if(trashOffset <=0){
            //NSLog(@"Offset: %.2f, Trash offset: %.2f, exp = %.2f, sqrt = %.2f", offsetX, trashOffset, expf(trashOffset), sqrtf(fabs(trashOffset)));
            offsetX = sqrtf(fabs(4*trashOffset));
        };
        if(trashOffset > maxOffset){
            offsetX = startPanOffset - maxOffset - sqrt(4*(trashOffset - maxOffset));
            //curPanOffset = startPanOffset - maxOffset;
            //return;
        }
        
        RENDERER_TYPECAST(myRender)->isPlotOutOfBoundsForOffsetAndScale(startPanOffset - offsetX, RENDERER_TYPECAST(myRender)->getCurScaleX());
        
        RENDERER_TYPECAST(myRender)->SetOffsetPixels(startPanOffset - offsetX, fabs((offsetX-curPanOffset) / velocityXScroll));
        RENDERER_TYPECAST(myRender)->UpdateYAxisParamsForOffsetAndScale(startPanOffset - offsetX, RENDERER_TYPECAST(myRender)->getCurScaleX(), fabs((offsetX-curPanOffset) / velocityXScroll));
        curPanOffset = offsetX;
        panTimestamp = CACurrentMediaTime();
        
    };
    
    if(gestureRecognizer.state==UIGestureRecognizerStateEnded){
        //RENDERER_TYPECAST(myRender)->SmoothPanFinish(velocityXScroll);
        float endDuration = (CACurrentMediaTime() - panTimestamp);
        float slideSize = (endDuration <= 0.3) ? velocityXScroll*1.5 : 0.0;
        //NSLog(@"Pan velocity = %.2f timestamp = %.5f, slideSize = %.3f", velocityXScroll, endDuration, slideSize);
        if(fabs(slideSize)<100) return;
        
        float maxOffset = RENDERER_TYPECAST(myRender)->getMaxOffsetPx();
        if(startPanOffset - curPanOffset - slideSize <=0){
            slideSize = startPanOffset - curPanOffset;
        }else if(startPanOffset - curPanOffset - slideSize >= maxOffset){
            slideSize = startPanOffset - curPanOffset - maxOffset;
        };
        
        float deceleratingTime = fabs(slideSize) / 1000.0;
        RENDERER_TYPECAST(myRender)->SetOffsetPixelsDecelerating(startPanOffset - curPanOffset - slideSize, deceleratingTime);
        RENDERER_TYPECAST(myRender)->UpdateYAxisParamsForOffsetAndScale(startPanOffset - curPanOffset - slideSize, RENDERER_TYPECAST(myRender)->getCurScaleX(), deceleratingTime);
        
        NSLog(@"Finish slide size: %.0f px by %.1f sec", slideSize, deceleratingTime);
        //NSLog(@"Finish scroll velocity: %.2f", fabs((offsetX-curPanOffset) / velocityXScroll));
    };
};

- (void)handlePinchGestureRecognizer:(UIPinchGestureRecognizer *)gestureRecognizer{
    CGFloat scale = gestureRecognizer.scale;
    CGFloat velocity = gestureRecognizer.velocity;
    //NSLog(@"handlePinchGestureRecognizer: scale = %.1f, velocity = %.1f", scale, velocity);
    if(gestureRecognizer.state==UIGestureRecognizerStateBegan){
        startScale = RENDERER_TYPECAST(myRender)->getCurScaleX();
        curScale = 1.0;
    };
    
    if(gestureRecognizer.state==UIGestureRecognizerStateChanged){
        float newXOffset = RENDERER_TYPECAST(myRender)->getCurOffsetXForScale(startScale*scale) / RENDERER_TYPECAST(myRender)->getTimeIntervalPerPixelForScale(startScale * scale);
        float offsetCorrect = 0.0;
        if(RENDERER_TYPECAST(myRender)->isPlotOutOfBoundsForOffsetAndScale(newXOffset, startScale*scale)==true){
            offsetCorrect = fabs((RENDERER_TYPECAST(myRender)->getPlotWidthPxForScale(startScale*scale) -
                             RENDERER_TYPECAST(myRender)->getPlotWidthPxForScale(startScale*curScale)) / 2.0);
            //offsetCorrect *= scale;
            if(newXOffset<=0){
                //offsetCorrect = 5.0;
            }else{
                offsetCorrect *= -1.0;
            };
            newXOffset += offsetCorrect;
            if(RENDERER_TYPECAST(myRender)->isPlotOutOfBoundsForOffsetAndScale(newXOffset, startScale*scale)==true){
                gestureRecognizer.scale = curScale;
                return;
            }
            
            //NSLog(@"Plot width: %.2f -> %.2f", RENDERER_TYPECAST(myRender)->getPlotWidthPxForScale(startScale*curScale), RENDERER_TYPECAST(myRender)->getPlotWidthPxForScale(startScale*scale));
            //NSLog(@"offset correction for scale %.2f (last scale %.2f, scaleChange %.2f): %.2f", startScale*scale, startScale*curScale, startScale*(scale - curScale), offsetCorrect);
            float curOffsetX = RENDERER_TYPECAST(myRender)->getCurOffsetX() / RENDERER_TYPECAST(myRender)->getTimeIntervalPerPixelForScale(startScale*scale);
            RENDERER_TYPECAST(myRender)->SetOffsetPixels(curOffsetX + offsetCorrect, fabs((scale - curScale) / velocity));
        };
        
        if(RENDERER_TYPECAST(myRender)->getTimeIntervalPerPixelForScale(startScale*scale) < 150.0){
            gestureRecognizer.scale = curScale;
            return;
        };
        
        RENDERER_TYPECAST(myRender)->UpdateYAxisParamsForOffsetAndScale(newXOffset, startScale * scale, fabs((scale - curScale) / velocity));
        RENDERER_TYPECAST(myRender)->SetScaleX(startScale * scale, fabs((scale - curScale) / velocity));
        
        curScale = scale;
    };
    
    
    
    //NSTimeInterval curXOffset = RENDERER_TYPECAST(myRender)->getCurOffsetX();
    //RENDERER_TYPECAST(myRender)->SetOffsetTimeInterval(curXOffset, true);
    
};

- (void)_testHorizontalLinesAnimating{
    if(tmpVal){
        RENDERER_TYPECAST(myRender)->SetYAxisParams(70.0, 80.0, 0.5, 1.0);
        //RENDERER_TYPECAST(myRender)->SetScaleX(4.0, true);
        RENDERER_TYPECAST(myRender)->SetOffsetTimeInterval(0.0, 1.0);
        
    }else{
        RENDERER_TYPECAST(myRender)->SetYAxisParams(70.0, 100.0, 0.5, 1.0);
        //RENDERER_TYPECAST(myRender)->SetScaleX(1.0, true);
        RENDERER_TYPECAST(myRender)->SetOffsetTimeInterval(60*60*24*3, 1.0);
    };
    tmpVal = !tmpVal;
}

@end
