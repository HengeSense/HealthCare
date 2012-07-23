//
//  WeightControlQuartzPlotPointer.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 29.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeightControlQuartzPlotPointer.h"


#pragma mark - Scroller view for pointer

@implementation WeightControlQuartzPlotPointerScrolerView
@synthesize delegate, pointerX, currentPointer_forPanGesture;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, frame.size.width, 30)];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0.0;
        self.userInteractionEnabled = YES;
        
        currentPointer_forPanGesture = frame.origin.x + frame.size.width / 2;
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureSelector:)];
        [self addGestureRecognizer:panGesture];
        [panGesture release];
    };
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    //CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIImage *arrowsImage = [UIImage imageNamed:@"weightControlQuartzPlotScrollPointer.png"];
    [arrowsImage drawInRect:CGRectMake(pointerX-25.0, 7.5, 50.0, 15.0)];
};

- (void)panGestureSelector:(UIPanGestureRecognizer *)sender{
    if(sender.state == UIGestureRecognizerStateBegan){
        currentPointer_forPanGesture = pointerX;
    }
       
    CGPoint curPoint = [sender translationInView:self];
    
    if((currentPointer_forPanGesture + curPoint.x)>(33+25) && (currentPointer_forPanGesture + curPoint.x)<(self.frame.size.width - 25)){
        pointerX = currentPointer_forPanGesture + curPoint.x;
        [delegate updatePointerDuringSelfScrolling:pointerX];
    };
    
    
    [self setNeedsDisplay];
};

- (void)showPointerScrollViewAtXCoord:(float)xCoord{
    pointerX = xCoord;
    [self setNeedsDisplay];
    
    if(self.alpha<0.1) [self showPointerScrollView];
};

- (void)showPointerScrollView{
    [UIView animateWithDuration:0.2 animations:^(void){
        self.alpha = 0.3;
    }];
};

- (void)hidePointerScrollView{
    [UIView animateWithDuration:0.2 animations:^(void){
        self.alpha = 0.0;
    }];
};



@end


#pragma mark - Pointer interface

@implementation WeightControlQuartzPlotPointer
@synthesize delegate, curTimeInt;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0.0;
        self.userInteractionEnabled = NO;
    };
    return self;
};

- (void)dealloc{
    delegate = nil;
    
    [super dealloc];
};


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //NSLog(@"draw pointer: labelPoint = %.0fx%.0f", labelPoint.x, labelPoint.y);
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Drawing vertical pointer line
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [[UIColor blueColor] CGColor]);
    CGFloat dashForNormLine[] = {5.0F, 5.0f};
    CGContextSetLineDash(context, 0.0f, dashForNormLine, 2);
    CGContextMoveToPoint(context, weightLabelPoint.x, 0);
    CGContextAddLineToPoint(context, weightLabelPoint.x, rect.origin.y+rect.size.height);
    CGContextStrokePath(context);
    
    // Draw point circles for weight point
    CGContextSetLineDash(context, 0.0f, nil, 0);
    CGContextAddEllipseInRect(context, CGRectMake(weightLabelPoint.x-2.0, weightLabelPoint.y-2.0, 4, 4));
    CGContextSetFillColorWithColor(context, (weightLabelPoint.y>trendLabelPoint.y ? [[UIColor greenColor] CGColor] : [[UIColor redColor] CGColor]));
    CGContextDrawPath(context, kCGPathFillStroke);
    // Draw point circles for trend point
    CGContextAddEllipseInRect(context, CGRectMake(trendLabelPoint.x-2.0, trendLabelPoint.y-2.0, 4, 4));
    CGContextSetFillColorWithColor(context, [[UIColor redColor] CGColor]);
    CGContextDrawPath(context, kCGPathFillStroke);

    BOOL isRightLabeing = YES;
    if(weightLabelPoint.x >= (self.frame.size.width-80)) isRightLabeing = NO;
    
    // Draw weight label
    NSString *weightStr;
    weightStr = [NSString stringWithFormat:@"weight: %.1f kg", [delegate getWeightByY:weightLabelPoint.y]];
    UIFont *weightFont = [UIFont fontWithName:@"Helvetica" size:12.0f];
    CGPoint labelDrawingPoint = CGPointMake(weightLabelPoint.x, weightLabelPoint.y);
    if(!isRightLabeing){
        CGSize weightStrSize = [weightStr sizeWithFont:weightFont];
        labelDrawingPoint.x -= weightStrSize.width;
    };
    CGContextSetFillColorWithColor(context, [[(weightLabelPoint.y>trendLabelPoint.y ? [UIColor greenColor] : [UIColor redColor]) colorWithAlphaComponent:0.6] CGColor]);
    [weightStr drawAtPoint:labelDrawingPoint withFont:weightFont];
    
    // Draw trend label
    NSString *trendStr;
    trendStr = [NSString stringWithFormat:@"trend: %.1f kg", [delegate getWeightByY:trendLabelPoint.y]];
    UIFont *trendFont = [UIFont fontWithName:@"Helvetica" size:12.0f];
    labelDrawingPoint = CGPointMake(trendLabelPoint.x, trendLabelPoint.y);
    if(!isRightLabeing){
        CGSize weightStrSize = [weightStr sizeWithFont:weightFont];
        labelDrawingPoint.x -= weightStrSize.width;
    };
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    [trendStr drawAtPoint:labelDrawingPoint withFont:trendFont];
    
    // Draw date label at bottom of the pointer
    NSString *dateStr;
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter.dateFormat = @"dd MMM YY";
    dateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:curTimeInt]];
    UIFont *dateFont = [UIFont fontWithName:@"Helvetica-Bold" size:12.0f];
    labelDrawingPoint = CGPointMake(weightLabelPoint.x, self.frame.size.height-13);
    if(!isRightLabeing){
        CGSize dateStrSize = [dateStr sizeWithFont:dateFont];
        labelDrawingPoint.x -= dateStrSize.width;
    };
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    [dateStr drawAtPoint:labelDrawingPoint withFont:dateFont];
    
};

