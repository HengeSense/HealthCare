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
        self.backgroundColor = [UIColor orangeColor];
        CGRect rulerFrame = CGRectMake(0, 0, POINTS_BETWEEN_100g * 3000, self.frame.size.height);
        WeightControlAddRecordRulerContentView *rulerContent = [[WeightControlAddRecordRulerContentView alloc] initWithFrame:rulerFrame and100gInterval:POINTS_BETWEEN_100g];
        [self setScrollEnabled:YES];
        [self addSubview:rulerContent];
        [self setContentSize:rulerContent.frame.size];
        //[rulerContent setNeedsDisplay];
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
    CGPoint weightOffset = CGPointMake(POINTS_BETWEEN_100g*weight*10.0 + self.frame.size.width/2, 0.0);
    
    div_t dt = div(((int)weightOffset.x + self.frame.size.width/2), POINTS_BETWEEN_100g);
    
    if(dt.rem <= (POINTS_BETWEEN_100g/2)){
        weightOffset.x = dt.quot * POINTS_BETWEEN_100g - self.frame.size.width/2;
    }else{
        weightOffset.x = (dt.quot+1) * POINTS_BETWEEN_100g - self.frame.size.width/2;
    };
    
    [self setContentOffset:weightOffset animated:YES];
};

- (float)getWeight{
    return (self.contentOffset.x + self.frame.size.width/2) / (POINTS_BETWEEN_100g*10.0);
};

- (float)getPointsBetween100g{
    return POINTS_BETWEEN_100g;
};


@end
