//
//  WeightControlVerticalAxisView.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 15.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeightControlVerticalAxisView.h"
#import <QuartzCore/QuartzCore.h>

#pragma mark - Y-Axis LAYER class

@implementation VerticalAxisLayer

@dynamic layerStartWeight;
@dynamic layerFinishWeight;
@dynamic layerHorizontalGridLinesInterval;
@dynamic layerNumOfHorizontalLines;

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


@end



#pragma mark - Y-Axis VIEW class

@implementation WeightControlVerticalAxisView

@synthesize startWeight, finishWeight, horizontalGridLinesInterval, numOfHorizontalLines;

+ (Class)layerClass{
    return [VerticalAxisLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //VerticalAxisLayer *myLayer = (VerticalAxisLayer *)self.layer;
        //myLayer.delegate = myLayer;
    }
    return self;
}



- (void)drawRect:(CGRect)rect{

};


- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    VerticalAxisLayer *myLayer = (VerticalAxisLayer *)layer;
    float _layerStartWeight = myLayer.layerStartWeight;
    float _layerFinishWeight = myLayer.layerFinishWeight;
    float _layerHorizontalGridLinesInterval = myLayer.layerHorizontalGridLinesInterval;
    NSUInteger _layerNumOfHorizontalLines = myLayer.layerNumOfHorizontalLines;
    
    //NSLog(@"Draw Y-Axis layer: start = %.1f, finish = %.1f, int = %.1f, num = %d", _layerStartWeight, _layerFinishWeight, _layerHorizontalGridLinesInterval, _layerNumOfHorizontalLines);
    
    CGRect rect = CGContextGetClipBoundingBox(ctx);
    CGContextRef context = ctx;
    
    if(_layerNumOfHorizontalLines<2 || _layerNumOfHorizontalLines>100) return;
    
    // Clear background
    CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(ctx, rect);
    
    
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
    float deltaWeight = (_layerFinishWeight - _layerStartWeight) / _layerNumOfHorizontalLines;
    NSUInteger labelStep;
    if(_layerHorizontalGridLinesInterval>24) labelStep = 1;
    if(_layerHorizontalGridLinesInterval>12 && _layerHorizontalGridLinesInterval<=24) labelStep = 2;
    if(_layerHorizontalGridLinesInterval>6 && _layerHorizontalGridLinesInterval<=12) labelStep = 4;
    if(_layerHorizontalGridLinesInterval<=6) labelStep = 8;
    
    for(i=1;i<_layerNumOfHorizontalLines;i+=labelStep){
        CGContextMoveToPoint(context, rect.origin.x+rect.size.width-5.0, self.frame.size.height - i*_layerHorizontalGridLinesInterval);
        CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, self.frame.size.height - i*_layerHorizontalGridLinesInterval);
        CGContextStrokePath(context);
        
        curYAxisLabel = [NSString stringWithFormat:@"%.1f", _layerStartWeight + i*deltaWeight];
        
        //if(self.frame.size.height - i*horizontalGridLinesInterval - 12.0 < 25) continue;
        CGSize labelSize = [curYAxisLabel sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12]];
        CGContextShowTextAtPoint(context, 0, self.frame.size.height - i * _layerHorizontalGridLinesInterval + labelSize.height/4,
                                 [curYAxisLabel cStringUsingEncoding:NSUTF8StringEncoding], [curYAxisLabel length]);
    };
    
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*
- (void)drawRect:(CGRect)rect
{
    //time_t startClock = clock();
    
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
        CGContextMoveToPoint(context, rect.origin.x+rect.size.width-5.0, self.frame.size.height - i*horizontalGridLinesInterval);
        CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, self.frame.size.height - i*horizontalGridLinesInterval);
        CGContextStrokePath(context);
        
        curYAxisLabel = [NSString stringWithFormat:@"%.1f", startWeight + i*deltaWeight];
        
        //if(self.frame.size.height - i*horizontalGridLinesInterval - 12.0 < 25) continue;
        CGSize labelSize = [curYAxisLabel sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12]];
        CGContextShowTextAtPoint(context, 0, self.frame.size.height - i * horizontalGridLinesInterval + labelSize.height/4,
                                 [curYAxisLabel cStringUsingEncoding:NSUTF8StringEncoding], [curYAxisLabel length]);
    };
    
    //time_t endClock = clock();
    //NSLog(@"Y_AXIS drawLayer: (%.0f, %.0f, %.0f, %.0f) - %.3f sec", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height, (float)(endClock-startClock)/CLOCKS_PER_SEC);


}*/

@end
