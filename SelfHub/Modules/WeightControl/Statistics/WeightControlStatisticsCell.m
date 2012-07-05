//
//  WeightControlStatisticsCell.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 05.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeightControlStatisticsCell.h"

@implementation WeightControlStatisticsCell

@synthesize mainLabel, label1, label2;

- (void)dealloc{
    [mainLabel release];
    [label1 release];
    [label2 release];
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
