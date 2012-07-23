//
//  WeightControlVerticalAxisView.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 15.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeightControlVerticalAxisView.h"

@implementation WeightControlVerticalAxisView

@synthesize startWeight, finishWeight, horizontalGridLinesInterval, numOfHorizontalLines;

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
    if(numOfHorizontalLines<2 || numOfHorizontalLines>100) return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Drawing wertical axis line
    CGContextSetLineWidth(context, 2.0f);
    CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    CGContextMoveToPoint(context, 32.0f, 0.0f);
    CGContextAddLineToPoint(context, 32.0f, self.frame.size.height - 13.0f);
    CGContextStrokePath(context);
    
    
    //Labeling Axis
    CGContextSelectFont(context, "Helvetica", 14, kCGEncodingMacRoman); //specifying vertical axis's labels
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextSetTextMatrix(context, CGAffineTransformMake(1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f));
    NSString *axisName = @"Kg";
    CGContextShowTextAtPoint(context, 0, 15, [axisName cStringUsingEncoding:NSUTF8StringEncoding], [axisName length]);

    
    CGContextSelectFont(context, "Helvetica", 12, kCGEncodingMacRoman); //specifying vertical axis's labels
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetFillColorWithColor(context, [[[UIColor blackColor] colorWithAlphaComponent:0.7f] CGColor]);
    CGContextSetTextMatrix(context, CGAffineTransformMake(1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f));
    NSUInteger i;
    NSString *curYAxisLabel;
    float deltaWeight = (finishWeight - startWeight) / numOfHorizontalLines;
    NSUInteger labelStep;
    if(horizontalGridLinesInterval>24) labelStep = 1;
    if(horizontalGridLinesInterval>12 && horizontalGridLinesInterval<=24) labelStep = 2;
    if(horizontalGridLinesInterval>6 && horizontalGridLinesInterval<=12) labelStep = 4;
    if(horizontalGridLinesInterval<=6) labelStep = 8;
    
    for(i=1;i<numOfHorizontalLines;i+=labelStep){
        CGContextMoveToPoint(context, rect.origin.x+rect.size.width-5.0, i*horizontalGridLinesInterval);
        CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, i*horizontalGridLinesInterval);
        CGContextStrokePath(context);
        
        curYAxisLabel = [NSString stringWithFormat:@"%.1f", startWeight + i*deltaWeight];
        
        //if(self.frame.size.height - i*horizontalGridLinesInterval - 12.0 < 25) continue;
        CGSize labelSize = [curYAxisLabel sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12]];
        CGContextShowTextAtPoint(context, 0, self.frame.size.height - i * horizontalGridLinesInterval + labelSize.height/4,
                                 [curYAxisLabel cStringUsingEncoding:NSUTF8StringEncoding], [curYAxisLabel length]);
    };

}

@end
