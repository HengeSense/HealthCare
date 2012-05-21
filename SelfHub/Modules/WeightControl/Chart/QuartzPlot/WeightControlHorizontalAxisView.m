//
//  WeightControlHorizontalAxisView.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 17.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeightControlHorizontalAxisView.h"

@implementation WeightControlHorizontalAxisView

@synthesize isZooming, zoomScale, startTimeInterval, verticalGridLinesInterval, step;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if(verticalGridLinesInterval==0) return;
    
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Drawing horizontal axis line
    CGContextSetLineWidth(context, 2.0f);
    CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    CGContextMoveToPoint(context, 0.0, 1.0);
    CGContextAddLineToPoint(context, self.frame.size.width, 1.0);
    CGContextStrokePath(context);
    
    
    //Labeling Axis
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    CGContextSelectFont(context, "Helvetica", 12, kCGEncodingMacRoman); //specifying vertical axis's labels
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetFillColorWithColor(context, [[[UIColor blackColor] colorWithAlphaComponent:0.7f] CGColor]);
    CGContextSetTextMatrix(context, CGAffineTransformMake(1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f));
    NSUInteger i;
    NSString *curXAxisLabel;
    NSTimeInterval oneDay = 24*60*60;
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    NSDate *curDate;
    NSUInteger numOfLabels = (rect.origin.x + rect.size.width) / verticalGridLinesInterval;
    for(i=1;i<numOfLabels;i++){
        if(step==oneDay){
            dateFormatter.dateFormat = @"dd";
        }else{
            dateFormatter.dateFormat = @"MMM";
        };
        if(isZooming){      // show strokes while zooming
            CGContextMoveToPoint(context, i*verticalGridLinesInterval, 0.0);
            CGContextAddLineToPoint(context, i*verticalGridLinesInterval, 10.0);
        }else{              // show dates
            curDate = [NSDate dateWithTimeIntervalSince1970:startTimeInterval + i*step];
            curXAxisLabel = [dateFormatter stringFromDate:curDate];
            CGSize labelSize = [curXAxisLabel sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12]];
            CGContextShowTextAtPoint(context, i*verticalGridLinesInterval-labelSize.width/2, 14,
                                     [curXAxisLabel cStringUsingEncoding:NSUTF8StringEncoding], [curXAxisLabel length]);
        };
    };
    
    CGContextStrokePath(context);
    
}


@end
