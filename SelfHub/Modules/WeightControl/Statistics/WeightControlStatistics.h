//
//  WeightControlStatistics.h
//  SelfHub
//
//  Created by Eugine Korobovsky on 12.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeightControl.h"
#import "WeightControlStatisticsCell.h"

@class WeightControl;
@class WeightControlStatisticsCell;

@interface WeightControlStatistics : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    
};

@property (nonatomic, assign) IBOutlet WeightControl *delegate;

@property (nonatomic, retain) IBOutlet UITableView *statTableView;

- (float)getRecordValueAtTimeInterval:(NSTimeInterval)needInterval forKey:(NSString *)key;


@end
