//
//  WeightControlAddRecordRulerView.m
//  SelfHub
//
//  Created by Mac on 21.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeightControlAddRecordRulerContentView.h"
#import "QuartzCore/QuartzCore.h"


@interface WeightControlAddRecordRulerTiledLayer : CATiledLayer
@end;

@implementation WeightControlAddRecordRulerTiledLayer

+ (NSTimeInterval)fadeDuration{
    return 0.2f;
}

@end



@implementation WeightControlAddRecordRulerContentView

@synthesize points_between_100g;


+ (Class)layerClass{
    return [WeightControlAddRecordRulerTiledLayer class];
};


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame and100gInterval:(float)interval{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        [self setClearsContextBeforeDrawing:NO];
        [self setClipsToBounds:NO];
        CATiledLayer *currentLayer = (CATiledLayer *)self.layer;
        [currentLayer setTileSize:CGSizeMake(interval*1.5*currentLayer.contentsScale, self.frame.size.height*currentLayer.contentsScale)];
        points_between_100g = interval;
    }
    return self;
};


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Drawing horizontal ruler line
    CGContextSetLineWidth(context, 2.0f);
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextMoveToPoint(context, rect.origin.x, 1.0);
    CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, 1.0);
    CGContextStrokePath(context);
    
    
    //Labeling Axis
    div_t dt = div((int)rect.origin.x, (int)points_between_100g);
    float curDrawX = dt.quot * points_between_100g;
    float curWeight = dt.quot / 10.0;
    if(curDrawX < rect.origin.x){
        curDrawX += points_between_100g;
        curWeight += 0.1;
    };
    NSString *curWeightLabel = nil;
    
    for(;curDrawX<rect.origin.x+rect.size.width+points_between_100g;curDrawX+=points_between_100g){
        CGContextMoveToPoint(context, curDrawX, 0.0);
        CGContextAddLineToPoint(context, curDrawX, 10.0);
        
        curWeightLabel = [[NSString alloc] initWithFormat:@"%.1f", curWeight];
        CGSize labelSize = [curWeightLabel sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:16.0]];
        [curWeightLabel drawAtPoint:CGPointMake(curDrawX-labelSize.width/2, 20.0) withFont:[UIFont fontWithName:@"Helvetica-Bold" size:16.0]];
        [curWeightLabel release];
        
        curWeight += 0.1;
    };
    
    CGContextStrokePath(context);

}

@end
