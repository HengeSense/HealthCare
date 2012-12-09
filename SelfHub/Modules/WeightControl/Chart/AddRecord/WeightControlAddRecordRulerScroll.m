//
//  WeightControlAddRecordRulerScroll.m
//  SelfHub
//
//  Created by Mac on 21.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeightControlAddRecordRulerScroll.h"
#import "WeightControlAddRecordRulerContentView.h"

#define POINTS_BETWEEN_100g 56.0

@implementation WeightControlAddRecordRulerScroll
@synthesize isNanAim;
@synthesize minWeightKg, maxWeightKg, stepWeightKg, weightFactor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder{
    self = [super initWithCoder:decoder];
    
    if(self){
        //Init code
        self.backgroundColor = [UIColor colorWithRed:17.0/255.0 green:19.0/255.0 blue:21.0/255.0 alpha:1.0];
        CGRect rulerFrame = CGRectMake(self.frame.size.width/2, 0, POINTS_BETWEEN_100g * 3000, self.frame.size.height);
        WeightControlAddRecordRulerContentView *rulerContent = [[[WeightControlAddRecordRulerContentView alloc] initWithFrame:rulerFrame and100gInterval:POINTS_BETWEEN_100g] autorelease];
        [self setScrollEnabled:YES];
        [self addSubview:rulerContent];
        [self setContentSize:rulerContent.frame.size];
        [self setShowsHorizontalScrollIndicator:NO];
        [self setShowsVerticalScrollIndicator:NO];
        //[rulerContent setNeedsDisplay];
        isNanAim = NO;
    }
    
    return self;
};

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)showWeight:(float)weight{
    for(UIView *oneSubView in [self subviews]){
        if([oneSubView isKindOfClass:[WeightControlAddRecordRulerContentView class]]){
            ((WeightControlAddRecordRulerContentView *)oneSubView).minWeightKg = self.minWeightKg;
            ((WeightControlAddRecordRulerContentView *)oneSubView).maxWeightKg = self.maxWeightKg;
            ((WeightControlAddRecordRulerContentView *)oneSubView).stepWeightKg = self.stepWeightKg;
            ((WeightControlAddRecordRulerContentView *)oneSubView).weightFactor = self.weightFactor;
            CGRect contentFrame = CGRectMake(self.frame.size.width/2, 0, POINTS_BETWEEN_100g * floor((maxWeightKg-minWeightKg)/stepWeightKg), self.frame.size.height);
            ((WeightControlAddRecordRulerContentView *)oneSubView).frame = contentFrame;
            [oneSubView setNeedsDisplay];
            [self setContentSize:contentFrame.size];
            break;
        }
    }
    
    CGPoint weightOffset;
    
    BOOL isNeedToSetNanAim = NO;
    if(isnan(weight)){
        weightOffset = CGPointMake(POINTS_BETWEEN_100g*((60.0-minWeightKg)/stepWeightKg), 0.0);
        isNeedToSetNanAim = YES;
    }else{
        weightOffset = CGPointMake(POINTS_BETWEEN_100g*((weight-minWeightKg)/stepWeightKg), 0.0);
    };
    
    div_t dt = div((int)weightOffset.x, POINTS_BETWEEN_100g);
    if(dt.rem <= (POINTS_BETWEEN_100g/2)){
        weightOffset.x = dt.quot * POINTS_BETWEEN_100g;
    }else{
        weightOffset.x = (dt.quot+1) * POINTS_BETWEEN_100g;
    };
    isNanAim = isNeedToSetNanAim;
    
    [self setContentOffset:weightOffset animated:NO];
    [self setNeedsDisplay];
};

- (float)getWeight{
    //NSLog(@"curWeight: %f", minWeightKg+((self.contentOffset.x) / (POINTS_BETWEEN_100g / stepWeightKg)));
    return isNanAim ? NAN : minWeightKg + ((self.contentOffset.x) / (POINTS_BETWEEN_100g / stepWeightKg));
};

- (float)getWeightForOffset:(float)needOffset{
    return minWeightKg + (needOffset / (POINTS_BETWEEN_100g / stepWeightKg));
};

- (float)getPointsBetween100g{
    return POINTS_BETWEEN_100g;
};

#pragma mark - UIScrollViewDelegate's functions


@end
