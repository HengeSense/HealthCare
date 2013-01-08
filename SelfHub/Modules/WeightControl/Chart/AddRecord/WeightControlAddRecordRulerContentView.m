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

@synthesize points_between_100g, minWeightKg, maxWeightKg, stepWeightKg, weightFactor;


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
        labelFont = [[UIFont fontWithName:@"Helvetica-Bold" size:16.0] retain];
    }
    return self;
};

- (void)dealloc{
    [labelFont release];
    
    [super dealloc];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *lightGrayColor = [UIColor colorWithRed:125.0/255.0 green:125.0/255.0 blue:126.0/255.0 alpha:0.5];
    //UIColor *middleGrayColor = [UIColor colorWithRed:144.0/255.0 green:144.0/255.0 blue:144.0/255.0 alpha:0.5];
    UIColor *semiHardGrayColor = [UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:0.5];
    //UIColor *hardGrayColor = [UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:0.5];
    UIColor *redColor = [UIColor colorWithRed:84.0/255.0 green:12.0/255.0 blue:28.0/255.0 alpha:1.0];
    
    CGRect topRect = CGRectMake(rect.origin.x, rect.origin.y, rect.origin.x+rect.size.width, rect.origin.y+12);
    CGContextSetFillColorWithColor(context, [semiHardGrayColor CGColor]);
    CGContextFillRect(context, topRect);
    
    
    
    //Labeling Axis
    div_t dt = div((int)rect.origin.x, (int)points_between_100g);
    float curDrawX = dt.quot * points_between_100g;
    float curWeight = dt.quot * stepWeightKg;
    if(curDrawX < rect.origin.x){
        curDrawX += points_between_100g;
        curWeight += 0.1;
    };
    NSString *curWeightLabel = nil;
    
    CGContextSetLineWidth(context, 1.0f);
    CGContextSetStrokeColorWithColor(context, [semiHardGrayColor CGColor]);
    CGContextSetFillColorWithColor(context, [lightGrayColor CGColor]);
    
    //UIFont *myFont = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];       //instead labelFont
    
    for(;curDrawX<rect.origin.x+rect.size.width+points_between_100g;curDrawX+=points_between_100g){
        CGContextMoveToPoint(context, curDrawX - points_between_100g/2.0, rect.origin.y);
        CGContextAddLineToPoint(context, curDrawX - points_between_100g/2.0, rect.origin.y+rect.size.height);
        
        CGContextMoveToPoint(context, curDrawX + points_between_100g/2.0, rect.origin.y);
        CGContextAddLineToPoint(context, curDrawX + points_between_100g/2.0, rect.origin.y+rect.size.height);
        
        CGContextMoveToPoint(context, curDrawX, rect.origin.y);
        CGContextAddLineToPoint(context, curDrawX, rect.origin.y+20.0);
        
        curWeightLabel = [[NSString alloc] initWithFormat:@"%.1f", (minWeightKg + curWeight)*weightFactor];
        CGSize labelSize = [curWeightLabel sizeWithFont:labelFont];
        [curWeightLabel drawAtPoint:CGPointMake(curDrawX-labelSize.width/2.0, rect.size.height/2.0) withFont:labelFont];
        [curWeightLabel release];
        
        curWeight += 0.1;
    };
    
    CGContextStrokePath(context);
    
    CGRect bottomRect = CGRectMake(rect.origin.x, rect.origin.y+rect.size.height-14.0, rect.origin.x+rect.size.width, rect.origin.y+rect.size.height);
    CGContextSetFillColorWithColor(context, [redColor CGColor]);
    CGContextFillRect(context, bottomRect);


}

@end
