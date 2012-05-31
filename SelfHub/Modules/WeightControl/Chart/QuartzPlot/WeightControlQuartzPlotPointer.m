//
//  WeightControlQuartzPlotPointer.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 29.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeightControlQuartzPlotPointer.h"

@implementation WeightControlQuartzPlotPointer
@synthesize delegate;

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
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [[UIColor blueColor] CGColor]);
    CGFloat dashForNormLine[] = {5.0F, 5.0f};
    CGContextSetLineDash(context, 0.0f, dashForNormLine, 2);
    CGContextMoveToPoint(context, labelPoint.x, 0);
    CGContextAddLineToPoint(context, labelPoint.x, rect.origin.y+rect.size.height-15);
    CGContextStrokePath(context);
    
    CGContextSetLineDash(context, 0.0f, nil, 0);
    CGContextAddEllipseInRect(context, CGRectMake(labelPoint.x-2.0, labelPoint.y-2.0, 4, 4));
    CGContextSetFillColorWithColor(context, [[UIColor greenColor] CGColor]);
    CGContextDrawPath(context, kCGPathFillStroke);

    
    NSString *weightStr;
    weightStr = [NSString stringWithFormat:@"%.1f kg", [delegate getWeightByY:labelPoint.y]];
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    [weightStr drawAtPoint:CGPointMake(labelPoint.x, labelPoint.y) withFont:[UIFont fontWithName:@"Helvetica" size:12.0f]];
};

- (void)showPointerAtPoint:(CGPoint)currentPoint{
    labelPoint = currentPoint;
    [self setNeedsDisplay];
    [self showPointerView];
};

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
};

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
    
    NSMutableArray *res = [[NSMutableArray alloc] initWithCapacity:imageHeight];
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
