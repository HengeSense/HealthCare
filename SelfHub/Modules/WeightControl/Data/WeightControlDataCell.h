//
//  WeightControlDataCell.h
//  SelfHub
//
//  Created by Eugine Korobovsky on 11.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeightControlDataCell : UITableViewCell{
    
}

@property (nonatomic, retain) IBOutlet UILabel *weekdayLabel;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UILabel *weightLabel;
@property (nonatomic, retain) IBOutlet UILabel *trendLabel;
@property (nonatomic, retain) IBOutlet UILabel *deviationLabel;

@end
