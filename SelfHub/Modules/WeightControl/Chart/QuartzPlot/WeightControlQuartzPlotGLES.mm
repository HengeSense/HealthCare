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
        if(std::isnan(forecastTimeInt)) forecastTimeInt = 0.0;
        RENDERER_TYPECAST(myRender)->SetXAxisParams([[delegateWeight getDateWithoutTime:firstDate] timeIntervalSince1970], [lastDate timeIntervalSince1970] + forecastTimeInt);
        RENDERER_TYPECAST(myRender)->SetScaleX(1.0);
        RENDERER_TYPECAST(myRender)->SetOffsetTimeInterval(0.0);
        
        [self createTextureForImage:@"weightControlChartGLES_background.png"];
        
        
        
        [self updatePlotLowLayerBase];
        
        allGLESLabels = [[NSMutableDictionary alloc] init];
        
        
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
        
        //lastShowedTiPerPx, lastShowedTimeIntervalInCenter
        
        
    }
    return self;
}

- (void)dealloc{
    [allGLESLabels removeAllObjects];
    [allGLESLabels release];
    
    [super dealloc];
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
    NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
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

- (GLuint)createTextureForImage:(NSString *)imageName{
    CGImageRef spriteImage = [UIImage imageNamed:imageName].CGImage;
    if (!spriteImage) {
        NSLog(@"Cannot open image %@", imageName);
        return 0;
    };
    
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);

    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    
    GLint existTexureId;
    glGenTextures(1, &backgroundTextureId);
    glGetIntegerv(GL_TEXTURE_BINDING_2D, &existTexureId);
    glBindTexture(GL_TEXTURE_2D, backgroundTextureId);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    glBindTexture(GL_TEXTURE_2D, existTexureId);
    
    texturesInHorizontal = self.frame.size.width*contentScale/width;
    texturesInVertical = self.frame.size.height*contentScale/height;
    
    free(spriteData);        
    return backgroundTextureId;
};

- (UIImage *)getViewScreenshot{
    GLint backingWidth, backingHeight;
    
    CAEAGLLayer* eaglLayer = (CAEAGLLayer*) super.layer;
    NSMutableDictionary *newDrawableProperties = [NSMutableDictionary dictionaryWithDictionary:eaglLayer.drawableProperties];
    [newDrawableProperties setObject:[NSNumber numberWithBool:YES] forKey:kEAGLDrawablePropertyRetainedBacking];
    [eaglLayer setDrawableProperties:newDrawableProperties];
    [plotContext renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable: eaglLayer];
    BOOL lastRedrawFlag = pauseRedraw;
    pauseRedraw = NO;
    [self performSelectorOnMainThread:@selector(drawView:) withObject:nil waitUntilDone:YES];
    pauseRedraw = lastRedrawFlag;
    
    // Bind the color renderbuffer used to render the OpenGL ES view
    // If your application only creates a single color renderbuffer which is already bound at this point,
    // this call is redundant, but it is needed if you're dealing with multiple renderbuffers.
    // Note, replace "_colorRenderbuffer" with the actual name of the renderbuffer object defined in your class.
    //glBindRenderbufferOES(GL_RENDERBUFFER_OES, RENDERER_TYPECAST(myRender)->GetRenderbuffer());
    
    // Get the size of the backing CAEAGLLayer
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    NSInteger x = 0, y = 0, width = backingWidth, height = backingHeight;
    NSInteger dataLength = width * height * 4;
    GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
    
    
    // Read pixel data from the framebuffer
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    // Create a CGImage with the pixel data
    // If your OpenGL ES content is opaque, use kCGImageAlphaNoneSkipLast to ignore the alpha channel
    // otherwise, use kCGImageAlphaPremultipliedLast
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGImageRef iref = CGImageCreate(width, height, 8, 32, width * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaNoneSkipLast, ref, NULL, true, kCGRenderingIntentDefault);
    
    // OpenGL ES measures data in PIXELS
    // Create a graphics context with the target size measured in POINTS
    NSInteger widthInPoints, heightInPoints;
    if (NULL != UIGraphicsBeginImageContextWithOptions) {
        // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
        // Set the scale parameter to your OpenGL ES view's contentScaleFactor
        // so that you get a high-resolution snapshot when its value is greater than 1.0
        widthInPoints = width / contentScale;
        heightInPoints = height / contentScale;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(widthInPoints, heightInPoints), NO, contentScale);
    }
    else {
        // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
        widthInPoints = width;
        heightInPoints = height;
        UIGraphicsBeginImageContext(CGSizeMake(widthInPoints, heightInPoints));
    }
    
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    
    // UIKit coordinate system is upside down to GL/Quartz coordinate system
    // Flip the CGImage by rendering it to the flipped bitmap context
    // The size of the destination area is measured in POINTS
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, widthInPoints, heightInPoints), iref);
    
    // Retrieve the UIImage from the current context
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [newDrawableProperties setObject:[NSNumber numberWithBool:NO] forKey:kEAGLDrawablePropertyRetainedBacking];
    [eaglLayer setDrawableProperties:newDrawableProperties];
    [plotContext renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable: eaglLayer];
    
    // Clean up
    free(data);
    CFRelease(ref);
    CFRelease(colorspace);
    CGImageRelease(iref);
    
    return image;
};