- (void)showPointerAtWeightPoint:(CGPoint)weightPoint andTrendPoint:(CGPoint)trendPoint;{
    weightLabelPoint = weightPoint;
    trendLabelPoint = trendPoint;
    [self setNeedsDisplay];
    //pointerScroller.pointerX = labelPoint.x;
    //[pointerScroller setNeedsDisplay];
    
    if(self.alpha<0.1) [self showPointerView];
};

/*
- (void)showPointerAtPoint:(CGPoint)touchPoint forContext:(CGImageRef)contentImage{
    NSArray *touchColumnColors = [self getColumnForPoint:touchPoint atImage:contentImage];
    int i;
    UIColor *orangeColor = [UIColor orangeColor];
    for(i=0;i<[touchColumnColors count];i++){
        if([self isEqualColor:[touchColumnColors objectAtIndex:i] toColor:orangeColor]){
            break;
        };
    };
    labelPoint = CGPointMake(touchPoint.x, i);
    NSLog(@"Orange color: %.0fx%.0f", labelPoint.x, labelPoint.y);
    
    [self setNeedsDisplay];
    [self showPointerView];
};*/

- (NSArray *)getColumnForPoint:(CGPoint)point atImage:(CGImageRef)image{
    NSUInteger imageWidth = CGImageGetWidth(image);
    NSUInteger imageHeight = CGImageGetHeight(image);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char *)calloc(imageWidth * imageHeight * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = imageWidth * bytesPerPixel;
    CGContextRef imageContext = CGBitmapContextCreate(rawData, imageWidth, imageHeight, 8, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(imageContext, CGRectMake(0, 0, imageWidth, imageHeight), image);
    CGContextRelease(imageContext);
    
    NSMutableArray *res = [[[NSMutableArray alloc] initWithCapacity:imageHeight] autorelease];
    NSUInteger pixelIndex;
    CGPoint curPoint = CGPointMake(point.x, 0);
    UIColor *curColor;
    int i;
    for(i=0;i<imageHeight;i++){
        pixelIndex = (bytesPerRow * curPoint.y) + curPoint.x * 4;
        CGFloat red = (float)rawData[pixelIndex+0] / 255.0;
        CGFloat green = (float)rawData[pixelIndex+1] / 255.0;
        CGFloat blue = (float)rawData[pixelIndex+2] / 255.0;
        CGFloat alpha = (float)rawData[pixelIndex+3] / 255.0;
        curColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        [res addObject:curColor];
        curPoint.y++;
    };
    
    return res;
};

- (BOOL)isEqualColor:(UIColor *)firstColor toColor:(UIColor *)secondColor{
    float red1, green1, blue1, alpha1;
    unsigned char red1_hex, green1_hex, blue1_hex;
    float red2, green2, blue2, alpha2;
    unsigned char red2_hex, green2_hex, blue2_hex;
    
    [firstColor getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];
    red1_hex = 255 * red1;
    green1_hex = 255 * green1;
    blue1_hex = 255 * blue1;

    [secondColor getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2];
    red2_hex = 255 * red2;
    green2_hex = 255 * green2;
    blue2_hex = 255 * blue2;
    
    NSUInteger total_deviation = abs(red1_hex-red2_hex) + abs(green1_hex-green2_hex) + abs(blue1_hex-blue2_hex);
    
    return total_deviation < 20 ? YES : NO;
};

- (void)showPointerView{
    [UIView animateWithDuration:0.2 animations:^(void){
        self.alpha = 1.0;
    }];
}
- (void)hidePointerView{
    [UIView animateWithDuration:0.2 animations:^(void){
        self.alpha = 0.0;
    }];
};

@end
