//
//  WeightControlStatisticsCell.h
//  SelfHub
//
//  Created by Eugine Korobovsky on 05.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeightControlChartSmoothLabel.h"

@interface WeightControlStatisticsCell : UITableViewCell{
    
    
};

@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, retain) IBOutlet UILabel *mainLabel;
@property (nonatomic, retain) IBOutlet WeightControlChartSmoothLabel *smoothLabel;
@property (nonatomic, retain) IBOutlet UILabel *label1;
@property (nonatomic, retain) IBOutlet UILabel *label2;

@end