- (Texture2D *)getTexture2DForStringLazy:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size{
    NSString *key = [NSString stringWithFormat:@"%@_%.1fx%.1f_%d_%@_%.1f", string, dimensions.width, dimensions.height, alignment, name, size];
    Texture2D *texture = [allGLESLabels objectForKey:key];
    if(texture==nil){
        texture = [[Texture2D alloc] initWithString:string dimensions:dimensions alignment:alignment fontName:name fontSize:size];
        [allGLESLabels setObject:texture forKey:key];
        [texture release];
        texture = [allGLESLabels objectForKey:key];
        //NSLog(@" + %@", key);
    };
    
    return texture;
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
    
    
    
    
    // Drawing plot background
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_TEXTURE_2D);
    glDisable(GL_BLEND);
    glColor4f(1.0, 1.0, 1.0, 1.0);
    //CGRect backgroundBounds = CGRectMake(-self.frame.size.width*contentScale/2.0, -self.frame.size.height*contentScale/2.0, self.frame.size.width*contentScale, self.frame.size.height*contentScale);
	//[backgroundTexture drawInRect:backgroundBounds];
    GLfloat	 coordinates[] = {  0,                         texturesInVertical,
                                texturesInHorizontal,      texturesInVertical,
                                0,                         0,
                                texturesInHorizontal,      0  };
    GLfloat	vertices[] = {	-self.frame.size.width*contentScale/2.0,    -self.frame.size.height*contentScale/2.0,
                            +self.frame.size.width*contentScale/2.0,	-self.frame.size.height*contentScale/2.0,
                            -self.frame.size.width*contentScale/2.0,    +self.frame.size.height*contentScale/2.0,
                            +self.frame.size.width*contentScale/2.0,    +self.frame.size.height*contentScale/2.0    };
    glBindTexture(GL_TEXTURE_2D, backgroundTextureId);
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    glEnable(GL_BLEND);
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
    
    
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
    color colorFromSettings = RENDERER_TYPECAST(myRender)->GetDrawSettings()->verticalAxisLabelsColor;
    for(i=0;i<linesNum;i++){
        curWeight = firstGridWeight + i*weightLinesStep;
        weightStr = [[NSString alloc] initWithFormat:(fabs(curWeight - ceil(curWeight))>0.0001 ? @"%.1f" : @"%.0f"), curWeight];
        fontSize = ([weightStr length]>4 ? 11 : 12) * contentScale;
        weightLabel = [self getTexture2DForStringLazy:weightStr dimensions:CGSizeMake(50*contentScale, 32) alignment:UITextAlignmentLeft fontName:@"Helvetica-Bold" fontSize:fontSize];
        if((firstGridPt + i*gridLinesStep)<=0){
            weightAlpha = RENDERER_TYPECAST(myRender)->FadeValue((firstGridPt + i*gridLinesStep), -(self.frame.size.height*contentScale/2.0 - blurBottomLimit), blurBottomLimit, 0.0, colorFromSettings.a);
        }else{
            weightAlpha = RENDERER_TYPECAST(myRender)->FadeValue((firstGridPt + i*gridLinesStep), +(self.frame.size.height*contentScale/2.0 - blurBottomLimit*1.3), blurBottomLimit, colorFromSettings.a, 0.0);
        };
        glColor4f(colorFromSettings.r, colorFromSettings.g, colorFromSettings.b, weightAlpha);
        [weightLabel drawAtPoint:CGPointMake(-(self.frame.size.width / 2.0-28) * contentScale, firstGridPt + i*gridLinesStep + 5*contentScale)];
        //[weightLabel release];
        [weightStr release];
        
    };
    
    
    // X-Axis labels
    float firstGridXPt, firstGridXTimeInterval, gridXLinesStep, timeIntLinesStep;//, firstLabelCorrect = 0.0;
    unsigned short linesXNum;
    RENDERER_TYPECAST(myRender)->GetXAxisDrawParams(firstGridXPt, firstGridXTimeInterval, gridXLinesStep, timeIntLinesStep, linesXNum);
    colorFromSettings = RENDERER_TYPECAST(myRender)->GetDrawSettings()->horizontalAxisLabelsColor;
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
        if((firstGridXPt + i*gridXLinesStep)<=0){
            weightAlpha = RENDERER_TYPECAST(myRender)->FadeValue((firstGridXPt + i*gridXLinesStep), (-self.frame.size.width / 2.0 + 10)*contentScale, 20*contentScale, 0.0, colorFromSettings.a);
        }else{
            weightAlpha = RENDERER_TYPECAST(myRender)->FadeValue((firstGridXPt + i*gridXLinesStep), (self.frame.size.width / 2.0 - 30)*contentScale, 20*contentScale, colorFromSettings.a, 0.0);
        };
        if(weightAlpha>0.01){
            glColor4f(colorFromSettings.r, colorFromSettings.g, colorFromSettings.b, weightAlpha);
            dateLabel = [self getTexture2DForStringLazy:curLabelXstr dimensions:CGSizeMake(50*contentScale, 32) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:fontSize];
            [dateLabel drawAtPoint:CGPointMake(firstGridXPt + i*gridXLinesStep, -(self.frame.size.height / 2.0)*contentScale + blurBottomLimit*0.3)];
            //[dateLabel release];
        }
    };
    
    NSTimeInterval startViewPortTi = RENDERER_TYPECAST(myRender)->GetXAxisVisibleRectStart();
    NSTimeInterval endViewPortTi = RENDERER_TYPECAST(myRender)->GetXAxisVisibleRectEnd();
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponentsStart = [gregorian components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)  fromDate:[NSDate dateWithTimeIntervalSince1970:startViewPortTi]];
    NSDateComponents *dateComponentsEnd = [gregorian components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)  fromDate:[NSDate dateWithTimeIntervalSince1970:endViewPortTi]];
    [gregorian release];
    
    // labeling top x-axis
    float tiPerPx = RENDERER_TYPECAST(myRender)->getTimeIntervalPerPixel();
    float topXaxis_alpha = RENDERER_TYPECAST(myRender)->FadeValue(tiPerPx, 38000, 4000, colorFromSettings.a, 0.0);
    if(topXaxis_alpha>0.01){
        glColor4f(colorFromSettings.r, colorFromSettings.g, colorFromSettings.b, topXaxis_alpha);
        
        BOOL isYearsAxis = NO;
        float leftMonthWidth, rightMonthWidth, interLabelWidth;
        //NSLog(@"(%d != %d && %d == %d) || %d != %d", dateComponentsStart.month, dateComponentsEnd.month, dateComponentsStart.year, dateComponentsEnd.year, dateComponentsStart.year, dateComponentsEnd.year);
        if(timeIntLinesStep<ONE_MONTH){
            isYearsAxis = NO;
        }else{
            isYearsAxis = YES;
        };
        
        
        if((dateComponentsStart.month!=dateComponentsEnd.month && !isYearsAxis) || (dateComponentsStart.year!=dateComponentsEnd.year && isYearsAxis)){
            NSTimeInterval interTi1;
            if(!isYearsAxis){
                dateFormatter.dateFormat = @"MMMM";
                interTi1 = [self firstDayOfMonth:endViewPortTi];
            }else{
                dateFormatter.dateFormat = @"YYYY";
                interTi1 = [self firstDayOfYear:endViewPortTi];
            };
            
            float x_division_pos1 = ((interTi1 - startViewPortTi) * self.frame.size.width * contentScale) / (endViewPortTi - startViewPortTi);
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
            
            
            Texture2D *leftMonthLabel = [self getTexture2DForStringLazy:leftMonth dimensions:CGSizeMake(leftMonthWidth*contentScale, 32) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:12.0*contentScale];
            if(x_division_pos1-interLabelWidth < (self.frame.size.width * contentScale * 0.5)){
                float tmpXleftCoord = -self.frame.size.width*contentScale/2.0 + x_division_pos1 - interLabelWidth;
                [leftMonthLabel drawAtPoint:CGPointMake(tmpXleftCoord,  -(self.frame.size.height / 2.0)*contentScale + blurBottomLimit*0.9)];
            }else{
                [leftMonthLabel drawAtPoint:CGPointMake(0.0,  -(self.frame.size.height / 2.0)*contentScale + blurBottomLimit*0.9)];
            };
            //[leftMonthLabel release];
            
            Texture2D *rightMonthLabel = [self getTexture2DForStringLazy:rightMonth dimensions:CGSizeMake(rightMonthWidth*contentScale*2, 32) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:12.0*contentScale];
            if(x_division_pos1+interLabelWidth >= (self.frame.size.width * contentScale * 0.5)){
                float correction = - x_division_pos1 + (self.frame.size.width * contentScale * 0.5);
                if(correction<0) correction = 0;
                float tmpXrightCoord = -self.frame.size.width*contentScale/2.0 + x_division_pos1 + correction;
                [rightMonthLabel drawAtPoint:CGPointMake(tmpXrightCoord,  -(self.frame.size.height / 2.0)*contentScale + blurBottomLimit*0.9)];
            }else{
                [rightMonthLabel drawAtPoint:CGPointMake(0.0,  -(self.frame.size.height / 2.0)*contentScale + blurBottomLimit*0.9)];
            };
            //[rightMonthLabel release];
        }else{
            //NSLog(@"one top-label with end-date: %@", [[NSDate dateWithTimeIntervalSince1970:endViewPortTi] description]);
            if(!isYearsAxis){
                dateFormatter.dateFormat = @"MMMM";
                endViewPortTi = [self firstDayOfMonth:endViewPortTi];
            }else{
                dateFormatter.dateFormat = @"YYYY";
                endViewPortTi = [self firstDayOfYear:endViewPortTi];
            };
            
            NSString *centerMonth = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:endViewPortTi]];
            
            Texture2D *centerMonthLabel = [self getTexture2DForStringLazy:centerMonth dimensions:CGSizeMake(self.frame.size.width*contentScale, 32) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:12.0*contentScale];
            [centerMonthLabel drawAtPoint:CGPointMake(0.0,  -(self.frame.size.height / 2.0)*contentScale + blurBottomLimit*0.9)];
            //[centerMonthLabel release];
        }
    };
    
    // Marking aim and norm lines
    float aimY = RENDERER_TYPECAST(myRender)->GetYForWeight(RENDERER_TYPECAST(myRender)->GetAimWeight());
    //NSLog(@"aim weight: %.1f, y = %.1f", RENDERER_TYPECAST(myRender)->GetAimWeight(), aimY);
    Texture2D *aimLabel = [self getTexture2DForStringLazy:@"aim" dimensions:CGSizeMake(self.frame.size.width*contentScale, 32) alignment:UITextAlignmentRight fontName:@"Helvetica" fontSize:12.0*contentScale];
    colorFromSettings = RENDERER_TYPECAST(myRender)->GetDrawSettings()->aimLabelColor;
    glColor4f(colorFromSettings.r, colorFromSettings.g, colorFromSettings.b, colorFromSettings.a);
    [aimLabel drawAtPoint:CGPointMake(0.0, aimY)];
    //[aimLabel release];
    
    float normY = RENDERER_TYPECAST(myRender)->GetYForWeight(RENDERER_TYPECAST(myRender)->GetNormalWeight())-4;
    Texture2D *normLabel = [self getTexture2DForStringLazy:@"norm" dimensions:CGSizeMake(self.frame.size.width*contentScale, 32) alignment:UITextAlignmentRight fontName:@"Helvetica" fontSize:12.0*contentScale];
    colorFromSettings = RENDERER_TYPECAST(myRender)->GetDrawSettings()->normLabelColor;
    glColor4f(colorFromSettings.r, colorFromSettings.g, colorFromSettings.b, colorFromSettings.a);
    [normLabel drawAtPoint:CGPointMake(0.0, normY)];
    //[normLabel release];
    
    
    //FPS
    /*if(fpsStr==nil || drawingsCounter%30==0){
     if(fpsStr) [fpsStr release];
     fpsStr = [[NSString alloc] initWithFormat:@"%.0f fps", (float)(CLOCKS_PER_SEC / ((clock() - lastClock)))];
     };
     Texture2D *fpsLabel = [self getTexture2DForStringLazy:fpsStr dimensions:CGSizeMake(self.frame.size.width*contentScale, 32) alignment:NSTextAlignmentRight fontName:@"Helvetica" fontSize:8.0*contentScale];
     glColor4f(0, 0, 0, 1);
     [fpsLabel drawAtPoint:CGPointMake(0.0, -(self.frame.size.height/2.0-30)*contentScale)];
     //[fpsLabel release];*/
    
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
    
    float curTimeIntInCenter = RENDERER_TYPECAST(myRender)->GetTimeIntervalInCenter();
    
    RENDERER_TYPECAST(myRender)->SetDataBase(syncBase);
    
    RENDERER_TYPECAST(myRender)->getCurOffsetX();
    
    float normWeight = [delegateWeight.normalWeight floatValue];
    float aimWeight = [delegateWeight.aimWeight floatValue];
    RENDERER_TYPECAST(myRender)->SetNormalWeight(normWeight);
    RENDERER_TYPECAST(myRender)->SetAimWeight(aimWeight);
    if([delegateWeight.weightData count]>0){
        NSDictionary *firstObj, *lastObj;
        firstObj = [delegateWeight.weightData objectAtIndex:0];
        lastObj = [delegateWeight.weightData lastObject];
        float forecastTimeInt = [delegateWeight getTimeIntervalToAim];
        if(std::isnan(forecastTimeInt)) forecastTimeInt = 0.0;
        
        RENDERER_TYPECAST(myRender)->SetXAxisParams([[delegateWeight getDateWithoutTime:[firstObj objectForKey:@"date"]] timeIntervalSince1970], [[lastObj objectForKey:@"date"] timeIntervalSince1970]+forecastTimeInt);
        RENDERER_TYPECAST(myRender)->SetForecastTimeInterval(forecastTimeInt);
    }else{
        RENDERER_TYPECAST(myRender)->SetXAxisParams([[delegateWeight getDateWithoutTime:[NSDate date]] timeIntervalSince1970], [[NSDate date] timeIntervalSince1970]);
        RENDERER_TYPECAST(myRender)->SetForecastTimeInterval(0);
    };
    
    if(!RENDERER_TYPECAST(myRender)->SetTimeIntervalInCenter(curTimeIntInCenter)){
        [self showLastDayInCenterWithTiPerPx:1500.0];
    };
    
    RENDERER_TYPECAST(myRender)->UpdateYAxisParams();
    
    //time_t endClock = clock();
    //NSLog(@"update low-layer base: %.7f sec", (double)(endClock-startClock)/CLOCKS_PER_SEC);
    
};

- (void)showLastDayInCenterWithTiPerPx:(float)tiPerPx{
    RENDERER_TYPECAST(myRender)->SetTiPerPx(tiPerPx, 0.0);
    if([delegateWeight.weightData count]>0){
        float visibleTimeInt = [[[delegateWeight.weightData lastObject] objectForKey:@"date"] timeIntervalSince1970];
        RENDERER_TYPECAST(myRender)->SetTimeIntervalInCenter(visibleTimeInt);
    };
    
    RENDERER_TYPECAST(myRender)->UpdateYAxisParams();
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
            offsetX = sqrtf(fabs(8*trashOffset));
        };
        if(trashOffset > maxOffset){
            offsetX = startPanOffset - maxOffset - sqrt(16*(trashOffset - maxOffset));
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
        //curPanOffset = offsetX;
        //RENDERER_TYPECAST(myRender)->SmoothPanFinish(velocityXScroll);
        float endDuration = (CACurrentMediaTime() - panTimestamp);
        float slideSize = (endDuration <= 0.3) ? velocityXScroll*1.5 : 0.0;
        //NSLog(@"Pan velocity = %.2f timestamp = %.5f, slideSize = %.3f", velocityXScroll, endDuration, slideSize);
        
        float maxOffset = RENDERER_TYPECAST(myRender)->getMaxOffsetPx();
        if(startPanOffset - curPanOffset - slideSize <=0){
            slideSize = startPanOffset - curPanOffset;
        }else if(startPanOffset - curPanOffset - slideSize >= maxOffset){
            slideSize = startPanOffset - curPanOffset - maxOffset;
        }else{
            if(fabs(slideSize)<100) return;
        };
        
        float deceleratingTime = fabs(slideSize) / 1000.0;
        RENDERER_TYPECAST(myRender)->SetOffsetPixelsDecelerating(startPanOffset - curPanOffset - slideSize, deceleratingTime);
        RENDERER_TYPECAST(myRender)->UpdateYAxisParamsForOffsetAndScale(startPanOffset - curPanOffset - slideSize, RENDERER_TYPECAST(myRender)->getCurScaleX(), deceleratingTime);
        
        //NSLog(@"Finish slide size: %.0f px by %.1f sec", slideSize, deceleratingTime);
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
        
        float minTiPerPx = RENDERER_TYPECAST(myRender)->GetDrawSettings()->minTiPerPx;
        float maxTiPerPx = RENDERER_TYPECAST(myRender)->GetDrawSettings()->maxTiPerPx;
        float curTiPerPx = RENDERER_TYPECAST(myRender)->getTimeIntervalPerPixelForScale(startScale*scale);
        if(curTiPerPx < minTiPerPx || (curTiPerPx > maxTiPerPx && scale < curScale)){
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
